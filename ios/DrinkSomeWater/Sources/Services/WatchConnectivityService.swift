import Foundation
import WatchConnectivity

@MainActor
protocol WatchConnectivityServiceProtocol: AnyObject {
  func activate()
  func syncToWatch(todayWater: Int, goal: Int)
  func setWaterService(_ waterService: WaterServiceProtocol)
}

@MainActor
final class WatchConnectivityService: NSObject, WatchConnectivityServiceProtocol {
  private var waterService: WaterServiceProtocol?
  private var session: WCSession?

  override init() {
    super.init()
  }
  
  func setWaterService(_ waterService: WaterServiceProtocol) {
    self.waterService = waterService
  }

  func activate() {
    guard WCSession.isSupported() else { return }
    session = WCSession.default
    session?.delegate = self
    session?.activate()
  }

  func syncToWatch(todayWater: Int, goal: Int) {
    guard let session = session, session.activationState == .activated else { return }

    let context: [String: Any] = [
      "todayWater": todayWater,
      "goal": goal,
      "timestamp": Date().timeIntervalSince1970
    ]

    do {
      try session.updateApplicationContext(context)
    } catch {
      print("Failed to update application context: \(error)")
    }

    if session.isReachable {
      session.sendMessage(context, replyHandler: nil)
    }
  }
  
  private func syncCurrentStateToWatch() async {
    guard let waterService = waterService else { return }
    let water = await waterService.fetchWater()
    let goal = await waterService.fetchGoal()

    if let todayRecord = water.first(where: { $0.date.checkToday }) {
      syncToWatch(todayWater: todayRecord.value, goal: goal)
    } else {
      syncToWatch(todayWater: 0, goal: goal)
    }
  }
}

extension WatchConnectivityService: WCSessionDelegate {
  nonisolated func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    if activationState == .activated {
      Task { @MainActor [weak self] in
        await self?.syncCurrentStateToWatch()
      }
    }
  }

  nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}

  nonisolated func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }

  nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    handleMessage(message)
  }

  nonisolated func session(
    _ session: WCSession,
    didReceiveMessage message: [String: Any],
    replyHandler: @escaping ([String: Any]) -> Void
  ) {
    handleMessage(message)
    replyHandler(["status": "received"])
  }

  nonisolated private func handleMessage(_ message: [String: Any]) {
    guard let action = message["action"] as? String else { return }

    switch action {
    case "addWater":
      if let amount = message["amount"] as? Int {
        Task { @MainActor [weak self] in
          _ = await self?.waterService?.updateWater(by: Float(amount))
        }
      }
    default:
      break
    }
  }
}
