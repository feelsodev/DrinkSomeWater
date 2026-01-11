import Testing
import Foundation
@testable import DrinkSomeWater

@Suite("NotificationTime")
struct NotificationTimeTests {
    
    @Test func displayStringFormatsCorrectly() {
        #expect(NotificationTime(hour: 8, minute: 0).displayString == "08:00")
        #expect(NotificationTime(hour: 14, minute: 30).displayString == "14:30")
        #expect(NotificationTime(hour: 0, minute: 5).displayString == "00:05")
    }
    
    @Test func fromDictionaryCreatesValidTime() throws {
        let validTime = try #require(NotificationTime.from(dictionary: ["hour": 9, "minute": 30]))
        #expect(validTime.hour == 9)
        #expect(validTime.minute == 30)
        
        #expect(NotificationTime.from(dictionary: ["hour": 9]) == nil)
    }
    
    @Test func toDictionaryConvertsCorrectly() {
        let dict = NotificationTime(hour: 10, minute: 45).toDictionary()
        #expect(dict["hour"] == 10)
        #expect(dict["minute"] == 45)
    }
    
    @Test func equatableWorksCorrectly() {
        let time1 = NotificationTime(hour: 8, minute: 0)
        let time2 = NotificationTime(hour: 8, minute: 0)
        let time3 = NotificationTime(hour: 8, minute: 30)
        
        #expect(time1 == time2)
        #expect(time1 != time3)
    }
}

@Suite("NotificationInterval")
struct NotificationIntervalTests {
    
    @Test func rawValuesAreCorrect() {
        #expect(NotificationInterval.thirtyMinutes.rawValue == 30)
        #expect(NotificationInterval.oneHour.rawValue == 60)
        #expect(NotificationInterval.twoHours.rawValue == 120)
        #expect(NotificationInterval.threeHours.rawValue == 180)
    }
    
    @Test func displayStringsAreLocalized() {
        // These values depend on locale - just verify they're not empty
        #expect(!NotificationInterval.thirtyMinutes.displayString.isEmpty)
        #expect(!NotificationInterval.oneHour.displayString.isEmpty)
        #expect(!NotificationInterval.twoHours.displayString.isEmpty)
        #expect(!NotificationInterval.threeHours.displayString.isEmpty)
    }
    
    @Test func allCasesHasFourIntervals() {
        #expect(NotificationInterval.allCases.count == 4)
    }
}

@Suite("Weekday")
struct WeekdayTests {
    
    @Test func rawValuesMatchCalendarWeekday() {
        #expect(Weekday.sunday.rawValue == 1)
        #expect(Weekday.monday.rawValue == 2)
        #expect(Weekday.saturday.rawValue == 7)
    }
    
    @Test func shortNamesAreLocalized() {
        // These values depend on locale - just verify they're not empty
        #expect(!Weekday.sunday.shortName.isEmpty)
        #expect(!Weekday.monday.shortName.isEmpty)
        #expect(!Weekday.saturday.shortName.isEmpty)
    }
    
    @Test func allCasesHasSevenDays() {
        #expect(Weekday.allCases.count == 7)
    }
}

@Suite("NotificationSettings")
struct NotificationSettingsTests {
    
    @Test func defaultSettingsAreCorrect() {
        let settings = NotificationSettings.default
        
        #expect(settings.isEnabled)
        #expect(settings.startTime.hour == 8)
        #expect(settings.startTime.minute == 0)
        #expect(settings.endTime.hour == 22)
        #expect(settings.endTime.minute == 0)
        #expect(settings.interval == .oneHour)
        #expect(settings.enabledWeekdays.count == 7)
        #expect(settings.customTimes.isEmpty)
    }
}

final class MockNotificationService: NotificationServiceProtocol, @unchecked Sendable {
    var savedSettings: NotificationSettings?
    var scheduledSettings: NotificationSettings?
    var cancelAllCalled = false
    var authorizationResult = true
    
    func loadSettings() -> NotificationSettings {
        savedSettings ?? .default
    }
    
