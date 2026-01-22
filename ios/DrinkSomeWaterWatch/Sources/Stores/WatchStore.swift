import Foundation
import WatchConnectivity
import WidgetKit

private struct CloudWaterRecord: Codable {
  let dateKey: String
  var value: Int
  var goal: Int
  var isSuccess: Bool
  var modifiedAt: TimeInterval
}

@MainActor
@Observable
final class WatchStore: NSObject {
  var todayWater: Int = 0
  var goal: Int = 2000

  var progress: Float {
    guard goal > 0 else { return 0 }
    return min(Float(todayWater) / Float(goal), 1.0)
  }

  var progressPercent: Int {
    Int(progress * 100)
  }

  private var session: WCSession?
  private let cloudStore = NSUbiquitousKeyValueStore.default
  private var cloudObserver: NSObjectProtocol?
  
  private var isCloudAvailable: Bool {
    FileManager.default.ubiquityIdentityToken != nil
  }

  override init() {
    super.init()
    setupWatchConnectivity()
    setupCloudObserver()
    loadData()
  }

  private func setupWatchConnectivity() {
    guard WCSession.isSupported() else { return }
    session = WCSession.default
    session?.delegate = self
    session?.activate()
  }
  
  private func setupCloudObserver() {
    guard isCloudAvailable else { return }
    cloudStore.synchronize()
    cloudObserver = NotificationCenter.default.addObserver(
      forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
      object: cloudStore,
      queue: .main
    ) { [weak self] _ in
      Task { @MainActor in
        self?.loadFromCloud()
      }
    }
  }

  private func loadData() {
    loadFromCloud()
    if todayWater == 0 && goal == 2000 {
      loadFromUserDefaults()
    }
  }
  
  private func todayDateKey() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = .current
    return formatter.string(from: Date())
  }
  
  private func loadFromCloud() {
    guard isCloudAvailable else { return }
    
    if let cloudGoal = loadGoalFromCloud(), cloudGoal > 0 {
      goal = cloudGoal
    }
    if let cloudWater = loadTodayRecordFromCloud() {
      todayWater = cloudWater
    }
  }
  
  private func loadTodayRecordFromCloud() -> Int? {
    guard isCloudAvailable else { return nil }
    
    let todayKey = "cloud_water_\(todayDateKey())"
    
    guard let data = cloudStore.data(forKey: todayKey) else {
      return nil
    }
    
    struct CloudRecord: Codable {
      let value: Int
    }
    
    guard let record = try? JSONDecoder().decode(CloudRecord.self, from: data) else {
      return nil
    }
    
    return record.value
  }
  
  private func loadGoalFromCloud() -> Int? {
    guard isCloudAvailable else { return nil }
    let value = cloudStore.longLong(forKey: "cloud_goal")
    return value > 0 ? Int(value) : nil
  }

  private func loadFromUserDefaults() {
    let defaults = UserDefaults.standard
    let savedWater = defaults.integer(forKey: "watch_today_water")
    if savedWater > 0 {
      todayWater = savedWater
    }
    let savedGoal = defaults.integer(forKey: "watch_goal")
    if savedGoal > 0 {
      goal = savedGoal
    }
  }

  private func saveToUserDefaults() {
    let defaults = UserDefaults.standard
    defaults.set(todayWater, forKey: "watch_today_water")
    defaults.set(goal, forKey: "watch_goal")
    WidgetCenter.shared.reloadAllTimelines()
  }
  
  private func saveToCloud() {
    guard isCloudAvailable else { return }
    
    let todayKey = "cloud_water_\(todayDateKey())"
    let record = CloudWaterRecord(
      dateKey: todayDateKey(),
      value: todayWater,
      goal: goal,
      isSuccess: todayWater >= goal,
      modifiedAt: Date().timeIntervalSince1970
    )
    
    if let existingData = cloudStore.data(forKey: todayKey),
       let existing = try? JSONDecoder().decode(CloudWaterRecord.self, from: existingData) {
      if existing.modifiedAt >= record.modifiedAt && existing.value >= record.value {
        return
      }
    }
    
    if let data = try? JSONEncoder().encode(record) {
      cloudStore.set(data, forKey: todayKey)
      cloudStore.synchronize()
    }
  }

  func addWater(_ amount: Int) async {
    todayWater += amount
    saveToUserDefaults()
    saveToCloud()
    sendToiPhone(action: "addWater", amount: amount)
  }

  private func sendToiPhone(action: String, amount: Int) {
    guard let session = session, session.isReachable else {
      saveForLaterSync(action: action, amount: amount)
      return
    }

    let message: [String: Any] = [
      "action": action,
      "amount": amount,
      "timestamp": Date().timeIntervalSince1970
    ]

    session.sendMessage(message, replyHandler: nil) { [weak self] _ in
      self?.saveForLaterSync(action: action, amount: amount)
    }
  }

  private func saveForLaterSync(action: String, amount: Int) {
    var pendingActions = UserDefaults.standard.array(forKey: "watch_pending_actions") as? [[String: Any]] ?? []
    pendingActions.append([
      "action": action,
      "amount": amount,
      "timestamp": Date().timeIntervalSince1970
    ])
    UserDefaults.standard.set(pendingActions, forKey: "watch_pending_actions")
  }

  func syncPendingActions() {
    guard let session = session, session.isReachable else { return }
    guard let pendingActions = UserDefaults.standard.array(forKey: "watch_pending_actions") as? [[String: Any]], !pendingActions.isEmpty else { return }

    for action in pendingActions {
      session.sendMessage(action, replyHandler: nil)
    }

    UserDefaults.standard.removeObject(forKey: "watch_pending_actions")
  }
}

extension WatchStore: WCSessionDelegate {
  nonisolated func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    let isActivated = activationState == .activated
    Task { @MainActor in
      if isActivated {
        syncPendingActions()
      }
    }
  }

  nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    let water = message["todayWater"] as? Int
    let newGoal = message["goal"] as? Int
    Task { @MainActor in
      applyUpdate(water: water, goal: newGoal)
    }
  }

  nonisolated func session(
    _ session: WCSession,
    didReceiveMessage message: [String: Any],
    replyHandler: @escaping ([String: Any]) -> Void
  ) {
    let water = message["todayWater"] as? Int
    let newGoal = message["goal"] as? Int
    replyHandler(["status": "received"])
    Task { @MainActor in
      applyUpdate(water: water, goal: newGoal)
    }
  }

  nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
    let water = applicationContext["todayWater"] as? Int
    let newGoal = applicationContext["goal"] as? Int
    Task { @MainActor in
      applyUpdate(water: water, goal: newGoal)
    }
  }

  @MainActor
  private func applyUpdate(water: Int?, goal newGoal: Int?) {
    if let water {
      todayWater = water
    }
    if let newGoal {
      goal = newGoal
    }
    saveToUserDefaults()
  }
}
