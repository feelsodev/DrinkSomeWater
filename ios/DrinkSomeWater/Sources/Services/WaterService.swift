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
  private let cloudSyncService: CloudSyncServiceProtocol
  private let watchConnectivityService: WatchConnectivityServiceProtocol
  
  init(
    userDefaultsService: UserDefaultsServiceProtocol,
    cloudSyncService: CloudSyncServiceProtocol,
    watchConnectivityService: WatchConnectivityServiceProtocol
  ) {
    self.userDefaultsService = userDefaultsService
    self.cloudSyncService = cloudSyncService
    self.watchConnectivityService = watchConnectivityService
  }
  
  func fetchWater() async -> [WaterRecord] {
    var localRecords: [WaterRecord] = []
    
    if let currentValue = userDefaultsService.value(forkey: .current) {
      localRecords = currentValue.compactMap(WaterRecord.init)
    }
    
    let mergedRecords = cloudSyncService.mergeWaterRecords(local: localRecords)
    
    let todayKey = CloudWaterRecord.dateKey(from: Date())
    let hasToday = mergedRecords.contains { CloudWaterRecord.dateKey(from: $0.date) == todayKey }
    
    var finalRecords = mergedRecords
    if !hasToday {
      let goalWater = await fetchGoal()
      let todayRecord = WaterRecord(date: Date(), value: 0, isSuccess: false, goal: goalWater)
      finalRecords.insert(todayRecord, at: 0)
    }
    
    await saveWater(finalRecords)
    return finalRecords
  }
  
  func fetchGoal() async -> Int {
    if let cloudGoal = cloudSyncService.loadGoal() {
      return cloudGoal
    }
    return userDefaultsService.value(forkey: .goal) ?? 2000
  }
  
  func saveWater(_ waterRecord: [WaterRecord]) async {
    let dicts = waterRecord.map { $0.asDictionary() }
    userDefaultsService.set(value: dicts, forkey: .current)
    
    for record in waterRecord {
      let cloudRecord = CloudWaterRecord(
        dateKey: CloudWaterRecord.dateKey(from: record.date),
        value: record.value,
        goal: record.goal,
        isSuccess: record.isSuccess,
        modifiedAt: Date().timeIntervalSince1970
      )
      cloudSyncService.saveWaterRecord(cloudRecord)
    }
  }
  
  @discardableResult
  func updateWater(by ml: Float) async -> [WaterRecord] {
    var waterRecord = await fetchWater()
    
    let todayKey = CloudWaterRecord.dateKey(from: Date())
    guard let index = waterRecord.firstIndex(where: { CloudWaterRecord.dateKey(from: $0.date) == todayKey }) else {
      return []
    }
    
    var newRecord = waterRecord[index]
    newRecord.value = max(0, newRecord.value + Int(ml))
    newRecord.date = Date()
    newRecord.isSuccess = newRecord.value >= newRecord.goal
    waterRecord[index] = newRecord
    
    let dicts = waterRecord.map { $0.asDictionary() }
    userDefaultsService.set(value: dicts, forkey: .current)
    
    let cloudRecord = CloudWaterRecord(
      dateKey: CloudWaterRecord.dateKey(from: newRecord.date),
      value: newRecord.value,
      goal: newRecord.goal,
      isSuccess: newRecord.isSuccess,
      modifiedAt: Date().timeIntervalSince1970
    )
    cloudSyncService.saveWaterRecord(cloudRecord)

    WidgetDataManager.shared.syncFromMainApp(todayWater: newRecord.value, goal: newRecord.goal)
    watchConnectivityService.syncToWatch(todayWater: newRecord.value, goal: newRecord.goal)

    return waterRecord
  }
  
  @discardableResult
  func updateGoal(to ml: Int) async -> Int {
    var waterRecord = await fetchWater()
    
    let todayKey = CloudWaterRecord.dateKey(from: Date())
    if let index = waterRecord.firstIndex(where: { CloudWaterRecord.dateKey(from: $0.date) == todayKey }) {
      var newRecord = waterRecord[index]
      newRecord.goal = ml
      newRecord.isSuccess = newRecord.value >= newRecord.goal
      waterRecord[index] = newRecord
      
      await saveWater(waterRecord)
      WidgetDataManager.shared.syncFromMainApp(todayWater: newRecord.value, goal: ml)
      watchConnectivityService.syncToWatch(todayWater: newRecord.value, goal: ml)
    }
    
    userDefaultsService.set(value: ml, forkey: .goal)
    cloudSyncService.saveGoal(ml)
    WidgetDataManager.shared.updateGoal(ml)
    return ml
  }

  @discardableResult
  func resetTodayWater() async -> [WaterRecord] {
    var waterRecord = await fetchWater()
    
    let todayKey = CloudWaterRecord.dateKey(from: Date())
    guard let index = waterRecord.firstIndex(where: { CloudWaterRecord.dateKey(from: $0.date) == todayKey }) else {
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
