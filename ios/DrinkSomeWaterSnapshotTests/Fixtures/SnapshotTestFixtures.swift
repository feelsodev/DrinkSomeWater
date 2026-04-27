import Foundation
import StoreKit
import Analytics
@testable import DrinkSomeWater

@MainActor
final class SnapshotMockStoreKitService: StoreKitServiceProtocol {
    var currentEntitlements: AsyncStream<EntitlementState> {
        AsyncStream { continuation in
            continuation.yield(.free)
            continuation.finish()
        }
    }
    
    var isPremium: Bool { false }
    var isSubscribed: Bool { false }
    var hasWidgetAccess: Bool { false }
    var hasWatchAccess: Bool { false }
    
    func loadProducts() async throws -> [Product] { [] }
    func purchase(_ product: Product) async throws -> Transaction { fatalError() }
    func restorePurchases() async throws { }
}

@MainActor
final class SnapshotMockInstagramSharingService: InstagramSharingServiceProtocol {
    func isInstagramInstalled() -> Bool { false }
    func shareToStories(record: WaterRecord, streak: Int) async throws { }
    func shareToFeed(record: WaterRecord, streak: Int) async throws { }
}

@MainActor
final class SnapshotMockSocialSharingService: SocialSharingServiceProtocol {
    func shareViaSystemSheet(record: WaterRecord, streak: Int, source: InstagramShareSource, from viewController: UIViewController) async throws { }
}

@MainActor
enum SnapshotFixtures {

    static func makeHomeStore(
        ml: Float = 1200,
        total: Float = 2000,
        quickButtons: [Int] = [100, 200, 300, 500],
        showNotificationBanner: Bool = false
    ) -> HomeStore {
        let mockWaterService = MockWaterService()
        mockWaterService.goal = Int(total)
        mockWaterService.waterRecords = [
            WaterRecord(
                date: Date(),
                value: Int(ml),
                isSuccess: ml >= total,
                goal: Int(total)
            )
        ]
        
        let mockUserDefaults = MockUserDefaultsService()
        mockUserDefaults.set(value: quickButtons, forkey: .quickButtons)
        if !showNotificationBanner {
            mockUserDefaults.set(value: true, forkey: .notificationBannerDismissed)
        }
        
        let provider = MockServiceProvider(
            userDefaultsService: mockUserDefaults,
            waterService: mockWaterService
        )
        
        let store = HomeStore(provider: provider)
        store.ml = ml
        store.total = total
        store.quickButtons = quickButtons
        store.showNotificationBanner = showNotificationBanner
        return store
    }
    
    static func makeHistoryStore(records: [WaterRecord]? = nil) -> HistoryStore {
        let mockWaterService = MockWaterService()
        mockWaterService.waterRecords = records ?? sampleWaterRecords
        
        let provider = MockServiceProvider(waterService: mockWaterService)
        let store = HistoryStore(provider: provider)
        store.waterRecordList = mockWaterService.waterRecords
        store.successDates = mockWaterService.waterRecords.filter { $0.isSuccess }.map { $0.date.dateToString }
        return store
    }
    
    static var fixedReferenceDate: Date {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 12
        return Calendar.current.date(from: components) ?? Date()
    }
    
    static var sampleWaterRecords: [WaterRecord] {
        let calendar = Calendar.current
        let referenceDate = fixedReferenceDate
        let fixedValues = [2200, 1800, 2100, 1500, 2300, 1900, 2000, 1700, 2400, 1600,
                          2100, 1850, 2050, 1750, 2250, 1950, 2150, 1650, 2350, 1550,
                          2000, 1800, 2100, 1700, 2200, 1900, 2050, 1850, 2150, 1750]
        
        return (0..<30).compactMap { daysAgo -> WaterRecord? in
            guard let date = calendar.date(byAdding: .day, value: -daysAgo, to: referenceDate) else { return nil }
            let value = fixedValues[daysAgo]
            let goal = 2000
            return WaterRecord(
                date: date,
                value: value,
                isSuccess: value >= goal,
                goal: goal
            )
        }
    }
    
    static var emptyHomeStore: HomeStore {
        makeHomeStore(ml: 0, total: 2000)
    }
    
    static var halfProgressHomeStore: HomeStore {
        makeHomeStore(ml: 1000, total: 2000)
    }
    
    static var goalAchievedHomeStore: HomeStore {
        makeHomeStore(ml: 2200, total: 2000)
    }
    