    func saveSettings(_ settings: NotificationSettings) {
        savedSettings = settings
    }
    
    func scheduleNotifications(with settings: NotificationSettings) {
        scheduledSettings = settings
    }
    
    func cancelAllNotifications() {
        cancelAllCalled = true
    }
    
    func requestAuthorization() async -> Bool {
        authorizationResult
    }

    func checkAuthorizationStatus() async -> Bool {
        authorizationResult
    }
}

final class MockWatchConnectivityService: WatchConnectivityServiceProtocol {
    func activate() {}
    func syncToWatch(todayWater: Int, goal: Int) {}
}

final class MockHealthKitService: HealthKitServiceProtocol {
    var isAvailable: Bool { false }
    func requestAuthorization() async -> Bool { false }
    func fetchWeight() async -> Double? { nil }
    func saveWaterIntake(_ ml: Double, date: Date) async -> Bool { false }
    func fetchTodayWaterIntake() async -> Double { 0 }
}

final class MockUserDefaultsService: UserDefaultsServiceProtocol {
    private var storage: [String: Any] = [:]

    func value<T>(forkey key: UserDefaultsKey<T>) -> T? {
        storage[key.key] as? T
    }

    func set<T>(value: T?, forkey key: UserDefaultsKey<T>) {
        if let value = value {
            storage[key.key] = value
        } else {
            storage.removeValue(forKey: key.key)
        }
    }
}

final class MockWaterService: WaterServiceProtocol {
    func fetchWater() async -> [WaterRecord] { [] }
    func fetchGoal() async -> Int { 2000 }
    func saveWater(_ waterRecord: [WaterRecord]) async {}
    func updateWater(by ml: Float) async -> [WaterRecord] { [] }
    func updateGoal(to ml: Int) async -> Int { ml }
    func resetTodayWater() async -> [WaterRecord] { [] }
}

final class MockAlertService: AlertServiceProtocol {
    @MainActor
    func show(title: String?, message: String?) async {}
}

final class MockServiceProvider: ServiceProviderProtocol, @unchecked Sendable {
    let userDefaultsService: UserDefaultsServiceProtocol
    let waterService: WaterServiceProtocol
    let alertService: AlertServiceProtocol
    let notificationService: NotificationServiceProtocol
    let healthKitService: HealthKitServiceProtocol
    let watchConnectivityService: WatchConnectivityServiceProtocol

    init(notificationService: NotificationServiceProtocol = MockNotificationService()) {
        self.userDefaultsService = MockUserDefaultsService()
        self.waterService = MockWaterService()
        self.alertService = MockAlertService()
        self.notificationService = notificationService
        self.healthKitService = MockHealthKitService()
        self.watchConnectivityService = MockWatchConnectivityService()
    }
}

@Suite("NotificationStore")
@MainActor
struct NotificationStoreTests {
    
    @Test func loadFetchesSettingsFromService() async {
        let mockService = MockNotificationService()
        mockService.savedSettings = NotificationSettings(
            isEnabled: false,
            startTime: NotificationTime(hour: 9, minute: 0),
            endTime: NotificationTime(hour: 21, minute: 0),
            interval: .twoHours,
            enabledWeekdays: Set([.monday, .tuesday, .wednesday]),
            customTimes: []
        )
        let provider = MockServiceProvider(notificationService: mockService)
        let store = NotificationStore(provider: provider)
        
        await store.send(.load)
        
        #expect(!store.settings.isEnabled)
        #expect(store.settings.startTime.hour == 9)
        #expect(store.settings.endTime.hour == 21)
        #expect(store.settings.interval == .twoHours)
        #expect(store.settings.enabledWeekdays.count == 3)
    }
    
    @Test func toggleEnabledUpdatesAndSaves() async {
        let mockService = MockNotificationService()
        let provider = MockServiceProvider(notificationService: mockService)
        let store = NotificationStore(provider: provider)
        await store.send(.load)
        
        await store.send(.toggleEnabled(false))
        
        #expect(!store.settings.isEnabled)
        #expect(mockService.savedSettings?.isEnabled == false)
    }
    
