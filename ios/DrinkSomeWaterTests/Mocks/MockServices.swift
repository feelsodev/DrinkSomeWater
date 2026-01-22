import Foundation
@testable import DrinkSomeWater

@MainActor
final class MockNotificationService: NotificationServiceProtocol {
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

@MainActor
final class MockWatchConnectivityService: WatchConnectivityServiceProtocol {
    func activate() {}
    func syncToWatch(todayWater: Int, goal: Int) {}
    func setWaterService(_ waterService: WaterServiceProtocol) {}
}

@MainActor
final class MockHealthKitService: HealthKitServiceProtocol {
    var isAvailable: Bool { false }
    func requestAuthorization() async -> Bool { false }
    func fetchWeight() async -> Double? { nil }
    func saveWaterIntake(_ ml: Double, date: Date) async -> Bool { false }
    func fetchTodayWaterIntake() async -> Double { 0 }
}

@MainActor
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

@MainActor
final class MockWaterService: WaterServiceProtocol {
    var waterRecords: [WaterRecord] = []
    var goal: Int = 2000

    func fetchWater() async -> [WaterRecord] { waterRecords }
    func fetchGoal() async -> Int { goal }
    func saveWater(_ waterRecord: [WaterRecord]) async { waterRecords = waterRecord }
    func updateWater(by ml: Float) async -> [WaterRecord] {
        let today = Calendar.current.startOfDay(for: Date())
        if let index = waterRecords.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            let currentRecord = waterRecords[index]
            let newValue = currentRecord.value + Int(ml)
            waterRecords[index] = WaterRecord(
                date: today,
                value: newValue,
                isSuccess: newValue >= currentRecord.goal,
                goal: currentRecord.goal
            )
        } else {
            waterRecords.append(WaterRecord(
                date: today,
                value: Int(ml),
                isSuccess: Int(ml) >= goal,
                goal: goal
            ))
        }
        return waterRecords
    }
    func updateGoal(to ml: Int) async -> Int {
        goal = ml
        return goal
    }
    func resetTodayWater() async -> [WaterRecord] {
        let today = Calendar.current.startOfDay(for: Date())
        if let index = waterRecords.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            let record = waterRecords[index]
            waterRecords[index] = WaterRecord(date: today, value: 0, isSuccess: false, goal: record.goal)
        }
        return waterRecords
    }
}

@MainActor
final class MockAlertService: AlertServiceProtocol {
    func show(title: String?, message: String?) async {}
}

@MainActor
final class MockCloudSyncService: CloudSyncServiceProtocol {
    var mockIsCloudAvailable = true
    var mockWaterRecords: [String: CloudWaterRecord] = [:]
    var mockGoal: Int?
    var mockQuickButtons: [Int]?
    var mockCustomQuickButtons: [Int]?
    var mockNotificationEnabled: Bool?
    var mockNotificationStartHour: Int?
    var mockNotificationStartMinute: Int?
    var mockNotificationEndHour: Int?
    var mockNotificationEndMinute: Int?
    var mockNotificationIntervalMinutes: Int?
    var mockNotificationWeekdays: [Int]?
    var mockNotificationCustomTimes: [[String: Int]]?
    var mockUserWeight: Double?
    var mockUseHealthKitWeight: Bool?
    var mockOnboardingCompleted: Bool?
    
    var requestSyncCallCount = 0
    var migrateCallCount = 0
    var changeHandler: (@MainActor () -> Void)?
    var errorHandler: (@MainActor (CloudSyncError) -> Void)?
    
    var isCloudAvailable: Bool { mockIsCloudAvailable }
    
    func requestSync() { requestSyncCallCount += 1 }
    
    func migrateFromUserDefaultsIfNeeded(userDefaultsService: UserDefaultsServiceProtocol) {
        migrateCallCount += 1
    }
    
    func saveWaterRecord(_ record: CloudWaterRecord) {
        if let existing = mockWaterRecords[record.dateKey] {
            if existing.modifiedAt >= record.modifiedAt && existing.value >= record.value {
                return
            }
        }
        mockWaterRecords[record.dateKey] = record
    }
    
    func loadWaterRecords() -> [String: CloudWaterRecord] { mockWaterRecords }
    
    func loadTodayRecord() -> CloudWaterRecord? {
        let todayKey = CloudWaterRecord.dateKey(from: Date())
        return mockWaterRecords[todayKey]
    }
    
