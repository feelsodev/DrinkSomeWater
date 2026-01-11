import Foundation
import WidgetKit
import Analytics

protocol WaterServiceProtocol {
  func fetchWater() async -> [WaterRecord]
  func fetchGoal() async -> Int
  func saveWater(_ waterRecord: [WaterRecord]) async
  func updateWater(by ml: Float) async -> [WaterRecord]
  func updateGoal(to ml: Int) async -> Int
  func resetTodayWater() async -> [WaterRecord]
}

final class WaterService: BaseService, WaterServiceProtocol {
  
  func fetchWater() async -> [WaterRecord] {
    if let currentValue = provider.userDefaultsService.value(forkey: .current) {
      var water = currentValue.compactMap(WaterRecord.init)
      if !water.contains(where: { $0.date.checkToday }) {
        guard let goalWater = provider.userDefaultsService.value(forkey: .goal) else {
          return []
        }
        water.append(WaterRecord(date: Date(), value: 0, isSuccess: false, goal: goalWater))
      }
      await saveWater(water)
      return water
    }
    
    guard let goalWater = provider.userDefaultsService.value(forkey: .goal) else {
      return []
    }
    let waterRecord = WaterRecord(date: Date(), value: 0, isSuccess: false, goal: goalWater)
    let value = waterRecord.asDictionary()
    provider.userDefaultsService.set(value: [value], forkey: .current)
    return [waterRecord]
  }
  
  func fetchGoal() async -> Int {
    guard let goalWater = provider.userDefaultsService.value(forkey: .goal) else {
      return 2000
    }
    return goalWater
  }
  
  func saveWater(_ waterRecord: [WaterRecord]) async {
    let dicts = waterRecord.map { $0.asDictionary() }
    provider.userDefaultsService.set(value: dicts, forkey: .current)
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
    provider.watchConnectivityService.syncToWatch(todayWater: newRecord.value, goal: newRecord.goal)

    return waterRecord
  }
  
  @discardableResult
  func updateGoal(to ml: Int) async -> Int {
    if let currentValue = provider.userDefaultsService.value(forkey: .current) {
      var waterRecord = currentValue.compactMap(WaterRecord.init)
      guard let index = waterRecord.firstIndex(where: { $0.date.checkToday }) else {
        provider.userDefaultsService.set(value: ml, forkey: .goal)
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
      provider.watchConnectivityService.syncToWatch(todayWater: newRecord.value, goal: ml)
    }
    provider.userDefaultsService.set(value: ml, forkey: .goal)
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
    provider.watchConnectivityService.syncToWatch(todayWater: 0, goal: newRecord.goal)

    return waterRecord
  }
}
