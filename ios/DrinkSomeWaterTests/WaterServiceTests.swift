import Testing
import Foundation
@testable import DrinkSomeWater

@Suite("WaterService")
@MainActor
struct WaterServiceTests {
    
    // MARK: - Fetch Water Tests
    
    @Test func fetchWaterReturnsExistingRecords() async {
        let mockUserDefaults = MockUserDefaultsService()
        let today = Date()
        let record = WaterRecord(date: today, value: 500, isSuccess: false, goal: 2000)
        mockUserDefaults.set(value: [record.asDictionary()], forkey: .current)
        mockUserDefaults.set(value: 2000, forkey: .goal)
        
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        let records = await service.fetchWater()
        
        #expect(!records.isEmpty)
        #expect(records.first?.value == 500)
    }
    
    @Test func fetchWaterCreatesNewRecordForToday() async {
        let mockUserDefaults = MockUserDefaultsService()
        mockUserDefaults.set(value: 2000, forkey: .goal)
        
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        let records = await service.fetchWater()
        
        #expect(!records.isEmpty)
        #expect(records.first?.value == 0)
        #expect(records.first?.goal == 2000)
    }
    
    @Test func fetchWaterUsesDefaultGoalWhenNotSet() async {
        let mockUserDefaults = MockUserDefaultsService()
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        let records = await service.fetchWater()
        
        #expect(!records.isEmpty)
        #expect(records.first?.goal == 2000)
        #expect(records.first?.value == 0)
    }
    
    // MARK: - Fetch Goal Tests
    
    @Test func fetchGoalReturnsStoredGoal() async {
        let mockUserDefaults = MockUserDefaultsService()
        mockUserDefaults.set(value: 2500, forkey: .goal)
        
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        let goal = await service.fetchGoal()
        
        #expect(goal == 2500)
    }
    
    @Test func fetchGoalReturnsDefaultWhenNotSet() async {
        let mockUserDefaults = MockUserDefaultsService()
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        let goal = await service.fetchGoal()
        
        #expect(goal == 2000)
    }
    
    // MARK: - Update Water Tests
    
    @Test func updateWaterAddsToExistingRecord() async {
        let mockUserDefaults = MockUserDefaultsService()
        let today = Date()
        let record = WaterRecord(date: today, value: 300, isSuccess: false, goal: 2000)
        mockUserDefaults.set(value: [record.asDictionary()], forkey: .current)
        mockUserDefaults.set(value: 2000, forkey: .goal)
        
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        let updatedRecords = await service.updateWater(by: 200)
        
        let todayRecord = updatedRecords.first { $0.date.checkToday }
        #expect(todayRecord?.value == 500)
    }
    
    @Test func updateWaterSetsSuccessWhenGoalReached() async {
        let mockUserDefaults = MockUserDefaultsService()
        let today = Date()
        let record = WaterRecord(date: today, value: 1800, isSuccess: false, goal: 2000)
        mockUserDefaults.set(value: [record.asDictionary()], forkey: .current)
        mockUserDefaults.set(value: 2000, forkey: .goal)
        
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        let updatedRecords = await service.updateWater(by: 300)
        
        let todayRecord = updatedRecords.first { $0.date.checkToday }
        #expect(todayRecord?.isSuccess == true)
    }
    
    @Test func updateWaterWithNegativeSubtracts() async {
        let mockUserDefaults = MockUserDefaultsService()
        let today = Date()
        let record = WaterRecord(date: today, value: 500, isSuccess: false, goal: 2000)
        mockUserDefaults.set(value: [record.asDictionary()], forkey: .current)
        mockUserDefaults.set(value: 2000, forkey: .goal)
        
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        let updatedRecords = await service.updateWater(by: -200)
        
        let todayRecord = updatedRecords.first { $0.date.checkToday }
        #expect(todayRecord?.value == 300)
    }
    
    // MARK: - Update Goal Tests
    
    @Test func updateGoalSavesNewGoal() async {
        let mockUserDefaults = MockUserDefaultsService()
        mockUserDefaults.set(value: 2000, forkey: .goal)
        
        let today = Date()
        let record = WaterRecord(date: today, value: 500, isSuccess: false, goal: 2000)
        mockUserDefaults.set(value: [record.asDictionary()], forkey: .current)
        
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        let newGoal = await service.updateGoal(to: 2500)
        
        #expect(newGoal == 2500)
        #expect(mockUserDefaults.value(forkey: .goal) == 2500)
    }
    
    @Test func updateGoalUpdatesSuccessStatus() async {
        let mockUserDefaults = MockUserDefaultsService()
        let today = Date()
        let record = WaterRecord(date: today, value: 1500, isSuccess: false, goal: 2000)
        mockUserDefaults.set(value: [record.asDictionary()], forkey: .current)
        mockUserDefaults.set(value: 2000, forkey: .goal)
        
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        _ = await service.updateGoal(to: 1500)
        let records = await service.fetchWater()
        let todayRecord = records.first { $0.date.checkToday }
        
        #expect(todayRecord?.isSuccess == true)
    }
    
    // MARK: - Reset Today Water Tests
    
    @Test func resetTodayWaterClearsValue() async {
        let mockUserDefaults = MockUserDefaultsService()
        let today = Date()
        let record = WaterRecord(date: today, value: 1500, isSuccess: false, goal: 2000)
        mockUserDefaults.set(value: [record.asDictionary()], forkey: .current)
        mockUserDefaults.set(value: 2000, forkey: .goal)
        
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        let updatedRecords = await service.resetTodayWater()
        
        let todayRecord = updatedRecords.first { $0.date.checkToday }
        #expect(todayRecord?.value == 0)
        #expect(todayRecord?.isSuccess == false)
    }
    
    @Test func resetTodayWaterPreservesOtherRecords() async {
        let mockUserDefaults = MockUserDefaultsService()
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        let todayRecord = WaterRecord(date: today, value: 1500, isSuccess: false, goal: 2000)
        let yesterdayRecord = WaterRecord(date: yesterday, value: 2000, isSuccess: true, goal: 2000)
        mockUserDefaults.set(value: [todayRecord.asDictionary(), yesterdayRecord.asDictionary()], forkey: .current)
        mockUserDefaults.set(value: 2000, forkey: .goal)
        
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        let updatedRecords = await service.resetTodayWater()
        let yesterdayUpdated = updatedRecords.first { !$0.date.checkToday }
        #expect(yesterdayUpdated?.value == 2000)
        #expect(yesterdayUpdated?.isSuccess == true)
    }
    
    // MARK: - Save Water Tests
    
    @Test func saveWaterPersistsToUserDefaults() async {
        let mockUserDefaults = MockUserDefaultsService()
        mockUserDefaults.set(value: 2000, forkey: .goal)
        
        let mockWatchService = MockWatchConnectivityService()
        let service = WaterService(
            userDefaultsService: mockUserDefaults,
            cloudSyncService: MockCloudSyncService(),
            watchConnectivityService: mockWatchService
        )
        
        let today = Date()
        let records = [
            WaterRecord(date: today, value: 1000, isSuccess: false, goal: 2000)
        ]
        
        await service.saveWater(records)
        
        let savedData: [[String: Any]]? = mockUserDefaults.value(forkey: .current)
        #expect(savedData != nil)
        #expect(savedData?.count == 1)
    }
}
