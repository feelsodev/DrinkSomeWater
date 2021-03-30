//
//  UserDefaultsService.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/30.
//

import Foundation

extension UserDefaultsKey {
  static var goal: Key<[[String: Any]]> { return "goal" }
  static var current: Key<[[String: Any]]> { return "current" }
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
    return self.defaults.value(forKey: key.key) as? T
  }
  
  func set<T>(value: T?, forkey key: UserDefaultsKey<T>) {
    self.defaults.set(value, forKey: key.key)
    self.defaults.synchronize()
  }
}
