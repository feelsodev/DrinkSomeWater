import Foundation
import StoreKit
@testable import DrinkSomeWater

@MainActor
final class MockStoreKitService: StoreKitServiceProtocol {
    var mockProducts: [Product] = []
    var mockEntitlementState: EntitlementState = .free
    var mockIsPremium: Bool = false
    var mockIsSubscribed: Bool = false
    var mockHasWidgetAccess: Bool = false
    var mockHasWatchAccess: Bool = false
    var mockIsLifetime: Bool = false
    var mockSubscriptionExpirationDate: Date?
    
    var loadProductsCalled = false
    var purchaseCalled = false
    var restorePurchasesCalled = false
    var lastPurchasedProduct: Product?
    
    var shouldThrowOnLoadProducts = false
    var shouldThrowOnPurchase = false
    var shouldThrowOnRestore = false
    
    var currentEntitlements: AsyncStream<EntitlementState> {
        AsyncStream { continuation in
            continuation.yield(mockEntitlementState)
        }
    }
    
    var isPremium: Bool { mockIsPremium }
    var isSubscribed: Bool { mockIsSubscribed }
    var isLifetime: Bool { mockIsLifetime }
    var subscriptionExpirationDate: Date? { mockSubscriptionExpirationDate }
    var hasWidgetAccess: Bool { mockHasWidgetAccess }
    var hasWatchAccess: Bool { mockHasWatchAccess }
    
    func loadProducts() async throws -> [Product] {
        loadProductsCalled = true
        
        if shouldThrowOnLoadProducts {
            throw StoreKitError.networkError
        }
        
        return mockProducts
    }
    
    func purchase(_ product: Product) async throws -> Transaction {
        purchaseCalled = true
        lastPurchasedProduct = product
        
        if shouldThrowOnPurchase {
            throw StoreKitError.purchaseFailed
        }
        
        mockIsPremium = true
        mockIsSubscribed = true
        mockHasWidgetAccess = true
        mockHasWatchAccess = true
        mockEntitlementState = .premium(expirationDate: nil)
        
        return try await fetchMockTransaction()
    }
    
    func restorePurchases() async throws {
        restorePurchasesCalled = true
        
        if shouldThrowOnRestore {
            throw StoreKitError.restoreFailed
        }
    }
    
    #if DEBUG
    func setDebugPremiumOverride(_ enabled: Bool) {
        setEntitlementState(enabled ? .premium(expirationDate: nil) : .free)
    }
    #endif
    
    func setEntitlementState(_ state: EntitlementState) {
        mockEntitlementState = state
        switch state {
        case .free:
            mockIsPremium = false
            mockIsSubscribed = false
            mockHasWidgetAccess = false
            mockHasWatchAccess = false
        case .premium:
            mockIsPremium = true
            mockIsSubscribed = true
            mockHasWidgetAccess = true
            mockHasWatchAccess = true
        }
    }
    
    func reset() {
        mockProducts = []
        mockEntitlementState = .free
        mockIsPremium = false
        mockIsSubscribed = false
        mockHasWidgetAccess = false
        mockHasWatchAccess = false
        mockIsLifetime = false
        mockSubscriptionExpirationDate = nil
        loadProductsCalled = false
        purchaseCalled = false
        restorePurchasesCalled = false
        lastPurchasedProduct = nil
        shouldThrowOnLoadProducts = false
        shouldThrowOnPurchase = false
        shouldThrowOnRestore = false
    }
    
    private func fetchMockTransaction() async throws -> Transaction {
        for await result in Transaction.all {
            if case .verified(let transaction) = result {
                return transaction
            }
        }
        throw StoreKitError.transactionNotFound
    }
}

enum StoreKitError: Error {
    case networkError
    case purchaseFailed
    case restoreFailed
    case transactionNotFound
}
