import Testing
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
        #expect(NotificationInterval.thirtyMinutes.displayString == "30분")
        #expect(NotificationInterval.oneHour.displayString == "1시간")
        #expect(NotificationInterval.twoHours.displayString == "2시간")
        #expect(NotificationInterval.threeHours.displayString == "3시간")
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
    
    @Test func shortNamesAreKorean() {
        #expect(Weekday.sunday.shortName == "일")
        #expect(Weekday.monday.shortName == "월")
        #expect(Weekday.saturday.shortName == "토")
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
        #expect(settings.customMessage == "물 마실 시간이에요! 💧")
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
}

final class MockServiceProvider: ServiceProviderProtocol, @unchecked Sendable {
    let userDefaultsService: UserDefaultsServiceProtocol
    let waterService: WaterServiceProtocol
    let alertService: AlertServiceProtocol
    let notificationService: NotificationServiceProtocol
    
    init(notificationService: NotificationServiceProtocol = MockNotificationService()) {
        let realProvider = ServiceProvider()
        self.userDefaultsService = UserDefaultsService(provider: realProvider)
        self.waterService = WaterService(provider: realProvider)
        self.alertService = AlertService(provider: realProvider)
        self.notificationService = notificationService
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
            customTimes: [],
            customMessage: "테스트 메시지"
        )
        let provider = MockServiceProvider(notificationService: mockService)
        let store = NotificationStore(provider: provider)
        
        await store.send(.load)
        
        #expect(!store.settings.isEnabled)
        #expect(store.settings.startTime.hour == 9)
        #expect(store.settings.endTime.hour == 21)
        #expect(store.settings.interval == .twoHours)
        #expect(store.settings.enabledWeekdays.count == 3)
        #expect(store.settings.customMessage == "테스트 메시지")
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
    
    @Test func updateMessageChangesMessage() async {
        let mockService = MockNotificationService()
        let provider = MockServiceProvider(notificationService: mockService)
        let store = NotificationStore(provider: provider)
        await store.send(.load)
        
        await store.send(.updateMessage("새로운 알림 메시지"))
        
        #expect(store.settings.customMessage == "새로운 알림 메시지")
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
