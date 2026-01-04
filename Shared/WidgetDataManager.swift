import Foundation
import WidgetKit

final class WidgetDataManager: @unchecked Sendable {
  
  static let shared = WidgetDataManager()
  static let appGroupIdentifier = "group.com.feelso.DrinkSomeWater"
  
  private let defaults: UserDefaults?
  private let lock = NSLock()
  
  private init() {
    self.defaults = UserDefaults(suiteName: Self.appGroupIdentifier)
  }
  
  private enum Keys {
    static let todayWater = "widget_today_water"
    static let goal = "widget_goal"
    static let lastUpdated = "widget_last_updated"
    static let needsSync = "widget_needs_sync"
    static let pendingWater = "widget_pending_water"
  }
  
  var todayWater: Int {
    lock.withLock {
      defaults?.integer(forKey: Keys.todayWater) ?? 0
    }
  }
  
  var goal: Int {
    lock.withLock {
      let value = defaults?.integer(forKey: Keys.goal) ?? 0
      return value > 0 ? value : 2000
    }
  }
  
  var progress: Float {
    let currentGoal = goal
    let currentWater = todayWater
    guard currentGoal > 0 else { return 0 }
    return min(Float(currentWater) / Float(currentGoal), 1.0)
  }
  
  var progressPercent: Int {
    Int(progress * 100)
  }
  
  var lastUpdated: Date? {
    lock.withLock {
      defaults?.object(forKey: Keys.lastUpdated) as? Date
    }
  }
  
  func updateTodayWater(_ amount: Int) {
    lock.withLock {
      defaults?.set(amount, forKey: Keys.todayWater)
      defaults?.set(Date(), forKey: Keys.lastUpdated)
      defaults?.synchronize()
    }
  }
  
  func updateGoal(_ goal: Int) {
    lock.withLock {
      defaults?.set(goal, forKey: Keys.goal)
      defaults?.synchronize()
    }
  }
  
  func addWater(_ amount: Int) async {
    lock.withLock {
      let newAmount = (defaults?.integer(forKey: Keys.todayWater) ?? 0) + amount
      defaults?.set(newAmount, forKey: Keys.todayWater)
      defaults?.set(Date(), forKey: Keys.lastUpdated)
      defaults?.set(true, forKey: Keys.needsSync)
      defaults?.set(amount, forKey: Keys.pendingWater)
      defaults?.synchronize()
    }
  }
  
  func syncFromMainApp(todayWater: Int, goal: Int) {
    lock.withLock {
      defaults?.set(todayWater, forKey: Keys.todayWater)
      defaults?.set(Date(), forKey: Keys.lastUpdated)
      defaults?.set(goal, forKey: Keys.goal)
      defaults?.synchronize()
    }
    WidgetCenter.shared.reloadAllTimelines()
  }
  
  func checkPendingWaterFromWidget() -> Int? {
    lock.withLock {
      guard defaults?.bool(forKey: Keys.needsSync) == true else { return nil }
      let pendingWater = defaults?.integer(forKey: Keys.pendingWater) ?? 0
      
      defaults?.set(false, forKey: Keys.needsSync)
      defaults?.set(0, forKey: Keys.pendingWater)
      defaults?.synchronize()
      
      return pendingWater > 0 ? pendingWater : nil
    }
  }
  
  func reloadWidgets() {
    WidgetCenter.shared.reloadAllTimelines()
  }
}