    func mergeWaterRecords(local: [WaterRecord]) -> [WaterRecord] {
        var merged: [String: WaterRecord] = [:]
        
        for record in local {
            let dateKey = CloudWaterRecord.dateKey(from: record.date)
            merged[dateKey] = record
        }
        
        for (dateKey, cloudRecord) in mockWaterRecords {
            if let localRecord = merged[dateKey] {
                let localModified = localRecord.date.timeIntervalSince1970
                if cloudRecord.modifiedAt > localModified {
                    if let date = CloudWaterRecord.date(from: dateKey) {
                        merged[dateKey] = WaterRecord(
                            date: date,
                            value: cloudRecord.value,
                            isSuccess: cloudRecord.isSuccess,
                            goal: cloudRecord.goal
                        )
                    }
                } else if cloudRecord.modifiedAt == localModified && cloudRecord.value > localRecord.value {
                    if let date = CloudWaterRecord.date(from: dateKey) {
                        merged[dateKey] = WaterRecord(
                            date: date,
                            value: cloudRecord.value,
                            isSuccess: cloudRecord.isSuccess,
                            goal: cloudRecord.goal
                        )
                    }
                }
            } else {
                if let date = CloudWaterRecord.date(from: dateKey) {
                    merged[dateKey] = WaterRecord(
                        date: date,
                        value: cloudRecord.value,
                        isSuccess: cloudRecord.isSuccess,
                        goal: cloudRecord.goal
                    )
                }
            }
        }
        
        return merged.values.sorted { $0.date > $1.date }
    }
    
    func saveGoal(_ goal: Int) { mockGoal = goal }
    func loadGoal() -> Int? { mockGoal }
    
    func saveQuickButtons(_ buttons: [Int]) { mockQuickButtons = buttons }
    func loadQuickButtons() -> [Int]? { mockQuickButtons }
    func saveCustomQuickButtons(_ buttons: [Int]) { mockCustomQuickButtons = buttons }
    func loadCustomQuickButtons() -> [Int]? { mockCustomQuickButtons }
    
    func saveNotificationSettings(
        enabled: Bool,
        startHour: Int,
        startMinute: Int,
        endHour: Int,
        endMinute: Int,
        intervalMinutes: Int,
        weekdays: [Int],
        customTimes: [[String: Int]]
    ) {
        mockNotificationEnabled = enabled
        mockNotificationStartHour = startHour
        mockNotificationStartMinute = startMinute
        mockNotificationEndHour = endHour
        mockNotificationEndMinute = endMinute
        mockNotificationIntervalMinutes = intervalMinutes
        mockNotificationWeekdays = weekdays
        mockNotificationCustomTimes = customTimes
    }
    
    func loadNotificationEnabled() -> Bool? { mockNotificationEnabled }
    func loadNotificationStartHour() -> Int? { mockNotificationStartHour }
    func loadNotificationStartMinute() -> Int? { mockNotificationStartMinute }
    func loadNotificationEndHour() -> Int? { mockNotificationEndHour }
    func loadNotificationEndMinute() -> Int? { mockNotificationEndMinute }
    func loadNotificationIntervalMinutes() -> Int? { mockNotificationIntervalMinutes }
    func loadNotificationWeekdays() -> [Int]? { mockNotificationWeekdays }
    func loadNotificationCustomTimes() -> [[String: Int]]? { mockNotificationCustomTimes }
    
    func saveUserWeight(_ weight: Double) { mockUserWeight = weight }
    func loadUserWeight() -> Double? { mockUserWeight }
    func saveUseHealthKitWeight(_ use: Bool) { mockUseHealthKitWeight = use }
    func loadUseHealthKitWeight() -> Bool? { mockUseHealthKitWeight }
    
    func saveOnboardingCompleted(_ completed: Bool) { mockOnboardingCompleted = completed }
    func loadOnboardingCompleted() -> Bool? { mockOnboardingCompleted }
    
    func startObservingChanges(handler: @escaping @MainActor () -> Void) {
        changeHandler = handler
    }
    
    func startObservingErrors(handler: @escaping @MainActor (CloudSyncError) -> Void) {
        errorHandler = handler
    }
    
    func stopObservingChanges() {
        changeHandler = nil
        errorHandler = nil
    }
    
    func simulateExternalChange() {
        changeHandler?()
    }
    
    func simulateError(_ error: CloudSyncError) {
        errorHandler?(error)
    }
}

@MainActor
final class MockServiceProvider: ServiceProviderProtocol {
    let userDefaultsService: UserDefaultsServiceProtocol
    let cloudSyncService: CloudSyncServiceProtocol
    let waterService: WaterServiceProtocol
    let alertService: AlertServiceProtocol
    let notificationService: NotificationServiceProtocol
    let healthKitService: HealthKitServiceProtocol
    let watchConnectivityService: WatchConnectivityServiceProtocol

    init(
        userDefaultsService: UserDefaultsServiceProtocol = MockUserDefaultsService(),
        cloudSyncService: CloudSyncServiceProtocol = MockCloudSyncService(),
        waterService: WaterServiceProtocol = MockWaterService(),
        alertService: AlertServiceProtocol = MockAlertService(),
        notificationService: NotificationServiceProtocol = MockNotificationService(),
        healthKitService: HealthKitServiceProtocol = MockHealthKitService(),
        watchConnectivityService: WatchConnectivityServiceProtocol = MockWatchConnectivityService()
    ) {
        self.userDefaultsService = userDefaultsService
        self.cloudSyncService = cloudSyncService
        self.waterService = waterService
        self.alertService = alertService
        self.notificationService = notificationService
        self.healthKitService = healthKitService
        self.watchConnectivityService = watchConnectivityService
    }
}
