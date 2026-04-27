import Foundation
import Observation
import StoreKit
import Analytics

enum PremiumProductKind: Int, CaseIterable, Equatable, Hashable, Sendable {
    case monthly
    case yearly
    case lifetime
    
    var productID: String {
        switch self {
        case .monthly:
            return "com.onceagain.drinksomewater.subscription.monthly"
        case .yearly:
            return "com.onceagain.drinksomewater.subscription.yearly"
        case .lifetime:
            return "com.onceagain.drinksomewater.premium.lifetime"
        }
    }
    
    init?(productID: String) {
        guard let kind = Self.allCases.first(where: { $0.productID == productID }) else {
            return nil
        }
        self = kind
    }
}

private final class EntitlementObserver {
    private let task: Task<Void, Never>
    
    @MainActor
    init(storeKitService: StoreKitServiceProtocol, onChange: @escaping @MainActor @Sendable () async -> Void) {
        task = Task { @MainActor in
            for await _ in storeKitService.currentEntitlements {
                await onChange()
            }
        }
    }
    
    deinit {
        task.cancel()
    }
}

@MainActor
@Observable
final class PremiumStore {
    enum Action {
        case loadProducts
        case purchase(Product)
        case restore
        case refreshEntitlements
    }
    
    var products: [Product] = []
    var isPremium: Bool = false
    var isSubscribed: Bool = false
    var isLoading: Bool = false
    var error: Error?
    var restoreSuccess: Bool = false
    var hasLoadedProducts: Bool = false
    
    private let storeKitService: StoreKitServiceProtocol
    private var entitlementObserver: EntitlementObserver?
    
    init(storeKitService: StoreKitServiceProtocol) {
        self.storeKitService = storeKitService
        Task {
            await send(.refreshEntitlements)
        }
        entitlementObserver = EntitlementObserver(storeKitService: storeKitService) { [weak self] in
            await self?.send(.refreshEntitlements)
        }
    }
    
    func send(_ action: Action) async {
        switch action {
        case .loadProducts:
            isLoading = true
            error = nil
            defer { isLoading = false }
            
            do {
                products = Self.sortedPremiumProducts(try await storeKitService.loadProducts())
                hasLoadedProducts = true
            } catch {
                self.error = error
            }
            
        case .purchase(let product):
            isLoading = true
            error = nil
            defer { isLoading = false }
            
            let price = NSDecimalNumber(decimal: product.price).doubleValue
            Analytics.shared.log(.purchaseStarted(productId: product.id, price: price))
            
            do {
                _ = try await storeKitService.purchase(product)
                isPremium = true
                isSubscribed = true
                Analytics.shared.log(.purchaseCompleted(
                    productId: product.id,
                    price: price,
                    currency: product.priceFormatStyle.currencyCode
                ))
                Analytics.shared.setPremiumStatus(Self.premiumStatus(for: product.id))
            } catch {
                self.error = error
                let errorCode = (error as? StoreKitServiceError)?.errorCode ?? "unknown"
                Analytics.shared.log(.purchaseFailed(productId: product.id, errorCode: errorCode))
            }
            
        case .restore:
            isLoading = true
            error = nil
            restoreSuccess = false
            defer { isLoading = false }
            
            do {
                try await storeKitService.restorePurchases()
                await send(.refreshEntitlements)
                restoreSuccess = isPremium
            } catch {
                self.error = error
            }
            
        case .refreshEntitlements:
            let wasPremium = isPremium
            isPremium = storeKitService.isPremium
            isSubscribed = storeKitService.isSubscribed
            
            if wasPremium != isPremium {
                Analytics.shared.setPremiumStatus(isPremium ? .legacyLifetime : .free)
            }
        }
    }
    
    private static func premiumStatus(for productId: String) -> PremiumStatus {
        if productId.contains("monthly") { return .subscriberMonthly }
        if productId.contains("yearly") { return .subscriberYearly }
        if productId.contains("lifetime") { return .legacyLifetime }
        return .free
    }
    
    static func premiumProductKind(for productID: String) -> PremiumProductKind? {
        PremiumProductKind(productID: productID)
    }
    
    static func premiumProductSortPriority(for productID: String) -> Int {
        premiumProductKind(for: productID)?.rawValue ?? PremiumProductKind.allCases.count
    }
    
    static func hasCompletePremiumProductCatalog(productIDs: [String]) -> Bool {
        let loadedKinds = Set(productIDs.compactMap(PremiumProductKind.init(productID:)))
        return loadedKinds == Set(PremiumProductKind.allCases)
    }
    
    static func sortedPremiumProducts(_ products: [Product]) -> [Product] {
        products.sorted { lhs, rhs in
            let lhsPriority = premiumProductSortPriority(for: lhs.id)
            let rhsPriority = premiumProductSortPriority(for: rhs.id)
            
            if lhsPriority != rhsPriority {
                return lhsPriority < rhsPriority
            }
            
            return lhs.price < rhs.price
        }
    }
}

// MARK: - StoreKitServiceError Extension

extension StoreKitServiceError {
    var errorCode: String {
        switch self {
        case .productNotFound: return "product_not_found"
        case .purchaseFailed: return "purchase_failed"
        case .userCancelled: return "user_cancelled"
        case .pending: return "pending"
        case .verificationFailed: return "verification_failed"
        case .unknown: return "unknown"
        }
    }
}
