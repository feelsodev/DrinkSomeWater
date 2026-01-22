import Testing
import Foundation
@testable import DrinkSomeWater

@Suite("CloudSyncService")
@MainActor
struct CloudSyncServiceTests {
    
    private static func fixedDate(year: Int = 2024, month: Int = 6, day: Int = 15, hour: Int = 12) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = .current
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }
    
    // MARK: - CloudWaterRecord Date Conversion Tests
    
    @Test func dateKeyFromDateFormatsCorrectly() {
        let date = Self.fixedDate(year: 2024, month: 6, day: 15)
        
        let key = CloudWaterRecord.dateKey(from: date)
        
        #expect(key == "2024-06-15")
    }
    
    @Test func dateFromDateKeyParsesCorrectly() {
        let dateKey = "2024-06-15"
        
        let date = CloudWaterRecord.date(from: dateKey)
        
        #expect(date != nil)
        let calendar = Calendar.current
        #expect(calendar.component(.year, from: date!) == 2024)
        #expect(calendar.component(.month, from: date!) == 6)
        #expect(calendar.component(.day, from: date!) == 15)
    }
    
    @Test func dateFromInvalidKeyReturnsNil() {
        let invalidKey = "invalid-date"
        
        let date = CloudWaterRecord.date(from: invalidKey)
        
        #expect(date == nil)
    }
    
    @Test func dateKeyRoundTrip() {
        let originalDate = Self.fixedDate(year: 2024, month: 12, day: 25)
        
        let key = CloudWaterRecord.dateKey(from: originalDate)
        let parsedDate = CloudWaterRecord.date(from: key)
        
        #expect(parsedDate != nil)
        #expect(key == "2024-12-25")
    }
    
    // MARK: - Merge Logic Tests
    
    @Test func mergeWithOnlyLocalRecordsReturnsLocal() {
        let mockCloud = MockCloudSyncService()
        let testDate = Self.fixedDate()
        let localRecords = [
            WaterRecord(date: testDate, value: 500, isSuccess: false, goal: 2000)
        ]
        
        let merged = mockCloud.mergeWaterRecords(local: localRecords)
        
        #expect(merged.count == 1)
        #expect(merged.first?.value == 500)
        #expect(merged.first?.goal == 2000)
        #expect(merged.first?.isSuccess == false)
    }
    
    @Test func mergeWithOnlyCloudRecordsReturnsCloud() {
        let mockCloud = MockCloudSyncService()
        let testDate = Self.fixedDate()
        let dateKey = CloudWaterRecord.dateKey(from: testDate)
        mockCloud.mockWaterRecords[dateKey] = CloudWaterRecord(
            dateKey: dateKey,
            value: 800,
            goal: 2500,
            isSuccess: false,
            modifiedAt: testDate.timeIntervalSince1970
        )
        
        let merged = mockCloud.mergeWaterRecords(local: [])
        
        #expect(merged.count == 1)
        #expect(merged.first?.value == 800)
        #expect(merged.first?.goal == 2500)
        #expect(merged.first?.isSuccess == false)
    }
    
    @Test func mergeWithNewerCloudRecordUsesCloud() {
        let mockCloud = MockCloudSyncService()
        let testDate = Self.fixedDate()
        let dateKey = CloudWaterRecord.dateKey(from: testDate)
        
        let localDate = testDate.addingTimeInterval(-3600)
        let cloudModifiedAt = testDate.timeIntervalSince1970
        
        mockCloud.mockWaterRecords[dateKey] = CloudWaterRecord(
            dateKey: dateKey,
            value: 1000,
            goal: 2000,
            isSuccess: false,
            modifiedAt: cloudModifiedAt
        )
        
        let localRecords = [
            WaterRecord(date: localDate, value: 500, isSuccess: false, goal: 2000)
        ]
        
        let merged = mockCloud.mergeWaterRecords(local: localRecords)
        
        #expect(merged.count == 1)
        #expect(merged.first?.value == 1000)
        #expect(merged.first?.goal == 2000)
    }
    
    @Test func mergeWithNewerLocalRecordUsesLocal() {
        let mockCloud = MockCloudSyncService()
        let testDate = Self.fixedDate()
        let dateKey = CloudWaterRecord.dateKey(from: testDate)
        
        let cloudModifiedAt = testDate.addingTimeInterval(-3600).timeIntervalSince1970
        
        mockCloud.mockWaterRecords[dateKey] = CloudWaterRecord(
            dateKey: dateKey,
            value: 500,
            goal: 1800,
            isSuccess: false,
            modifiedAt: cloudModifiedAt
        )
        
        let localRecords = [
            WaterRecord(date: testDate, value: 1000, isSuccess: false, goal: 2000)
        ]
        
        let merged = mockCloud.mergeWaterRecords(local: localRecords)
        
        #expect(merged.count == 1)
        #expect(merged.first?.value == 1000)
        #expect(merged.first?.goal == 2000)
    }
    
    @Test func mergeWithSameTimestampPrefersHigherValue() {
        let mockCloud = MockCloudSyncService()
        let testDate = Self.fixedDate()
        let dateKey = CloudWaterRecord.dateKey(from: testDate)
        let timestamp = testDate.timeIntervalSince1970
        
        mockCloud.mockWaterRecords[dateKey] = CloudWaterRecord(
            dateKey: dateKey,
            value: 1200,
            goal: 2000,
            isSuccess: false,
            modifiedAt: timestamp
        )
        
        let localRecords = [
            WaterRecord(date: testDate, value: 800, isSuccess: false, goal: 2000)
        ]
        
        let merged = mockCloud.mergeWaterRecords(local: localRecords)
        
        #expect(merged.count == 1)
        #expect(merged.first?.value == 1200)
        #expect(merged.first?.goal == 2000)
        #expect(merged.first?.isSuccess == false)
    }
    
    @Test func mergeWithSameTimestampAndLocalHigherUsesLocal() {
        let mockCloud = MockCloudSyncService()
        let testDate = Self.fixedDate()
        let dateKey = CloudWaterRecord.dateKey(from: testDate)
        let timestamp = testDate.timeIntervalSince1970
        
        mockCloud.mockWaterRecords[dateKey] = CloudWaterRecord(
            dateKey: dateKey,
            value: 500,
            goal: 2000,
            isSuccess: false,
            modifiedAt: timestamp
        )
        
        let localRecords = [
            WaterRecord(date: testDate, value: 1000, isSuccess: false, goal: 2000)
        ]
        
        let merged = mockCloud.mergeWaterRecords(local: localRecords)
        
        #expect(merged.count == 1)
        #expect(merged.first?.value == 1000)
    }
    
    @Test func mergeCombinesRecordsFromDifferentDays() {
        let mockCloud = MockCloudSyncService()
        let day1 = Self.fixedDate(year: 2024, month: 6, day: 15)
        let day2 = Self.fixedDate(year: 2024, month: 6, day: 14)
        
        let day1Key = CloudWaterRecord.dateKey(from: day1)
        let day2Key = CloudWaterRecord.dateKey(from: day2)
        
        mockCloud.mockWaterRecords[day2Key] = CloudWaterRecord(
            dateKey: day2Key,
            value: 2000,
            goal: 2000,
            isSuccess: true,
            modifiedAt: day2.timeIntervalSince1970
        )
        
        let localRecords = [
            WaterRecord(date: day1, value: 500, isSuccess: false, goal: 2000)
        ]
        
        let merged = mockCloud.mergeWaterRecords(local: localRecords)
        
        #expect(merged.count == 2)
        
        let day1Record = merged.first { CloudWaterRecord.dateKey(from: $0.date) == day1Key }
        let day2Record = merged.first { CloudWaterRecord.dateKey(from: $0.date) == day2Key }
        
        #expect(day1Record?.value == 500)
        #expect(day1Record?.isSuccess == false)
        #expect(day2Record?.value == 2000)
        #expect(day2Record?.isSuccess == true)
    }
    
    @Test func mergeResultsSortedByDateDescending() {
        let mockCloud = MockCloudSyncService()
        let day1 = Self.fixedDate(year: 2024, month: 6, day: 15)
        let day2 = Self.fixedDate(year: 2024, month: 6, day: 14)
        let day3 = Self.fixedDate(year: 2024, month: 6, day: 13)
        
        let localRecords = [
            WaterRecord(date: day2, value: 1000, isSuccess: false, goal: 2000),
            WaterRecord(date: day1, value: 500, isSuccess: false, goal: 2000),
            WaterRecord(date: day3, value: 1500, isSuccess: false, goal: 2000)
        ]
        
        let merged = mockCloud.mergeWaterRecords(local: localRecords)
        
        #expect(merged.count == 3)
        #expect(merged[0].date > merged[1].date)
        #expect(merged[1].date > merged[2].date)
        #expect(merged[0].value == 500)
        #expect(merged[1].value == 1000)
        #expect(merged[2].value == 1500)
    }
    
    // MARK: - SaveWaterRecord Overwrite Guard Tests
    
    @Test func saveWaterRecordIgnoresOlderRecord() {
        let mockCloud = MockCloudSyncService()
        let testDate = Self.fixedDate()
        let dateKey = CloudWaterRecord.dateKey(from: testDate)
        
        let newerRecord = CloudWaterRecord(
            dateKey: dateKey,
            value: 1000,
            goal: 2000,
            isSuccess: false,
            modifiedAt: testDate.timeIntervalSince1970
        )
        mockCloud.saveWaterRecord(newerRecord)
        
        let olderRecord = CloudWaterRecord(
            dateKey: dateKey,
            value: 500,
            goal: 2000,
            isSuccess: false,
            modifiedAt: testDate.addingTimeInterval(-3600).timeIntervalSince1970
        )
        mockCloud.saveWaterRecord(olderRecord)
        
        let loaded = mockCloud.loadWaterRecords()
        #expect(loaded[dateKey]?.value == 1000)
    }
    
    @Test func saveWaterRecordIgnoresLowerValueAtSameTime() {
        let mockCloud = MockCloudSyncService()
        let testDate = Self.fixedDate()
        let dateKey = CloudWaterRecord.dateKey(from: testDate)
        let timestamp = testDate.timeIntervalSince1970
        
        let higherRecord = CloudWaterRecord(
            dateKey: dateKey,
            value: 1000,
            goal: 2000,
            isSuccess: false,
            modifiedAt: timestamp
        )
        mockCloud.saveWaterRecord(higherRecord)
        
        let lowerRecord = CloudWaterRecord(
            dateKey: dateKey,
            value: 500,
            goal: 2000,
            isSuccess: false,
            modifiedAt: timestamp
        )
        mockCloud.saveWaterRecord(lowerRecord)
        
        let loaded = mockCloud.loadWaterRecords()
        #expect(loaded[dateKey]?.value == 1000)
    }
    
    @Test func saveWaterRecordAcceptsNewerHigherValue() {
        let mockCloud = MockCloudSyncService()
        let testDate = Self.fixedDate()
        let dateKey = CloudWaterRecord.dateKey(from: testDate)
        
        let olderRecord = CloudWaterRecord(
            dateKey: dateKey,
            value: 500,
            goal: 2000,
            isSuccess: false,
            modifiedAt: testDate.addingTimeInterval(-3600).timeIntervalSince1970
        )
        mockCloud.saveWaterRecord(olderRecord)
        
        let newerRecord = CloudWaterRecord(
            dateKey: dateKey,
            value: 1000,
            goal: 2000,
            isSuccess: false,
            modifiedAt: testDate.timeIntervalSince1970
        )
        mockCloud.saveWaterRecord(newerRecord)
        
        let loaded = mockCloud.loadWaterRecords()
        #expect(loaded[dateKey]?.value == 1000)
    }
    
    // MARK: - Cloud Sync Service Protocol Tests
    
    @Test func saveAndLoadGoal() {
        let mockCloud = MockCloudSyncService()
        
        mockCloud.saveGoal(2500)
        
        #expect(mockCloud.loadGoal() == 2500)
    }
    
    @Test func saveAndLoadQuickButtons() {
        let mockCloud = MockCloudSyncService()
        let buttons = [100, 200, 300, 500]
        
        mockCloud.saveQuickButtons(buttons)
        
        #expect(mockCloud.loadQuickButtons() == buttons)
    }
    
    @Test func saveAndLoadCustomQuickButtons() {
        let mockCloud = MockCloudSyncService()
        let buttons = [150, 250]
        
        mockCloud.saveCustomQuickButtons(buttons)
        
        #expect(mockCloud.loadCustomQuickButtons() == buttons)
    }
    
    @Test func saveAndLoadNotificationSettings() {
        let mockCloud = MockCloudSyncService()
        
        mockCloud.saveNotificationSettings(
            enabled: true,
            startHour: 9,
            startMinute: 30,
            endHour: 21,
            endMinute: 0,
            intervalMinutes: 90,
            weekdays: [1, 2, 3, 4, 5],
            customTimes: [["hour": 12, "minute": 0]]
        )
        
        #expect(mockCloud.loadNotificationEnabled() == true)
        #expect(mockCloud.loadNotificationStartHour() == 9)
        #expect(mockCloud.loadNotificationStartMinute() == 30)
        #expect(mockCloud.loadNotificationEndHour() == 21)
        #expect(mockCloud.loadNotificationEndMinute() == 0)
        #expect(mockCloud.loadNotificationIntervalMinutes() == 90)
        #expect(mockCloud.loadNotificationWeekdays() == [1, 2, 3, 4, 5])
        #expect(mockCloud.loadNotificationCustomTimes()?.count == 1)
    }
    
    @Test func saveAndLoadUserWeight() {
        let mockCloud = MockCloudSyncService()
        
        mockCloud.saveUserWeight(70.5)
        
        #expect(mockCloud.loadUserWeight() == 70.5)
    }
    
    @Test func saveAndLoadUseHealthKitWeight() {
        let mockCloud = MockCloudSyncService()
        
        mockCloud.saveUseHealthKitWeight(true)
        
        #expect(mockCloud.loadUseHealthKitWeight() == true)
    }
    
    @Test func saveAndLoadOnboardingCompleted() {
        let mockCloud = MockCloudSyncService()
        
        mockCloud.saveOnboardingCompleted(true)
        
        #expect(mockCloud.loadOnboardingCompleted() == true)
    }
    
    @Test func saveWaterRecordStoresCorrectly() {
        let mockCloud = MockCloudSyncService()
        let testDate = Self.fixedDate()
        let dateKey = CloudWaterRecord.dateKey(from: testDate)
        
        let record = CloudWaterRecord(
            dateKey: dateKey,
            value: 750,
            goal: 2000,
            isSuccess: false,
            modifiedAt: testDate.timeIntervalSince1970
        )
        
        mockCloud.saveWaterRecord(record)
        
        let loaded = mockCloud.loadWaterRecords()
        #expect(loaded[dateKey]?.value == 750)
        #expect(loaded[dateKey]?.goal == 2000)
        #expect(loaded[dateKey]?.isSuccess == false)
    }
    
    @Test func cloudUnavailableReturnsCorrectStatus() {
        let mockCloud = MockCloudSyncService()
        mockCloud.mockIsCloudAvailable = false
        
        #expect(mockCloud.isCloudAvailable == false)
    }
    
    @Test func requestSyncIncrementsCallCount() {
        let mockCloud = MockCloudSyncService()
        
        mockCloud.requestSync()
        mockCloud.requestSync()
        
        #expect(mockCloud.requestSyncCallCount == 2)
    }
    
    @Test func changeObservationCallsHandler() {
        let mockCloud = MockCloudSyncService()
        var handlerCalled = false
        
        mockCloud.startObservingChanges {
            handlerCalled = true
        }
        mockCloud.simulateExternalChange()
        
        #expect(handlerCalled)
    }
    
    @Test func stopObservingClearsHandler() {
        let mockCloud = MockCloudSyncService()
        var handlerCalled = false
        
        mockCloud.startObservingChanges {
            handlerCalled = true
        }
        mockCloud.stopObservingChanges()
        mockCloud.simulateExternalChange()
        
        #expect(!handlerCalled)
    }
}
