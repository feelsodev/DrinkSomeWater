import Foundation

enum CloudSyncKey: String {
  case goal = "cloud_goal"
  case quickButtons = "cloud_quick_buttons"
  case customQuickButtons = "cloud_custom_quick_buttons"
  case migrationCompleted = "cloud_migration_completed_v2"
  case migrationInProgress = "cloud_migration_in_progress_v2"
  case notificationEnabled = "cloud_notification_enabled"
  case notificationStartHour = "cloud_notification_start_hour"
  case notificationStartMinute = "cloud_notification_start_minute"
  case notificationEndHour = "cloud_notification_end_hour"
  case notificationEndMinute = "cloud_notification_end_minute"
  case notificationIntervalMinutes = "cloud_notification_interval_minutes"
  case notificationWeekdays = "cloud_notification_weekdays"
  case notificationCustomTimes = "cloud_notification_custom_times"
  case userWeight = "cloud_user_weight"
  case useHealthKitWeight = "cloud_use_healthkit_weight"
  case onboardingCompleted = "cloud_onboarding_completed"
}

struct CloudWaterRecord: Codable {
  let dateKey: String
  var value: Int
  var goal: Int
  var isSuccess: Bool
  var modifiedAt: TimeInterval
  
  static func dateKey(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = .current
    return formatter.string(from: date)
  }
  
  static func date(from dateKey: String) -> Date? {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = .current
    return formatter.date(from: dateKey)
  }
}

enum CloudSyncError {
  case quotaViolation
  case accountChanged
}

@MainActor
protocol CloudSyncServiceProtocol: AnyObject {
  var isCloudAvailable: Bool { get }
  
  func requestSync()
  func migrateFromUserDefaultsIfNeeded(userDefaultsService: UserDefaultsServiceProtocol)
  
  func saveWaterRecord(_ record: CloudWaterRecord)
  func loadWaterRecords() -> [String: CloudWaterRecord]
  func loadTodayRecord() -> CloudWaterRecord?
  func mergeWaterRecords(local: [WaterRecord]) -> [WaterRecord]
  
  func saveGoal(_ goal: Int)
  func loadGoal() -> Int?
  
  func saveQuickButtons(_ buttons: [Int])
  func loadQuickButtons() -> [Int]?
  func saveCustomQuickButtons(_ buttons: [Int])
  func loadCustomQuickButtons() -> [Int]?
  
  func saveNotificationSettings(
    enabled: Bool,
    startHour: Int,
    startMinute: Int,
    endHour: Int,
    endMinute: Int,
    intervalMinutes: Int,
    weekdays: [Int],
    customTimes: [[String: Int]]
  )
  func loadNotificationEnabled() -> Bool?
  func loadNotificationStartHour() -> Int?
  func loadNotificationStartMinute() -> Int?
  func loadNotificationEndHour() -> Int?
  func loadNotificationEndMinute() -> Int?
  func loadNotificationIntervalMinutes() -> Int?
  func loadNotificationWeekdays() -> [Int]?
  func loadNotificationCustomTimes() -> [[String: Int]]?
  
  func saveUserWeight(_ weight: Double)
  func loadUserWeight() -> Double?
  func saveUseHealthKitWeight(_ use: Bool)
  func loadUseHealthKitWeight() -> Bool?
  
  func saveOnboardingCompleted(_ completed: Bool)
  func loadOnboardingCompleted() -> Bool?
  
  func startObservingChanges(handler: @escaping @MainActor () -> Void)
  func startObservingErrors(handler: @escaping @MainActor (CloudSyncError) -> Void)
  func stopObservingChanges()
}

@MainActor
final class CloudSyncService: CloudSyncServiceProtocol {
  
  private let cloudStore = NSUbiquitousKeyValueStore.default
  private var changeObserver: NSObjectProtocol?
  private var changeHandler: (@MainActor () -> Void)?
  private var errorHandler: (@MainActor (CloudSyncError) -> Void)?
  
  private var syncWorkItem: DispatchWorkItem?
  private let syncDebounceInterval: TimeInterval = 0.5
  private let maxRecordAge: Int = 730 // 2 years
  
  var isCloudAvailable: Bool {
    FileManager.default.ubiquityIdentityToken != nil
  }
  
  init() {
    if isCloudAvailable {
      cloudStore.synchronize()
    }
  }
  
  // MARK: - Debounced Sync
  
  func requestSync() {
    syncWorkItem?.cancel()
    
    let workItem = DispatchWorkItem { [weak self] in
      Task { @MainActor in
        self?.performSync()
      }
    }
    syncWorkItem = workItem
    DispatchQueue.main.asyncAfter(deadline: .now() + syncDebounceInterval, execute: workItem)
  }
  
