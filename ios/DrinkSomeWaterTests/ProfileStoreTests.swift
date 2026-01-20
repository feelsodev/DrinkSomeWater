import Testing
import Foundation
@testable import DrinkSomeWater

@Suite("ProfileStore")
@MainActor
struct ProfileStoreTests {
    
    // MARK: - Load Tests
    
    @Test func loadFetchesProfileFromUserDefaults() async {
        let mockUserDefaults = MockUserDefaultsService()
        mockUserDefaults.set(value: 75.0, forkey: .userWeight)
        mockUserDefaults.set(value: false, forkey: .useHealthKitWeight)
        
        let provider = MockServiceProvider(userDefaultsService: mockUserDefaults)
        let store = ProfileStore(provider: provider)
        
        await store.send(.load)
        
        #expect(store.profile.weight == 75.0)
        #expect(store.profile.useHealthKitWeight == false)
    }
    
    @Test func loadUsesDefaultWhenNoStoredProfile() async {
        let mockUserDefaults = MockUserDefaultsService()
        let provider = MockServiceProvider(userDefaultsService: mockUserDefaults)
        let store = ProfileStore(provider: provider)
        
        await store.send(.load)
        
        #expect(store.profile.weight == 65.0)
        #expect(store.profile.useHealthKitWeight == false)
    }
    
    // MARK: - Update Weight Tests
    
    @Test func updateWeightChangesProfileWeight() async {
        let mockUserDefaults = MockUserDefaultsService()
        
        let provider = MockServiceProvider(userDefaultsService: mockUserDefaults)
        let store = ProfileStore(provider: provider)
        
        await store.send(.load)
        await store.send(.updateWeight(80.0))
        
        #expect(store.profile.weight == 80.0)
    }
    
    @Test func updateWeightPersistsToUserDefaults() async {
        let mockUserDefaults = MockUserDefaultsService()
        
        let provider = MockServiceProvider(userDefaultsService: mockUserDefaults)
        let store = ProfileStore(provider: provider)
        
        await store.send(.load)
        await store.send(.updateWeight(85.0))
        
        #expect(mockUserDefaults.value(forkey: .userWeight) == 85.0)
    }
    
    // MARK: - Recommended Intake Tests
    
    @Test func recommendedIntakeCalculatesCorrectly() async {
        let mockUserDefaults = MockUserDefaultsService()
        mockUserDefaults.set(value: 70.0, forkey: .userWeight)
        
        let provider = MockServiceProvider(userDefaultsService: mockUserDefaults)
        let store = ProfileStore(provider: provider)
        
        await store.send(.load)
        
        // 70kg * 33ml = 2310ml
        #expect(store.recommendedIntake == 2310)
    }
    
    @Test func recommendedIntakeUpdatesWithWeight() async {
        let mockUserDefaults = MockUserDefaultsService()
        
        let provider = MockServiceProvider(userDefaultsService: mockUserDefaults)
        let store = ProfileStore(provider: provider)
        
        await store.send(.load)
        await store.send(.updateWeight(80.0))
        
        // 80kg * 33ml = 2640ml
        #expect(store.recommendedIntake == 2640)
    }
    
    // MARK: - Apply Recommended Goal Tests
    
    @Test func applyRecommendedGoalUpdatesWaterServiceGoal() async {
        let mockUserDefaults = MockUserDefaultsService()
        mockUserDefaults.set(value: 70.0, forkey: .userWeight)
        
        let mockWaterService = MockWaterService()
        mockWaterService.goal = 2000
        
        let provider = MockServiceProvider(
            userDefaultsService: mockUserDefaults,
            waterService: mockWaterService
        )
        let store = ProfileStore(provider: provider)
        
        await store.send(.load)
        await store.send(.applyRecommendedGoal)
        
        #expect(mockWaterService.goal == 2310)
    }
    
    // MARK: - Toggle HealthKit Weight Tests
    
    @Test func toggleHealthKitWeightUpdatesProfile() async {
        let mockUserDefaults = MockUserDefaultsService()
        
        let provider = MockServiceProvider(userDefaultsService: mockUserDefaults)
        let store = ProfileStore(provider: provider)
        
        await store.send(.load)
        #expect(store.profile.useHealthKitWeight == false)
        
        await store.send(.toggleHealthKitWeight(true))
        #expect(store.profile.useHealthKitWeight == true)
    }
    
    @Test func toggleHealthKitWeightPersistsToUserDefaults() async {
        let mockUserDefaults = MockUserDefaultsService()
        
        let provider = MockServiceProvider(userDefaultsService: mockUserDefaults)
        let store = ProfileStore(provider: provider)
        
        await store.send(.load)
        await store.send(.toggleHealthKitWeight(true))
        
        #expect(mockUserDefaults.value(forkey: .useHealthKitWeight) == true)
    }
    
    // MARK: - HealthKit Sync Tests
    
    @Test func syncWeightFromHealthKitUpdatesProfile() async {
        let mockHealthKitService = MockHealthKitService()
        let mockUserDefaults = MockUserDefaultsService()
        let provider = MockServiceProvider(
            userDefaultsService: mockUserDefaults,
            healthKitService: mockHealthKitService
        )
        let store = ProfileStore(provider: provider)
        
        await store.send(.load)
        await store.send(.syncWeightFromHealthKit)
        
        #expect(store.profile.weight == 65.0)
    }
    
    // MARK: - HealthKit Availability Tests
    
    @Test func isHealthKitAvailableReflectsServiceState() async {
        let mockHealthKitService = MockHealthKitService()
        let provider = MockServiceProvider(healthKitService: mockHealthKitService)
        let store = ProfileStore(provider: provider)
        
        #expect(store.isHealthKitAvailable == false)
    }
    
    // MARK: - Request HealthKit Permission Tests
    
    @Test func requestHealthKitPermissionUpdatesAuthorizationState() async {
        let mockHealthKitService = MockHealthKitService()
        let provider = MockServiceProvider(healthKitService: mockHealthKitService)
        let store = ProfileStore(provider: provider)
        
        await store.send(.requestHealthKitPermission)
        
        #expect(store.isHealthKitAuthorized == false)
    }
}
