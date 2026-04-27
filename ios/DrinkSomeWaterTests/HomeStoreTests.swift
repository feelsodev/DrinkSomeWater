import Testing
import Foundation
@testable import DrinkSomeWater

@Suite("HomeStore")
@MainActor
struct HomeStoreTests {
    
    // MARK: - Refresh Tests
    
    @Test func refreshLoadsTodayWater() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 500, isSuccess: false, goal: 2000)
        ]
        mockWaterService.goal = 2000
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshGoal)
        await store.send(.refresh)
        
        #expect(store.ml == 500)
        #expect(store.total == 2000)
        #expect(store.progress == 0.25)
    }
    
    @Test func refreshGoalUpdatesTotal() async {
        let mockWaterService = MockWaterService()
        mockWaterService.goal = 2500
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshGoal)
        
        #expect(store.total == 2500)
    }
    
    // MARK: - Add Water Tests
    
    @Test func addWaterIncreasesAmount() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 0, isSuccess: false, goal: 2000)
        ]
        mockWaterService.goal = 2000
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshGoal)
        await store.send(.refresh)
        await store.send(.addWater(300))
        
        #expect(store.ml == 300)
    }
    
    @Test func addWaterMultipleTimes() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 0, isSuccess: false, goal: 2000)
        ]
        mockWaterService.goal = 2000
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshGoal)
        await store.send(.refresh)
        await store.send(.addWater(200))
        await store.send(.addWater(300))
        await store.send(.addWater(500))
        
        #expect(store.ml == 1000)
        #expect(store.progress == 0.5)
    }
    
    // MARK: - Subtract Water Tests
    
    @Test func subtractWaterDecreasesAmount() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 500, isSuccess: false, goal: 2000)
        ]
        mockWaterService.goal = 2000
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshGoal)
        await store.send(.refresh)
        await store.send(.subtractWater(200))
        
        #expect(store.ml == 300)
    }
    
    @Test func subtractWaterDoesNotGoBelowZero() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 100, isSuccess: false, goal: 2000)
        ]
        mockWaterService.goal = 2000
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshGoal)
        await store.send(.refresh)
        await store.send(.subtractWater(200))
        
        #expect(store.ml >= 0)
    }
    
    // MARK: - Reset Tests
    
    @Test func resetTodayWaterClearsAmount() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1500, isSuccess: false, goal: 2000)
        ]
        mockWaterService.goal = 2000
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshGoal)
        await store.send(.refresh)
        
        #expect(store.ml == 1500)
        
        await store.send(.resetTodayWater)
        
        #expect(store.ml == 0)
    }
    
    // MARK: - Computed Properties Tests
    
    @Test func remainingMlCalculatesCorrectly() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1200, isSuccess: false, goal: 2000)
        ]
        mockWaterService.goal = 2000
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshGoal)
        await store.send(.refresh)
        
        #expect(store.remainingMl == 800)
    }
    
    @Test func remainingMlIsZeroWhenGoalAchieved() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2500, isSuccess: true, goal: 2000)
        ]
        mockWaterService.goal = 2000
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshGoal)
        await store.send(.refresh)
        
        #expect(store.remainingMl == 0)
    }
    
    @Test func remainingCupsCalculatesCorrectly() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1000, isSuccess: false, goal: 2000)
        ]
        mockWaterService.goal = 2000
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshGoal)
        await store.send(.refresh)
        
        #expect(store.remainingCups == 4)
    }
    
    // MARK: - Quick Buttons Tests
    
    @Test func refreshQuickButtonsLoadsFromUserDefaults() async {
        let mockUserDefaults = MockUserDefaultsService()
        mockUserDefaults.set(value: [150, 250, 350], forkey: .quickButtons)
        
        let provider = MockServiceProvider(userDefaultsService: mockUserDefaults)
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshQuickButtons)
        
        #expect(store.quickButtons == [150, 250, 350])
    }
    
    @Test func defaultQuickButtonsWhenNoneSet() async {
        let mockUserDefaults = MockUserDefaultsService()
        let provider = MockServiceProvider(userDefaultsService: mockUserDefaults)
        let store = HomeStore(provider: provider)
        
        #expect(store.quickButtons == HomeStore.defaultQuickButtons)
    }
    
    // MARK: - Review Tests
    
    @Test func addWaterGoalAchievedSetsShouldRequestReviewWhenEligible() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1800, isSuccess: false, goal: 2000)
        ]
        mockWaterService.goal = 2000
        
        let mockReview = MockReviewEligibilityService()
        mockReview.shouldRequestReviewResult = true
        
        let provider = MockServiceProvider(
            waterService: mockWaterService,
            reviewEligibilityService: mockReview
        )
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshGoal)
        await store.send(.refresh)
        await store.send(.addWater(300))
        
        #expect(mockReview.recordGoalCompletionCallCount == 1)
        #expect(mockReview.markReviewRequestedCallCount == 1)
        #expect(store.shouldRequestReview == true)
    }
    
    @Test func addWaterGoalAchievedDoesNotRequestReviewWhenNotEligible() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1800, isSuccess: false, goal: 2000)
        ]
        mockWaterService.goal = 2000
        
        let mockReview = MockReviewEligibilityService()
        mockReview.shouldRequestReviewResult = false
        
        let provider = MockServiceProvider(
            waterService: mockWaterService,
            reviewEligibilityService: mockReview
        )
        let store = HomeStore(provider: provider)
        
        await store.send(.refreshGoal)
        await store.send(.refresh)
        await store.send(.addWater(300))
        
        #expect(mockReview.recordGoalCompletionCallCount == 1)
        #expect(mockReview.markReviewRequestedCallCount == 0)
        #expect(store.shouldRequestReview == false)
    }
    
    // MARK: - Notification Banner Tests
    
    @Test func checkNotificationPermissionShowsBannerWhenNotAuthorized() async {
        let mockNotificationService = MockNotificationService()
        mockNotificationService.authorizationResult = false
        
        let mockUserDefaults = MockUserDefaultsService()
        let provider = MockServiceProvider(
            userDefaultsService: mockUserDefaults,
            notificationService: mockNotificationService
        )
        let store = HomeStore(provider: provider)
        
        await store.send(.checkNotificationPermission)
        
        #expect(store.showNotificationBanner == true)
    }
    
    @Test func dismissNotificationBannerHidesBanner() async {
        let mockNotificationService = MockNotificationService()
        mockNotificationService.authorizationResult = false
        
        let mockUserDefaults = MockUserDefaultsService()
        
        let provider = MockServiceProvider(
            userDefaultsService: mockUserDefaults,
            notificationService: mockNotificationService
        )
        let store = HomeStore(provider: provider)
        
        await store.send(.checkNotificationPermission)
        #expect(store.showNotificationBanner == true)
        
        await store.send(.dismissNotificationBanner)
        #expect(store.showNotificationBanner == false)
    }
}