  private func performSync() {
    guard isCloudAvailable else { return }
    cloudStore.synchronize()
  }
  
  // MARK: - Migration
  
  func migrateFromUserDefaultsIfNeeded(userDefaultsService: UserDefaultsServiceProtocol) {
    guard isCloudAvailable else { return }
    
    if cloudStore.bool(forKey: CloudSyncKey.migrationCompleted.rawValue) {
      return
    }
    
    if cloudStore.bool(forKey: CloudSyncKey.migrationInProgress.rawValue) {
      cloudStore.set(false, forKey: CloudSyncKey.migrationInProgress.rawValue)
    }
    
    guard let existingRecords = userDefaultsService.value(forkey: .current),
          !existingRecords.isEmpty else {
      cloudStore.set(true, forKey: CloudSyncKey.migrationCompleted.rawValue)
      requestSync()
      return
    }
    
    cloudStore.set(true, forKey: CloudSyncKey.migrationInProgress.rawValue)
    requestSync()
    
    let waterRecords = existingRecords.compactMap(WaterRecord.init)
    for record in waterRecords {
      let dateKey = CloudWaterRecord.dateKey(from: record.date)
      let cloudRecord = CloudWaterRecord(
        dateKey: dateKey,
        value: record.value,
        goal: record.goal,
        isSuccess: record.isSuccess,
        modifiedAt: record.date.timeIntervalSince1970
      )
      saveWaterRecord(cloudRecord)
    }
    
    if let goal = userDefaultsService.value(forkey: .goal) {
      saveGoal(goal)
    }
    
    if let quickButtons = userDefaultsService.value(forkey: .quickButtons) {
      saveQuickButtons(quickButtons)
    }
    if let customQuickButtons = userDefaultsService.value(forkey: .customQuickButtons) {
      saveCustomQuickButtons(customQuickButtons)
    }
    
    let enabled = userDefaultsService.value(forkey: .notificationEnabled) ?? true
    let startHour = userDefaultsService.value(forkey: .notificationStartHour) ?? 8
    let startMinute = userDefaultsService.value(forkey: .notificationStartMinute) ?? 0
    let endHour = userDefaultsService.value(forkey: .notificationEndHour) ?? 22
    let endMinute = userDefaultsService.value(forkey: .notificationEndMinute) ?? 0
    let interval = userDefaultsService.value(forkey: .notificationIntervalMinutes) ?? 120
    let weekdays = userDefaultsService.value(forkey: .notificationWeekdays) ?? Array(1...7)
    let customTimes = userDefaultsService.value(forkey: .notificationCustomTimes) ?? []
    
    saveNotificationSettings(
      enabled: enabled,
      startHour: startHour,
      startMinute: startMinute,
      endHour: endHour,
      endMinute: endMinute,
      intervalMinutes: interval,
      weekdays: weekdays,
      customTimes: customTimes
    )
    
    if let weight = userDefaultsService.value(forkey: .userWeight) {
      saveUserWeight(weight)
    }
    if let useHealthKit = userDefaultsService.value(forkey: .useHealthKitWeight) {
      saveUseHealthKitWeight(useHealthKit)
    }
    
    if let onboarding = userDefaultsService.value(forkey: .onboardingCompleted) {
      saveOnboardingCompleted(onboarding)
    }
    
    cloudStore.set(false, forKey: CloudSyncKey.migrationInProgress.rawValue)
    cloudStore.set(true, forKey: CloudSyncKey.migrationCompleted.rawValue)
    requestSync()
  }
  
  // MARK: - Water Records (Per-Day Keyed)
  
  private func waterRecordKey(for dateKey: String) -> String {
    "cloud_water_\(dateKey)"
  }
  
  func saveWaterRecord(_ record: CloudWaterRecord) {
    guard isCloudAvailable else { return }
    
    let key = waterRecordKey(for: record.dateKey)
    
    if let existingData = cloudStore.data(forKey: key),
       let existing = try? JSONDecoder().decode(CloudWaterRecord.self, from: existingData) {
      if existing.modifiedAt >= record.modifiedAt && existing.value >= record.value {
        return
      }
    }
    
    if let data = try? JSONEncoder().encode(record) {
      cloudStore.set(data, forKey: key)
      requestSync()
    }
    
    pruneOldRecords()
  }
  
  func loadWaterRecords() -> [String: CloudWaterRecord] {
    guard isCloudAvailable else { return [:] }
    
    var records: [String: CloudWaterRecord] = [:]
    let allKeys = cloudStore.dictionaryRepresentation.keys
    
    for key in allKeys where key.hasPrefix("cloud_water_") {
      if let data = cloudStore.data(forKey: key),
         let record = try? JSONDecoder().decode(CloudWaterRecord.self, from: data) {
        records[record.dateKey] = record
      }
    }
    
    return records
  }
  
