import Foundation
import WidgetKit
import Analytics

@MainActor
protocol WaterServiceProtocol: AnyObject {
  func fetchWater() async -> [WaterRecord]
  func fetchGoal() async -> Int
  func saveWater(_ waterRecord: [WaterRecord]) async
  func updateWater(by ml: Float) async -> [WaterRecord]
  func updateGoal(to ml: Int) async -> Int
  func resetTodayWater() async -> [WaterRecord]
}

@MainActor
final class WaterService: WaterServiceProtocol {
  
  private let userDefaultsService: UserDefaultsServiceProtocol
  private let watchConnectivityService: WatchConnectivityServiceProtocol
  
  init(
    userDefaultsService: UserDefaultsServiceProtocol,
    watchConnectivityService: WatchConnectivityServiceProtocol
  ) {
    self.userDefaultsService = userDefaultsService
    self.watchConnectivityService = watchConnectivityService
  }
  
  func fetchWater() async -> [WaterRecord] {
    if let currentValue = userDefaultsService.value(forkey: .current) {
      var water = currentValue.compactMap(WaterRecord.init)
      if !water.contains(where: { $0.date.checkToday }) {
        guard let goalWater = userDefaultsService.value(forkey: .goal) else {
          return []
        }
        water.append(WaterRecord(date: Date(), value: 0, isSuccess: false, goal: goalWater))
      }
      await saveWater(water)
      return water
    }
    
    guard let goalWater = userDefaultsService.value(forkey: .goal) else {
      return []
    }
    let waterRecord = WaterRecord(date: Date(), value: 0, isSuccess: false, goal: goalWater)
    let value = waterRecord.asDictionary()
    userDefaultsService.set(value: [value], forkey: .current)
    return [waterRecord]
  }
  
  func fetchGoal() async -> Int {
    guard let goalWater = userDefaultsService.value(forkey: .goal) else {
      return 2000
    }
    return goalWater
  }
  
  func saveWater(_ waterRecord: [WaterRecord]) async {
    let dicts = waterRecord.map { $0.asDictionary() }
    userDefaultsService.set(value: dicts, forkey: .current)
  }
  
  @discardableResult
  func updateWater(by ml: Float) async -> [WaterRecord] {
    var waterRecord = await fetchWater()
    guard let index = waterRecord.firstIndex(where: { $0.date.checkToday }) else {
      return []
    }
    
    var newRecord = waterRecord[index]
    newRecord.value += Int(ml)
    newRecord.date = Date()
    newRecord.isSuccess = newRecord.value >= newRecord.goal
    waterRecord[index] = newRecord
    
    await saveWater(waterRecord)

    WidgetDataManager.shared.syncFromMainApp(todayWater: newRecord.value, goal: newRecord.goal)
    watchConnectivityService.syncToWatch(todayWater: newRecord.value, goal: newRecord.goal)

    return waterRecord
  }
  
  @discardableResult
  func updateGoal(to ml: Int) async -> Int {
    if let currentValue = userDefaultsService.value(forkey: .current) {
      var waterRecord = currentValue.compactMap(WaterRecord.init)
      guard let index = waterRecord.firstIndex(where: { $0.date.checkToday }) else {
        userDefaultsService.set(value: ml, forkey: .goal)
        WidgetDataManager.shared.updateGoal(ml)
        WidgetDataManager.shared.reloadWidgets()
        return ml
      }
      
      var newRecord = waterRecord[index]
      newRecord.goal = ml
      newRecord.isSuccess = newRecord.value >= newRecord.goal
      waterRecord[index] = newRecord
      
      await saveWater(waterRecord)
      WidgetDataManager.shared.syncFromMainApp(todayWater: newRecord.value, goal: ml)
      watchConnectivityService.syncToWatch(todayWater: newRecord.value, goal: ml)
    }
    userDefaultsService.set(value: ml, forkey: .goal)
    WidgetDataManager.shared.updateGoal(ml)
    return ml
  }

  @discardableResult
  func resetTodayWater() async -> [WaterRecord] {
    var waterRecord = await fetchWater()
    guard let index = waterRecord.firstIndex(where: { $0.date.checkToday }) else {
      return []
    }

    var newRecord = waterRecord[index]
    newRecord.value = 0
    newRecord.date = Date()
    newRecord.isSuccess = false
    waterRecord[index] = newRecord

    await saveWater(waterRecord)

    WidgetDataManager.shared.syncFromMainApp(todayWater: 0, goal: newRecord.goal)
    watchConnectivityService.syncToWatch(todayWater: 0, goal: newRecord.goal)

    return waterRecord
  }
}
