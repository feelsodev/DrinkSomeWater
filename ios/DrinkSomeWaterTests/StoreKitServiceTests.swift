import Testing
import Foundation
import StoreKit
@testable import DrinkSomeWater

@Suite("StoreKitService")
@MainActor
struct StoreKitServiceTests {
    
    @Test func mockService_loadProducts_callsLoadProducts() async throws {
        let mock = MockStoreKitService()
        
        _ = try await mock.loadProducts()
        
        #expect(mock.loadProductsCalled)
    }
    
    @Test func mockService_loadProducts_throwsWhenConfigured() async throws {
        let mock = MockStoreKitService()
        mock.shouldThrowOnLoadProducts = true
        
        do {
            _ = try await mock.loadProducts()
            #expect(Bool(false), "Should have thrown")
        } catch is StoreKitError {
            #expect(true)
        }
        
        #expect(mock.loadProductsCalled)
    }
    
    @Test func mockService_restorePurchases_succeeds() async throws {
        let mock = MockStoreKitService()
        
        try await mock.restorePurchases()
        
        #expect(mock.restorePurchasesCalled)
    }
    
    @Test func mockService_restorePurchases_throwsWhenConfigured() async throws {
        let mock = MockStoreKitService()
        mock.shouldThrowOnRestore = true
        
        do {
            try await mock.restorePurchases()
            #expect(Bool(false), "Should have thrown")
        } catch is StoreKitError {
            #expect(true)
        }
        
        #expect(mock.restorePurchasesCalled)
    }
    
    @Test func mockService_isPremium_reflectsEntitlementState() async throws {
        let mock = MockStoreKitService()
        
        #expect(mock.isPremium == false)
        
        mock.setEntitlementState(.premium(expirationDate: nil))
        #expect(mock.isPremium == true)
        
        mock.setEntitlementState(.free)
        #expect(mock.isPremium == false)
    }
    
    @Test func mockService_currentEntitlements_streamsState() async throws {
        let mock = MockStoreKitService()
        mock.mockEntitlementState = .premium(expirationDate: nil)
        
        var entitlements: [EntitlementState] = []
        for await state in mock.currentEntitlements {
            entitlements.append(state)
            break
        }
        
        #expect(entitlements.count == 1)
        if case .premium = entitlements.first {
            #expect(true)
        } else {
            #expect(Bool(false), "Expected premium state")
        }
    }
    
    @Test func mockService_reset_clearsAllState() async throws {
        let mock = MockStoreKitService()
        
        mock.mockIsPremium = true
        mock.loadProductsCalled = true
        mock.purchaseCalled = true
        mock.shouldThrowOnLoadProducts = true
        
        mock.reset()
        
        #expect(mock.mockProducts.isEmpty)
        #expect(mock.mockIsPremium == false)
        #expect(mock.loadProductsCalled == false)
        #expect(mock.purchaseCalled == false)
        #expect(mock.shouldThrowOnLoadProducts == false)
    }
    
    @Test func mockService_entitlementState_withExpirationDate() async throws {
        let mock = MockStoreKitService()
        let expirationDate = Date().addingTimeInterval(86400 * 30)
        
        mock.setEntitlementState(.premium(expirationDate: expirationDate))
        
        #expect(mock.isPremium == true)
        
        if case .premium(let expiration) = mock.mockEntitlementState {
            #expect(expiration == expirationDate)
        } else {
            #expect(Bool(false), "Expected premium state with expiration")
        }
    }
    
    @Test func entitlementState_free_isPremiumFalse() {
        let state = EntitlementState.free
        
        switch state {
        case .free:
            #expect(true)
        case .premium:
            #expect(Bool(false), "Expected free state")
        }
    }
    
    @Test func entitlementState_premium_withoutExpiration() {
        let state = EntitlementState.premium(expirationDate: nil)
        
        switch state {
        case .free:
            #expect(Bool(false), "Expected premium state")
        case .premium(let expiration):
            #expect(expiration == nil)
        }
    }
    
    // MARK: - isSubscribed / hasWidgetAccess / hasWatchAccess
    
    @Test func mockService_isSubscribed_reflectsEntitlementState() {
        let mock = MockStoreKitService()
        
        #expect(mock.isSubscribed == false)
        #expect(mock.hasWidgetAccess == false)
        #expect(mock.hasWatchAccess == false)
        
        mock.setEntitlementState(.premium(expirationDate: nil))
        
        #expect(mock.isSubscribed == true)
        #expect(mock.hasWidgetAccess == true)
        #expect(mock.hasWatchAccess == true)
        
        mock.setEntitlementState(.free)
        
        #expect(mock.isSubscribed == false)
        #expect(mock.hasWidgetAccess == false)
        #expect(mock.hasWatchAccess == false)
    }
    
    @Test func mockService_reset_clearsSubscriptionProperties() {
        let mock = MockStoreKitService()
        
        mock.setEntitlementState(.premium(expirationDate: nil))
        #expect(mock.isSubscribed == true)
        
        mock.reset()
        
        #expect(mock.isSubscribed == false)
        #expect(mock.hasWidgetAccess == false)
        #expect(mock.hasWatchAccess == false)
    }
}
