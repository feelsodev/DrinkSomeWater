import Testing
import Foundation
@testable import DrinkSomeWater

@Suite("StatisticsStore")
@MainActor
struct StatisticsStoreTests {
    
    // MARK: - View Did Load Tests
    
    @Test func viewDidLoadFetchesWaterRecords() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1500, isSuccess: false, goal: 2000),
            WaterRecord(date: Calendar.current.date(byAdding: .day, value: -1, to: today)!, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.waterRecords.count == 2)
    }
    
    @Test func viewDidLoadSetsLoadingState() async {
        let mockWaterService = MockWaterService()
        mockWaterService.waterRecords = [
            WaterRecord(date: Date(), value: 1500, isSuccess: false, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        #expect(store.isLoading == false)
        
        let task = Task {
            await store.send(.viewDidLoad)
        }
        
        await task.value
        
        #expect(store.isLoading == false)
    }
    
    // MARK: - Daily Average Tests
    
    @Test func dailyAverageCalculatesCorrectlyWithRecords() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, value: 1400, isSuccess: false, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -2, to: today)!, value: 1600, isSuccess: false, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -3, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -4, to: today)!, value: 1800, isSuccess: false, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -5, to: today)!, value: 2200, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -6, to: today)!, value: 1400, isSuccess: false, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        // Total: 2000 + 1400 + 1600 + 2000 + 1800 + 2200 + 1400 = 12400
        // Average for 7 days: 12400 / 7 = 1771
        #expect(store.dailyAverage == 1771)
    }
    
    @Test func dailyAverageReturnsZeroWhenEmpty() async {
        let mockWaterService = MockWaterService()
        mockWaterService.waterRecords = []
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.dailyAverage == 0)
    }
    
    @Test func dailyAverageReturnsZeroWhenNoRecordsInPeriod() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        // Records from 30+ days ago
        mockWaterService.waterRecords = [
            WaterRecord(date: calendar.date(byAdding: .day, value: -40, to: today)!, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.dailyAverage == 0)
    }
    
    // MARK: - Goal Achievement Rate Tests
    
    @Test func goalAchievementRateCalculatesCorrectly() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -2, to: today)!, value: 1000, isSuccess: false, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -3, to: today)!, value: 2500, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        // 3 success out of 4 records = 0.75
        #expect(store.goalAchievementRate == 0.75)
    }
    
    @Test func goalAchievementRateReturnsZeroWhenEmpty() async {
        let mockWaterService = MockWaterService()
        mockWaterService.waterRecords = []
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.goalAchievementRate == 0.0)
    }
    
    @Test func goalAchievementRateReturnsZeroWhenAllFailed() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1000, isSuccess: false, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, value: 1500, isSuccess: false, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.goalAchievementRate == 0.0)
    }
    
    @Test func goalAchievementRateReturnsOneWhenAllSucceeded() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, value: 2500, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.goalAchievementRate == 1.0)
    }
    
    // MARK: - Current Streak Tests
    
    @Test func currentStreakCalculatesConsecutiveDays() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -2, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -3, to: today)!, value: 1000, isSuccess: false, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.currentStreak == 3)
    }
    
    @Test func currentStreakReturnsZeroWhenEmpty() async {
        let mockWaterService = MockWaterService()
        mockWaterService.waterRecords = []
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.currentStreak == 0)
    }
    
    @Test func currentStreakReturnsZeroWhenNoSuccessRecords() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1000, isSuccess: false, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, value: 1500, isSuccess: false, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.currentStreak == 0)
    }
    
    @Test func currentStreakBreaksOnGap() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -2, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -3, to: today)!, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        // Gap on day -1, so streak is only 1 (today)
        #expect(store.currentStreak == 1)
    }
    
    // MARK: - Longest Streak Tests
    
    @Test func longestStreakCalculatesCorrectly() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -2, to: today)!, value: 1000, isSuccess: false, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -3, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -4, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -5, to: today)!, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        // Longest streak is 3 (days -5, -4, -3)
        #expect(store.longestStreak == 3)
    }
    
    @Test func longestStreakReturnsZeroWhenEmpty() async {
        let mockWaterService = MockWaterService()
        mockWaterService.waterRecords = []
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.longestStreak == 0)
    }
    
    @Test func longestStreakReturnsOneForSingleSuccess() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.longestStreak == 1)
    }
    
    @Test func longestStreakIgnoresFailedRecords() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1000, isSuccess: false, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, value: 1000, isSuccess: false, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -2, to: today)!, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.longestStreak == 1)
    }
    
    // MARK: - Period Selection Tests
    
    @Test func selectPeriodChangesSelectedPeriod() async {
        let mockWaterService = MockWaterService()
        mockWaterService.waterRecords = []
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        #expect(store.selectedPeriod == .week)
        
        await store.send(.selectPeriod(.month))
        
        #expect(store.selectedPeriod == .month)
    }
    
    @Test func selectPeriodFiltersDataCorrectly() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -3, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -10, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -25, to: today)!, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        // Week period (7 days): should include today and -3 (2 records, -10 is outside 7 day range)
        #expect(store.dailyData.count == 2)
        
        await store.send(.selectPeriod(.month))
        
        // Month period: should include all 4 records
        #expect(store.dailyData.count == 4)
    }
    
    @Test func selectPeriodUpdatesAverageCalculation() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -5, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -25, to: today)!, value: 1000, isSuccess: false, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        // Week: (2000 + 2000) / 7 = 571
        let weekAverage = store.dailyAverage
        
        await store.send(.selectPeriod(.month))
        
        // Month: (2000 + 2000 + 1000) / 30 = 166
        let monthAverage = store.dailyAverage
        
        #expect(weekAverage != monthAverage)
    }
    
    // MARK: - Daily Data Tests
    
    @Test func dailyDataReturnsSortedRecords() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: calendar.date(byAdding: .day, value: -2, to: today)!, value: 1600, isSuccess: false, goal: 2000),
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, value: 1400, isSuccess: false, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        let dailyData = store.dailyData
        
        #expect(dailyData.count == 3)
        #expect(dailyData[0].amount == 1600)
        #expect(dailyData[1].amount == 1400)
        #expect(dailyData[2].amount == 2000)
    }
    
    @Test func dailyDataIncludesDateAmountAndGoal() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        let dailyData = store.dailyData
        
        #expect(dailyData.count == 1)
        #expect(dailyData[0].amount == 2000)
        #expect(dailyData[0].goal == 2000)
    }
    
    @Test func dailyDataReturnsEmptyWhenNoRecordsInPeriod() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: calendar.date(byAdding: .day, value: -40, to: today)!, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.dailyData.isEmpty)
    }
    
    // MARK: - Integration Tests
    
    @Test func multipleActionsUpdateStateCorrectly() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -5, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -25, to: today)!, value: 1000, isSuccess: false, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        #expect(store.waterRecords.count == 3)
        
        await store.send(.selectPeriod(.month))
        #expect(store.selectedPeriod == .month)
        #expect(store.dailyData.count == 3)
    }
    
    @Test func currentStreakHandlesMultipleRecordsOnSameDay() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1000, isSuccess: true, goal: 2000),
            WaterRecord(date: today.addingTimeInterval(-3600), value: 500, isSuccess: true, goal: 2000),
            WaterRecord(date: today.addingTimeInterval(-7200), value: 800, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.currentStreak == 2)
    }
    
    @Test func longestStreakHandlesMultipleRecordsOnSameDay() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: calendar.date(byAdding: .day, value: -10, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -10, to: today)!.addingTimeInterval(-3600), value: 500, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -9, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -9, to: today)!.addingTimeInterval(-3600), value: 500, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -8, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -5, to: today)!, value: 1000, isSuccess: false, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.longestStreak == 3)
    }
    
    @Test func currentStreakStartsFromYesterdayWhenTodayNotSuccess() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 500, isSuccess: false, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -2, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -3, to: today)!, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = StatisticsStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.currentStreak == 3)
    }
}
