import Foundation

extension UserDefaultsKey {
    static var goal: Key<Int> { return "goal" }
    static var current: Key<[[String: Any]]> { return "current" }
    static var customQuickButtons: Key<[Int]> { return "customQuickButtons" }
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