    static var notificationBannerHomeStore: HomeStore {
        makeHomeStore(showNotificationBanner: true)
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
final class MockNotificationService: NotificationServiceProtocol {
    var savedSettings: NotificationSettings?
    var scheduledSettings: NotificationSettings?
    var cancelAllCalled = false
    var authorizationResult = true

    func loadSettings() -> NotificationSettings { savedSettings ?? .default }
    func saveSettings(_ settings: NotificationSettings) { savedSettings = settings }
    func scheduleNotifications(with settings: NotificationSettings) { scheduledSettings = settings }
    func cancelAllNotifications() { cancelAllCalled = true }
    func requestAuthorization() async -> Bool { authorizationResult }
    func checkAuthorizationStatus() async -> Bool { authorizationResult }
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
final class MockAlertService: AlertServiceProtocol {
    func show(title: String?, message: String?) async {}
}

@MainActor
final class MockCloudSyncService: CloudSyncServiceProtocol {
    var isCloudAvailable: Bool { true }
    func requestSync() {}
    func migrateFromUserDefaultsIfNeeded(userDefaultsService: UserDefaultsServiceProtocol) {}
    func saveWaterRecord(_ record: CloudWaterRecord) {}
    func loadWaterRecords() -> [String: CloudWaterRecord] { [:] }
    func loadTodayRecord() -> CloudWaterRecord? { nil }
    func mergeWaterRecords(local: [WaterRecord]) -> [WaterRecord] { local }
    func saveGoal(_ goal: Int) {}
    func loadGoal() -> Int? { nil }
    func saveQuickButtons(_ buttons: [Int]) {}
    func loadQuickButtons() -> [Int]? { nil }
    func saveCustomQuickButtons(_ buttons: [Int]) {}
    func loadCustomQuickButtons() -> [Int]? { nil }
    func saveNotificationSettings(enabled: Bool, startHour: Int, startMinute: Int, endHour: Int, endMinute: Int, intervalMinutes: Int, weekdays: [Int], customTimes: [[String: Int]]) {}
    func loadNotificationEnabled() -> Bool? { nil }
    func loadNotificationStartHour() -> Int? { nil }
    func loadNotificationStartMinute() -> Int? { nil }
    func loadNotificationEndHour() -> Int? { nil }
    func loadNotificationEndMinute() -> Int? { nil }
    func loadNotificationIntervalMinutes() -> Int? { nil }
    func loadNotificationWeekdays() -> [Int]? { nil }
    func loadNotificationCustomTimes() -> [[String: Int]]? { nil }
    func saveUserWeight(_ weight: Double) {}
    func loadUserWeight() -> Double? { nil }
    func saveUseHealthKitWeight(_ use: Bool) {}
    func loadUseHealthKitWeight() -> Bool? { nil }
    func saveOnboardingCompleted(_ completed: Bool) {}
    func loadOnboardingCompleted() -> Bool? { nil }
    func startObservingChanges(handler: @escaping @MainActor () -> Void) {}
    func startObservingErrors(handler: @escaping @MainActor (CloudSyncError) -> Void) {}
    func stopObservingChanges() {}
}

@MainActor
final class SnapshotMockReviewEligibilityService: ReviewEligibilityServiceProtocol {
    var goalCompletionCount: Int = 0
    var daysSinceInstall: Int = 30
    func recordGoalCompletion() {}
    func shouldRequestReview() -> Bool { false }
    func markReviewRequested() {}
}

@MainActor
final class SnapshotMockFreeDrinkCounterService: FreeDrinkCounterServiceProtocol {
    var drinksToday: Int { 0 }
    var adFrequency: Int { 3 }
    func recordDrink() -> Bool { false }
    func reset() {}
}

@MainActor
final class SnapshotMockRewardedAdCoordinator: RewardedAdCoordinatorProtocol {
    func showRewardedAd() async -> Bool { true }
    func setRootViewController(_ viewController: UIViewController) {}
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
    let instagramSharingService: InstagramSharingServiceProtocol
    let socialSharingService: SocialSharingServiceProtocol
    let storeKitService: StoreKitServiceProtocol
    let reviewEligibilityService: ReviewEligibilityServiceProtocol
    let freeDrinkCounterService: FreeDrinkCounterServiceProtocol
    let rewardedAdCoordinator: RewardedAdCoordinatorProtocol

    init(
        userDefaultsService: UserDefaultsServiceProtocol = MockUserDefaultsService(),
        cloudSyncService: CloudSyncServiceProtocol = MockCloudSyncService(),
        waterService: WaterServiceProtocol = MockWaterService(),
        alertService: AlertServiceProtocol = MockAlertService(),
        notificationService: NotificationServiceProtocol = MockNotificationService(),
        healthKitService: HealthKitServiceProtocol = MockHealthKitService(),
        watchConnectivityService: WatchConnectivityServiceProtocol = MockWatchConnectivityService(),
        instagramSharingService: InstagramSharingServiceProtocol = SnapshotMockInstagramSharingService(),
        socialSharingService: SocialSharingServiceProtocol = SnapshotMockSocialSharingService(),
        storeKitService: StoreKitServiceProtocol = SnapshotMockStoreKitService(),
        reviewEligibilityService: ReviewEligibilityServiceProtocol = SnapshotMockReviewEligibilityService(),
        freeDrinkCounterService: FreeDrinkCounterServiceProtocol = SnapshotMockFreeDrinkCounterService(),
        rewardedAdCoordinator: RewardedAdCoordinatorProtocol = SnapshotMockRewardedAdCoordinator()
    ) {
        self.userDefaultsService = userDefaultsService
        self.cloudSyncService = cloudSyncService
        self.waterService = waterService
        self.alertService = alertService
        self.notificationService = notificationService
        self.healthKitService = healthKitService
        self.watchConnectivityService = watchConnectivityService
        self.instagramSharingService = instagramSharingService
        self.socialSharingService = socialSharingService
        self.storeKitService = storeKitService
        self.reviewEligibilityService = reviewEligibilityService
        self.freeDrinkCounterService = freeDrinkCounterService
        self.rewardedAdCoordinator = rewardedAdCoordinator
    }
}
