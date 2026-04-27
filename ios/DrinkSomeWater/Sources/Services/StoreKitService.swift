import Foundation
import StoreKit
import WidgetKit

// MARK: - Entitlement State

enum EntitlementState: Sendable {
    case free
    case premium(expirationDate: Date?)
}

// MARK: - StoreKit Service Protocol

@MainActor
protocol StoreKitServiceProtocol: AnyObject {
    func loadProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws -> Transaction
    func restorePurchases() async throws
    var currentEntitlements: AsyncStream<EntitlementState> { get }
    var isPremium: Bool { get }
    var isSubscribed: Bool { get }
    var isLifetime: Bool { get }
    var subscriptionExpirationDate: Date? { get }
    var hasWidgetAccess: Bool { get }
    var hasWatchAccess: Bool { get }
    #if DEBUG
    func setDebugPremiumOverride(_ enabled: Bool)
    #endif
}

// MARK: - StoreKit Errors

enum StoreKitServiceError: Error, LocalizedError {
    case productNotFound
    case purchaseFailed
    case userCancelled
    case pending
    case verificationFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound: return L.Error.productNotFound
        case .purchaseFailed: return L.Error.purchaseFailed
        case .userCancelled: return L.Error.purchaseCancelled
        case .pending: return L.Error.purchasePending
        case .verificationFailed: return L.Error.verificationFailed
        case .unknown: return L.Error.unknown
        }
    }
}

// MARK: - StoreKit Service Implementation

@MainActor
final class StoreKitService: StoreKitServiceProtocol {
    
    private static let productIDs: Set<String> = [
        "com.onceagain.drinksomewater.subscription.monthly",
        "com.onceagain.drinksomewater.subscription.yearly",
        "com.onceagain.drinksomewater.premium.lifetime"
    ]
    
    private static let lifetimeProductID = "com.onceagain.drinksomewater.premium.lifetime"
    
    // MARK: - Cache Keys
    private enum CacheKeys {
        static let isPremium = "StoreKitService.isPremium"
        static let expirationDate = "StoreKitService.expirationDate"
        static let isLifetime = "StoreKitService.isLifetime"
    }
    
    private var updateListenerTask: Task<Void, Error>?
    private var entitlementContinuation: AsyncStream<EntitlementState>.Continuation?
    private var _currentEntitlementState: EntitlementState = .free
    
    private func applyEntitlementState(_ state: EntitlementState) {
        _currentEntitlementState = state
        cacheEntitlementState(state)
        entitlementContinuation?.yield(state)
    }
    
    var isPremium: Bool {
        switch _currentEntitlementState {
        case .free:
            return false
        case .premium(let expirationDate):
            return expirationDate.map { $0 > Date() } ?? true
        }
    }
    
    var isSubscribed: Bool { isPremium }
    var isLifetime: Bool {
        if case .premium(expirationDate: nil) = _currentEntitlementState { return true }
        return false
    }
    var subscriptionExpirationDate: Date? {
        if case .premium(let expDate) = _currentEntitlementState { return expDate }
        return nil
    }
    var hasWidgetAccess: Bool { isSubscribed }
    var hasWatchAccess: Bool { isSubscribed }
    
    lazy var currentEntitlements: AsyncStream<EntitlementState> = {
        AsyncStream { [weak self] continuation in
            self?.entitlementContinuation = continuation
            if let state = self?._currentEntitlementState {
                continuation.yield(state)
            }
            continuation.onTermination = { _ in }
        }
    }()
    
    init() {
        #if DEBUG
        _currentEntitlementState = .premium(expirationDate: nil)
        #else
        if Environment.isTestFlight {
            _currentEntitlementState = .premium(expirationDate: nil)
        } else {
            _currentEntitlementState = Self.loadCachedEntitlementState()
            updateListenerTask = listenForTransactions()
            Task {
                await updateEntitlementState()
            }
        }
        #endif
        
        cacheEntitlementState(_currentEntitlementState)
    }
    
    #if DEBUG
    func setDebugPremiumOverride(_ enabled: Bool) {
        applyEntitlementState(enabled ? .premium(expirationDate: nil) : .free)
    }
    #endif
    
    deinit {
        updateListenerTask?.cancel()
        entitlementContinuation?.finish()
    }
    
    func loadProducts() async throws -> [Product] {
        let products = try await Product.products(for: Self.productIDs)
        return products.sorted { $0.price < $1.price }
    }
    