    @Test func updateStartTimeChangesStartTime() async {
        let mockService = MockNotificationService()
        let provider = MockServiceProvider(notificationService: mockService)
        let store = NotificationStore(provider: provider)
        await store.send(.load)
        
        await store.send(.updateStartTime(NotificationTime(hour: 7, minute: 30)))
        
        #expect(store.settings.startTime.hour == 7)
        #expect(store.settings.startTime.minute == 30)
    }
    
    @Test func updateEndTimeChangesEndTime() async {
        let mockService = MockNotificationService()
        let provider = MockServiceProvider(notificationService: mockService)
        let store = NotificationStore(provider: provider)
        await store.send(.load)
        
        await store.send(.updateEndTime(NotificationTime(hour: 23, minute: 0)))
        
        #expect(store.settings.endTime.hour == 23)
        #expect(store.settings.endTime.minute == 0)
    }
    
    @Test func updateIntervalChangesInterval() async {
        let mockService = MockNotificationService()
        let provider = MockServiceProvider(notificationService: mockService)
        let store = NotificationStore(provider: provider)
        await store.send(.load)
        
        await store.send(.updateInterval(.threeHours))
        
        #expect(store.settings.interval == .threeHours)
    }
    
    @Test func toggleWeekdayAddsAndRemovesWeekday() async {
        let mockService = MockNotificationService()
        let provider = MockServiceProvider(notificationService: mockService)
        let store = NotificationStore(provider: provider)
        await store.send(.load)
        
        let initialCount = store.settings.enabledWeekdays.count
        
        await store.send(.toggleWeekday(.sunday))
        #expect(store.settings.enabledWeekdays.count == initialCount - 1)
        #expect(!store.settings.enabledWeekdays.contains(.sunday))
        
        await store.send(.toggleWeekday(.sunday))
        #expect(store.settings.enabledWeekdays.count == initialCount)
        #expect(store.settings.enabledWeekdays.contains(.sunday))
    }
    
    @Test func addCustomTimeAddsAndSortsTimes() async {
        let mockService = MockNotificationService()
        let provider = MockServiceProvider(notificationService: mockService)
        let store = NotificationStore(provider: provider)
        await store.send(.load)
        
        await store.send(.addCustomTime(NotificationTime(hour: 14, minute: 0)))
        await store.send(.addCustomTime(NotificationTime(hour: 10, minute: 0)))
        await store.send(.addCustomTime(NotificationTime(hour: 12, minute: 0)))
        
        #expect(store.settings.customTimes.count == 3)
        #expect(store.settings.customTimes[0].hour == 10)
        #expect(store.settings.customTimes[1].hour == 12)
        #expect(store.settings.customTimes[2].hour == 14)
    }
    
    @Test func addCustomTimeIgnoresDuplicates() async {
        let mockService = MockNotificationService()
        let provider = MockServiceProvider(notificationService: mockService)
        let store = NotificationStore(provider: provider)
        await store.send(.load)
        
        let time = NotificationTime(hour: 12, minute: 0)
        await store.send(.addCustomTime(time))
        await store.send(.addCustomTime(time))
        
        #expect(store.settings.customTimes.count == 1)
    }
    
    @Test func removeCustomTimeRemovesTime() async {
        let mockService = MockNotificationService()
        let provider = MockServiceProvider(notificationService: mockService)
        let store = NotificationStore(provider: provider)
        await store.send(.load)
        
        let time = NotificationTime(hour: 12, minute: 0)
        await store.send(.addCustomTime(time))
        await store.send(.removeCustomTime(time))
        
        #expect(store.settings.customTimes.isEmpty)
    }
    
    @Test func changesTriggersScheduling() async throws {
        let mockService = MockNotificationService()
        let provider = MockServiceProvider(notificationService: mockService)
        let store = NotificationStore(provider: provider)
        await store.send(.load)
        
        await store.send(.updateInterval(.thirtyMinutes))
        
        let scheduled = try #require(mockService.scheduledSettings)
        #expect(scheduled.interval == .thirtyMinutes)
    }
}
