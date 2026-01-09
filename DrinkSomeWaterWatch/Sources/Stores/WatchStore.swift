import Foundation
import WatchConnectivity
import WidgetKit

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

  override init() {
    super.init()
    setupWatchConnectivity()
    loadFromUserDefaults()
  }

  private func setupWatchConnectivity() {
    guard WCSession.isSupported() else { return }
    session = WCSession.default
    session?.delegate = self
    session?.activate()
  }

  private func loadFromUserDefaults() {
    let defaults = UserDefaults.standard
    todayWater = defaults.integer(forKey: "watch_today_water")
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

  func addWater(_ amount: Int) async {
    todayWater += amount
    saveToUserDefaults()
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
