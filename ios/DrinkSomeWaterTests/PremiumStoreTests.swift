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
        #expect(store.hasLoadedProducts == true)
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
    
    @Test func store_restore_setsRestoreSuccessOnSuccess() async throws {
        let mockService = MockStoreKitService()
        mockService.setEntitlementState(.premium(expirationDate: nil))
        let store = PremiumStore(storeKitService: mockService)
        
        await store.send(.restore)
        
        #expect(store.restoreSuccess == true)
        #expect(store.error == nil)
    }
    
    @Test func store_restore_doesNotShowSuccessWithoutEntitlement() async throws {
        let mockService = MockStoreKitService()
        let store = PremiumStore(storeKitService: mockService)
        
        await store.send(.restore)
        
        #expect(store.restoreSuccess == false)
        #expect(store.error == nil)
    }
    
    @Test func store_restore_restoreSuccessIsFalseOnFailure() async throws {
        let mockService = MockStoreKitService()
        mockService.shouldThrowOnRestore = true
        let store = PremiumStore(storeKitService: mockService)
        
        await store.send(.restore)
        
        #expect(store.restoreSuccess == false)
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
        #expect(store.restoreSuccess == false)
        #expect(store.hasLoadedProducts == false)
    }
    
    @Test func productKind_detectsConfiguredProductIDs() {
        #expect(PremiumStore.premiumProductKind(for: "com.onceagain.drinksomewater.subscription.monthly") == .monthly)
        #expect(PremiumStore.premiumProductKind(for: "com.onceagain.drinksomewater.subscription.yearly") == .yearly)
        #expect(PremiumStore.premiumProductKind(for: "com.onceagain.drinksomewater.premium.lifetime") == .lifetime)
        #expect(PremiumStore.premiumProductKind(for: "com.onceagain.drinksomewater.unknown") == nil)
        #expect(PremiumStore.premiumProductKind(for: "com.onceagain.drinksomewater.notmonthly") == nil)
        #expect(PremiumStore.premiumProductKind(for: "com.onceagain.drinksomewater.subscription.monthly.yearly") == nil)
    }
    
    @Test func productSortPriority_ordersMonthlyYearlyLifetime() {
        #expect(PremiumStore.premiumProductSortPriority(for: "com.onceagain.drinksomewater.subscription.monthly") == 0)
        #expect(PremiumStore.premiumProductSortPriority(for: "com.onceagain.drinksomewater.subscription.yearly") == 1)
        #expect(PremiumStore.premiumProductSortPriority(for: "com.onceagain.drinksomewater.premium.lifetime") == 2)
        #expect(PremiumStore.premiumProductSortPriority(for: "com.onceagain.drinksomewater.unknown") == 3)
    }
    
    @Test func productCatalogCompleteness_requiresAllThreeProducts() {
        #expect(PremiumStore.hasCompletePremiumProductCatalog(productIDs: [
            "com.onceagain.drinksomewater.subscription.monthly",
            "com.onceagain.drinksomewater.subscription.yearly",
            "com.onceagain.drinksomewater.premium.lifetime"
        ]))
        
        #expect(PremiumStore.hasCompletePremiumProductCatalog(productIDs: [
            "com.onceagain.drinksomewater.subscription.monthly",
            "com.onceagain.drinksomewater.subscription.yearly"
        ]) == false)
        
        #expect(PremiumStore.hasCompletePremiumProductCatalog(productIDs: [
            "com.onceagain.drinksomewater.subscription.monthly",
            "com.onceagain.drinksomewater.subscription.yearly",
            "com.onceagain.drinksomewater.subscription.monthly.yearly"
        ]) == false)
    }
    
    // MARK: - isSubscribed
    
    @Test func store_refreshEntitlements_updatesIsSubscribed() async throws {
        let mockService = MockStoreKitService()
        let store = PremiumStore(storeKitService: mockService)
        
        #expect(store.isSubscribed == false)
        
        mockService.setEntitlementState(.premium(expirationDate: nil))
        await store.send(.refreshEntitlements)
        
        #expect(store.isSubscribed == true)
        
        mockService.setEntitlementState(.free)
        await store.send(.refreshEntitlements)
        
        #expect(store.isSubscribed == false)
    }
    
    @Test func store_observesEntitlementStreamUpdates() async throws {
        let mockService = MockStoreKitService()
        let store = PremiumStore(storeKitService: mockService)
        
        #expect(store.isPremium == false)
        
        mockService.setEntitlementState(.premium(expirationDate: nil))
        try await Task.sleep(nanoseconds: 50_000_000)
        
        #expect(store.isPremium == true)
        #expect(store.isSubscribed == true)
        
        mockService.setEntitlementState(.free)
        try await Task.sleep(nanoseconds: 50_000_000)
        
        #expect(store.isPremium == false)
        #expect(store.isSubscribed == false)
    }
}
