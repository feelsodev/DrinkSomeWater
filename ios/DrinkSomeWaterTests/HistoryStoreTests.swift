import Testing
import Foundation
@testable import DrinkSomeWater

@Suite("HistoryStore")
@MainActor
struct HistoryStoreTests {
    
    // MARK: - View Did Load Tests
    
    @Test func viewDidLoadFetchesRecords() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1500, isSuccess: false, goal: 2000),
            WaterRecord(date: Calendar.current.date(byAdding: .day, value: -1, to: today)!, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HistoryStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.waterRecordList.count == 2)
    }
    
    @Test func viewDidLoadPopulatesSuccessDates() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: yesterday, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HistoryStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.successDates.count == 2)
    }
    
    // MARK: - Select Date Tests
    
    @Test func selectDateUpdatesSelectedRecord() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1500, isSuccess: false, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HistoryStore(provider: provider)
        
        await store.send(.viewDidLoad)
        await store.send(.selectDate(today))
        
        #expect(store.selectedRecord != nil)
        #expect(store.selectedRecord?.value == 1500)
    }
    
    @Test func selectDateWithNoRecordSetsNil() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: 10, to: today)!
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 1500, isSuccess: false, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HistoryStore(provider: provider)
        
        await store.send(.viewDidLoad)
        await store.send(.selectDate(futureDate))
        
        #expect(store.selectedRecord == nil)
    }
    
    // MARK: - Monthly Statistics Tests
    
    @Test func monthlySuccessCountCalculatesCorrectly() async {
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
        let store = HistoryStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.monthlySuccessCount == 3)
    }
    
    @Test func monthlyTotalDaysCalculatesCorrectly() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -1, to: today)!, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -2, to: today)!, value: 1000, isSuccess: false, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -3, to: today)!, value: 500, isSuccess: false, goal: 2000),
            WaterRecord(date: calendar.date(byAdding: .day, value: -4, to: today)!, value: 2500, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HistoryStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.monthlyTotalDays == 5)
    }
    
    @Test func monthlySuccessCountExcludesOtherMonths() async {
        let mockWaterService = MockWaterService()
        let today = Date()
        let calendar = Calendar.current
        
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: today)!
        mockWaterService.waterRecords = [
            WaterRecord(date: today, value: 2000, isSuccess: true, goal: 2000),
            WaterRecord(date: lastMonth, value: 2000, isSuccess: true, goal: 2000)
        ]
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HistoryStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.monthlySuccessCount == 1)
    }
    
    // MARK: - Empty State Tests
    
    @Test func emptyRecordsShowZeroStatistics() async {
        let mockWaterService = MockWaterService()
        mockWaterService.waterRecords = []
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HistoryStore(provider: provider)
        
        await store.send(.viewDidLoad)
        
        #expect(store.waterRecordList.isEmpty)
        #expect(store.successDates.isEmpty)
        #expect(store.monthlySuccessCount == 0)
        #expect(store.monthlyTotalDays == 0)
    }
}
