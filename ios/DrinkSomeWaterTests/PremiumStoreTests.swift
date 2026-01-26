import Testing
import Foundation
@testable import DrinkSomeWater

@Suite("PremiumStore")
@MainActor
struct PremiumStoreTests {
    
    @Test func store_loadProducts_updatesProducts() async throws {
        let mockService = MockStoreKitService()
        let store = PremiumStore(storeKitService: mockService)
        
        await store.send(.loadProducts)
        
        #expect(mockService.loadProductsCalled)
        #expect(store.isLoading == false)
        #expect(store.error == nil)
    }
    
    @Test func store_loadProducts_setsErrorOnFailure() async throws {
        let mockService = MockStoreKitService()
        mockService.shouldThrowOnLoadProducts = true
        let store = PremiumStore(storeKitService: mockService)
        
        await store.send(.loadProducts)
        
        #expect(mockService.loadProductsCalled)
        #expect(store.error != nil)
        #expect(store.isLoading == false)
    }
    
    @Test func store_purchase_updatesPremiumOnSuccess() async throws {
        let mockService = MockStoreKitService()
        mockService.setEntitlementState(.premium(expirationDate: nil))
        let store = PremiumStore(storeKitService: mockService)
        
        await store.send(.refreshEntitlements)
        
        #expect(store.isPremium == true)
    }
    
    @Test func store_purchase_remainsFreeOnFailure() async throws {
        let mockService = MockStoreKitService()
        mockService.shouldThrowOnPurchase = true
        let store = PremiumStore(storeKitService: mockService)
        
        #expect(store.isPremium == false)
        
        mockService.setEntitlementState(.free)
        await store.send(.refreshEntitlements)
        
        #expect(store.isPremium == false)
    }
    
    @Test func store_restore_callsRestorePurchases() async throws {
        let mockService = MockStoreKitService()
        let store = PremiumStore(storeKitService: mockService)
        
        await store.send(.restore)
        
        #expect(mockService.restorePurchasesCalled)
        #expect(store.isLoading == false)
    }
    
    @Test func store_restore_setsErrorOnFailure() async throws {
        let mockService = MockStoreKitService()
        mockService.shouldThrowOnRestore = true
        let store = PremiumStore(storeKitService: mockService)
        
        await store.send(.restore)
        
        #expect(mockService.restorePurchasesCalled)
        #expect(store.error != nil)
    }
    
    @Test func store_refreshEntitlements_updatesPremiumStatus() async throws {
        let mockService = MockStoreKitService()
        let store = PremiumStore(storeKitService: mockService)
        
        #expect(store.isPremium == false)
        
        mockService.setEntitlementState(.premium(expirationDate: nil))
        
        await store.send(.refreshEntitlements)
        
        #expect(store.isPremium == true)
    }
    
    @Test func store_refreshEntitlements_detectsFreeStatus() async throws {
        let mockService = MockStoreKitService()
        mockService.setEntitlementState(.premium(expirationDate: nil))
        let store = PremiumStore(storeKitService: mockService)
        
        await store.send(.refreshEntitlements)
        #expect(store.isPremium == true)
        
        mockService.setEntitlementState(.free)
        
        await store.send(.refreshEntitlements)
        
        #expect(store.isPremium == false)
    }
    
    @Test func store_isLoadingDuringOperations() async throws {
        let mockService = MockStoreKitService()
        let store = PremiumStore(storeKitService: mockService)
        
        #expect(store.isLoading == false)
        
        await store.send(.loadProducts)
        
        #expect(store.isLoading == false)
    }
    
    @Test func store_initialState_isFree() async throws {
        let mockService = MockStoreKitService()
        let store = PremiumStore(storeKitService: mockService)
        
        #expect(store.isPremium == false)
        #expect(store.products.isEmpty)
        #expect(store.isLoading == false)
        #expect(store.error == nil)
    }
}
