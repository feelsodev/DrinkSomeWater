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
        waterRecords.removeAll { Calendar.current.isDate($0.date, inSameDayAs: today) }
        return waterRecords
    }
}

@MainActor
final class MockAlertService: AlertServiceProtocol {
    func show(title: String?, message: String?) async {}
}

@MainActor
final class MockServiceProvider: ServiceProviderProtocol {
    let userDefaultsService: UserDefaultsServiceProtocol
    let waterService: WaterServiceProtocol
    let alertService: AlertServiceProtocol
    let notificationService: NotificationServiceProtocol
    let healthKitService: HealthKitServiceProtocol
    let watchConnectivityService: WatchConnectivityServiceProtocol

    init(
        userDefaultsService: UserDefaultsServiceProtocol = MockUserDefaultsService(),
        waterService: WaterServiceProtocol = MockWaterService(),
        alertService: AlertServiceProtocol = MockAlertService(),
        notificationService: NotificationServiceProtocol = MockNotificationService(),
        healthKitService: HealthKitServiceProtocol = MockHealthKitService(),
        watchConnectivityService: WatchConnectivityServiceProtocol = MockWatchConnectivityService()
    ) {
        self.userDefaultsService = userDefaultsService
        self.waterService = waterService
        self.alertService = alertService
        self.notificationService = notificationService
        self.healthKitService = healthKitService
        self.watchConnectivityService = watchConnectivityService
    }
}
