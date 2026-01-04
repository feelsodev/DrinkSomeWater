import Foundation

extension UserDefaultsKey {
    static var goal: Key<Int> { return "goal" }
    static var current: Key<[[String: Any]]> { return "current" }
    static var customQuickButtons: Key<[Int]> { return "customQuickButtons" }
    static var quickButtons: Key<[Int]> { return "quickButtons" }
    
    // MARK: - Notification Settings
    static var notificationEnabled: Key<Bool> { return "notificationEnabled" }
    static var notificationStartHour: Key<Int> { return "notificationStartHour" }
    static var notificationStartMinute: Key<Int> { return "notificationStartMinute" }
    static var notificationEndHour: Key<Int> { return "notificationEndHour" }
    static var notificationEndMinute: Key<Int> { return "notificationEndMinute" }
    static var notificationIntervalMinutes: Key<Int> { return "notificationIntervalMinutes" }
    static var notificationWeekdays: Key<[Int]> { return "notificationWeekdays" }
    static var notificationCustomTimes: Key<[[String: Int]]> { return "notificationCustomTimes" }
    static var notificationMessage: Key<String> { return "notificationMessage" }
}

protocol UserDefaultsServiceProtocol {
    func value<T>(forkey key: UserDefaultsKey<T>) -> T?
    func set<T>(value: T?, forkey key: UserDefaultsKey<T>)
}

final class UserDefaultsService: BaseService, UserDefaultsServiceProtocol {
    
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    func value<T>(forkey key: UserDefaultsKey<T>) -> T? {
        return defaults.value(forKey: key.key) as? T
    }
    
    func set<T>(value: T?, forkey key: UserDefaultsKey<T>) {
        defaults.set(value, forKey: key.key)
        defaults.synchronize()
    }
}
