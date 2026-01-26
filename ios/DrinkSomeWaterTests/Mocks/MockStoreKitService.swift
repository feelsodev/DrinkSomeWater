import Foundation
import StoreKit
@testable import DrinkSomeWater

@MainActor
final class MockStoreKitService: StoreKitServiceProtocol {
    var mockProducts: [Product] = []
    var mockEntitlementState: EntitlementState = .free
    var mockIsPremium: Bool = false
    
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
    
    var isPremium: Bool {
        mockIsPremium
    }
    
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
        mockEntitlementState = .premium(expirationDate: nil)
        
        return try await fetchMockTransaction()
    }
    
    func restorePurchases() async throws {
        restorePurchasesCalled = true
        
        if shouldThrowOnRestore {
            throw StoreKitError.restoreFailed
        }
    }
    
    func setEntitlementState(_ state: EntitlementState) {
        mockEntitlementState = state
        switch state {
        case .free:
            mockIsPremium = false
        case .premium:
            mockIsPremium = true
        }
    }
    
    func reset() {
        mockProducts = []
        mockEntitlementState = .free
        mockIsPremium = false
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