  func loadTodayRecord() -> CloudWaterRecord? {
    guard isCloudAvailable else { return nil }
    
    let todayKey = CloudWaterRecord.dateKey(from: Date())
    let key = waterRecordKey(for: todayKey)
    
    guard let data = cloudStore.data(forKey: key),
          let record = try? JSONDecoder().decode(CloudWaterRecord.self, from: data) else {
      return nil
    }
    
    return record
  }
  
  func mergeWaterRecords(local: [WaterRecord]) -> [WaterRecord] {
    let cloudRecords = loadWaterRecords()
    var merged: [String: WaterRecord] = [:]
    
    for record in local {
      let dateKey = CloudWaterRecord.dateKey(from: record.date)
      merged[dateKey] = record
    }
    
    for (dateKey, cloudRecord) in cloudRecords {
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
  
  private func pruneOldRecords() {
    guard isCloudAvailable else { return }
    
    let calendar = Calendar.current
    let cutoffDate = calendar.date(byAdding: .day, value: -maxRecordAge, to: Date()) ?? Date()
    let cutoffKey = CloudWaterRecord.dateKey(from: cutoffDate)
    
    let allKeys = cloudStore.dictionaryRepresentation.keys
    for key in allKeys where key.hasPrefix("cloud_water_") {
      let dateKey = String(key.dropFirst("cloud_water_".count))
      if dateKey < cutoffKey {
        cloudStore.removeObject(forKey: key)
      }
    }
  }
  
  // MARK: - Goal
  
  func saveGoal(_ goal: Int) {
    guard isCloudAvailable else { return }
    cloudStore.set(goal, forKey: CloudSyncKey.goal.rawValue)
    requestSync()
  }
  
  func loadGoal() -> Int? {
    guard isCloudAvailable else { return nil }
    let value = cloudStore.longLong(forKey: CloudSyncKey.goal.rawValue)
    return value > 0 ? Int(value) : nil
  }
  
  // MARK: - Quick Buttons
  
  func saveQuickButtons(_ buttons: [Int]) {
    guard isCloudAvailable else { return }
    cloudStore.set(buttons, forKey: CloudSyncKey.quickButtons.rawValue)
    requestSync()
  }
  
  func loadQuickButtons() -> [Int]? {
    guard isCloudAvailable else { return nil }
    return cloudStore.array(forKey: CloudSyncKey.quickButtons.rawValue) as? [Int]
  }
  
  func saveCustomQuickButtons(_ buttons: [Int]) {
    guard isCloudAvailable else { return }
    cloudStore.set(buttons, forKey: CloudSyncKey.customQuickButtons.rawValue)
    requestSync()
  }
  
  func loadCustomQuickButtons() -> [Int]? {
    guard isCloudAvailable else { return nil }
    return cloudStore.array(forKey: CloudSyncKey.customQuickButtons.rawValue) as? [Int]
  }
  
  // MARK: - Notification Settings
  
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
    guard isCloudAvailable else { return }
    cloudStore.set(enabled, forKey: CloudSyncKey.notificationEnabled.rawValue)
    cloudStore.set(startHour, forKey: CloudSyncKey.notificationStartHour.rawValue)
    cloudStore.set(startMinute, forKey: CloudSyncKey.notificationStartMinute.rawValue)
    cloudStore.set(endHour, forKey: CloudSyncKey.notificationEndHour.rawValue)
    cloudStore.set(endMinute, forKey: CloudSyncKey.notificationEndMinute.rawValue)
    cloudStore.set(intervalMinutes, forKey: CloudSyncKey.notificationIntervalMinutes.rawValue)
    cloudStore.set(weekdays, forKey: CloudSyncKey.notificationWeekdays.rawValue)
    cloudStore.set(customTimes, forKey: CloudSyncKey.notificationCustomTimes.rawValue)
    requestSync()
  }
  
  func loadNotificationEnabled() -> Bool? {
    guard isCloudAvailable else { return nil }
    return cloudStore.object(forKey: CloudSyncKey.notificationEnabled.rawValue) as? Bool
  }
  
  func loadNotificationStartHour() -> Int? {
    guard isCloudAvailable else { return nil }
    let value = cloudStore.longLong(forKey: CloudSyncKey.notificationStartHour.rawValue)
    return cloudStore.object(forKey: CloudSyncKey.notificationStartHour.rawValue) != nil ? Int(value) : nil
  }
  
  func loadNotificationStartMinute() -> Int? {
    guard isCloudAvailable else { return nil }
    let value = cloudStore.longLong(forKey: CloudSyncKey.notificationStartMinute.rawValue)
    return cloudStore.object(forKey: CloudSyncKey.notificationStartMinute.rawValue) != nil ? Int(value) : nil
  }
  
  func loadNotificationEndHour() -> Int? {
    guard isCloudAvailable else { return nil }
    let value = cloudStore.longLong(forKey: CloudSyncKey.notificationEndHour.rawValue)
    return cloudStore.object(forKey: CloudSyncKey.notificationEndHour.rawValue) != nil ? Int(value) : nil
  }
  
  func loadNotificationEndMinute() -> Int? {
    guard isCloudAvailable else { return nil }
    let value = cloudStore.longLong(forKey: CloudSyncKey.notificationEndMinute.rawValue)
    return cloudStore.object(forKey: CloudSyncKey.notificationEndMinute.rawValue) != nil ? Int(value) : nil
  }
  
  func loadNotificationIntervalMinutes() -> Int? {
    guard isCloudAvailable else { return nil }
    let value = cloudStore.longLong(forKey: CloudSyncKey.notificationIntervalMinutes.rawValue)
    return cloudStore.object(forKey: CloudSyncKey.notificationIntervalMinutes.rawValue) != nil ? Int(value) : nil
  }
  
  func loadNotificationWeekdays() -> [Int]? {
    guard isCloudAvailable else { return nil }
    return cloudStore.array(forKey: CloudSyncKey.notificationWeekdays.rawValue) as? [Int]
  }
  
  func loadNotificationCustomTimes() -> [[String: Int]]? {
    guard isCloudAvailable else { return nil }
    return cloudStore.array(forKey: CloudSyncKey.notificationCustomTimes.rawValue) as? [[String: Int]]
  }
  
  // MARK: - User Profile
  
  func saveUserWeight(_ weight: Double) {
    guard isCloudAvailable else { return }
    cloudStore.set(weight, forKey: CloudSyncKey.userWeight.rawValue)
    requestSync()
  }
  
  func loadUserWeight() -> Double? {
    guard isCloudAvailable else { return nil }
    let value = cloudStore.double(forKey: CloudSyncKey.userWeight.rawValue)
    return value > 0 ? value : nil
  }
  
  func saveUseHealthKitWeight(_ use: Bool) {
    guard isCloudAvailable else { return }
    cloudStore.set(use, forKey: CloudSyncKey.useHealthKitWeight.rawValue)
    requestSync()
  }
  
  func loadUseHealthKitWeight() -> Bool? {
    guard isCloudAvailable else { return nil }
    return cloudStore.object(forKey: CloudSyncKey.useHealthKitWeight.rawValue) as? Bool
  }
  
  // MARK: - Onboarding
  
  func saveOnboardingCompleted(_ completed: Bool) {
    guard isCloudAvailable else { return }
    cloudStore.set(completed, forKey: CloudSyncKey.onboardingCompleted.rawValue)
    requestSync()
  }
  
  func loadOnboardingCompleted() -> Bool? {
    guard isCloudAvailable else { return nil }
    return cloudStore.object(forKey: CloudSyncKey.onboardingCompleted.rawValue) as? Bool
  }
  
  // MARK: - Change Observation
  
  func startObservingChanges(handler: @escaping @MainActor () -> Void) {
    self.changeHandler = handler
    setupObserverIfNeeded()
  }
  
  func startObservingErrors(handler: @escaping @MainActor (CloudSyncError) -> Void) {
    self.errorHandler = handler
    setupObserverIfNeeded()
  }
  
  private func setupObserverIfNeeded() {
    guard changeObserver == nil else { return }
    
    self.changeObserver = NotificationCenter.default.addObserver(
      forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
      object: self.cloudStore,
      queue: .main
    ) { [weak self] notification in
      guard let self else { return }
      
      guard let userInfo = notification.userInfo,
            let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
        return
      }
      
      Task { @MainActor in
        switch reason {
        case NSUbiquitousKeyValueStoreServerChange,
             NSUbiquitousKeyValueStoreInitialSyncChange:
          self.changeHandler?()
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
          self.errorHandler?(.quotaViolation)
        case NSUbiquitousKeyValueStoreAccountChange:
          self.errorHandler?(.accountChanged)
        default:
          break
        }
      }
    }
  }
  
  func stopObservingChanges() {
    if let observer = changeObserver {
      NotificationCenter.default.removeObserver(observer)
      changeObserver = nil
    }
    changeHandler = nil
    errorHandler = nil
  }
}