    func purchase(_ product: Product) async throws -> Transaction {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try Self.checkVerified(verification)
            await updateEntitlementState()
            await transaction.finish()
            return transaction
            
        case .userCancelled:
            throw StoreKitServiceError.userCancelled
            
        case .pending:
            throw StoreKitServiceError.pending
            
        @unknown default:
            throw StoreKitServiceError.unknown
        }
    }
    
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updateEntitlementState()
    }
    
    // MARK: - Private
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let verifiedTransaction = Self.verifyTransaction(result) else { continue }
                await self?.handleTransactionUpdate()
                await verifiedTransaction.finish()
            }
        }
    }
    
    private func handleTransactionUpdate() async {
        await updateEntitlementState()
    }
    
    private nonisolated static func verifyTransaction(_ result: VerificationResult<Transaction>) -> Transaction? {
        switch result {
        case .unverified:
            return nil
        case .verified(let transaction):
            return transaction
        }
    }
    
    private nonisolated static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitServiceError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    private func updateEntitlementState() async {
        #if !DEBUG
        guard !Environment.isTestFlight else { return }
        
        var hasLifetime = false
        var subscriptionState: EntitlementState = .free
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard Self.productIDs.contains(transaction.productID) else { continue }
            guard transaction.revocationDate == nil else { continue }
            
            switch transaction.productType {
            case .nonConsumable:
                hasLifetime = true
                
            case .autoRenewable:
                if let subscriptionStatus = await getSubscriptionStatus(for: transaction.productID) {
                    switch subscriptionStatus.state {
                    case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
                        let expDate = Self.extractExpirationDate(from: subscriptionStatus) ?? transaction.expirationDate
                        guard let expDate else { break }
                        subscriptionState = .premium(expirationDate: expDate)
                    case .expired, .revoked:
                        break
                    default:
                        break
                    }
                }
                
            default:
                break
            }
        }
        
        let newState: EntitlementState = hasLifetime ? .premium(expirationDate: nil) : subscriptionState
        applyEntitlementState(newState)
        #endif
    }
    
    private static func extractExpirationDate(from status: Product.SubscriptionInfo.Status) -> Date? {
        guard case .verified(let transaction) = status.transaction else {
            return nil
        }
        return transaction.expirationDate
    }
    
    private func getSubscriptionStatus(for productID: String) async -> Product.SubscriptionInfo.Status? {
        do {
            let products = try await Product.products(for: [productID])
            guard let product = products.first,
                  let subscription = product.subscription else {
                return nil
            }
            
            let statuses = try await subscription.status
            
            for status in statuses {
                if let transaction = try? status.transaction.payloadValue,
                   transaction.productID == productID {
                    return status
                }
            }
            
            return statuses.first
        } catch {
            return nil
        }
    }
    
    // MARK: - Cache
    
    private func cacheEntitlementState(_ state: EntitlementState) {
        switch state {
        case .free:
            UserDefaults.standard.set(false, forKey: CacheKeys.isPremium)
            UserDefaults.standard.set(false, forKey: CacheKeys.isLifetime)
            UserDefaults.standard.removeObject(forKey: CacheKeys.expirationDate)
            
            let appGroupDefaults = UserDefaults(suiteName: "group.com.onceagain.DrinkSomeWater")
            appGroupDefaults?.set(false, forKey: "shared_is_subscribed")
            appGroupDefaults?.set(false, forKey: "shared_is_lifetime")
            appGroupDefaults?.removeObject(forKey: "shared_subscription_expiration")
            appGroupDefaults?.synchronize()
            WidgetCenter.shared.reloadAllTimelines()
            
        case .premium(let expirationDate):
            UserDefaults.standard.set(true, forKey: CacheKeys.isPremium)
            UserDefaults.standard.set(expirationDate == nil, forKey: CacheKeys.isLifetime)
            UserDefaults.standard.set(expirationDate, forKey: CacheKeys.expirationDate)
            
            let appGroupDefaults = UserDefaults(suiteName: "group.com.onceagain.DrinkSomeWater")
            appGroupDefaults?.set(true, forKey: "shared_is_subscribed")
            appGroupDefaults?.set(expirationDate == nil, forKey: "shared_is_lifetime")
            appGroupDefaults?.set(expirationDate, forKey: "shared_subscription_expiration")
            appGroupDefaults?.synchronize()
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    private nonisolated static func loadCachedEntitlementState() -> EntitlementState {
        let isPremium = UserDefaults.standard.bool(forKey: CacheKeys.isPremium)
        guard isPremium else { return .free }
        
        let isLifetime = UserDefaults.standard.bool(forKey: CacheKeys.isLifetime)
        if isLifetime {
            return .premium(expirationDate: nil)
        }
        
        let expirationDate = UserDefaults.standard.object(forKey: CacheKeys.expirationDate) as? Date
        if let expDate = expirationDate, expDate > Date() {
            return .premium(expirationDate: expDate)
        }
        
        return .free
    }
}
