import Foundation
import WatchConnectivity

protocol WatchConnectivityServiceProtocol: AnyObject {
  func activate()
  func syncToWatch(todayWater: Int, goal: Int)
}

final class WatchConnectivityService: NSObject, WatchConnectivityServiceProtocol, @unchecked Sendable {
  weak var provider: ServiceProviderProtocol?
  private var session: WCSession?

  init(provider: ServiceProviderProtocol) {
    self.provider = provider
    super.init()
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
}

extension WatchConnectivityService: WCSessionDelegate {
  func session(
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

  func sessionDidBecomeInactive(_ session: WCSession) {}

  func sessionDidDeactivate(_ session: WCSession) {
    session.activate()
  }

  func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
    handleMessage(message)
  }

  func session(
    _ session: WCSession,
    didReceiveMessage message: [String: Any],
    replyHandler: @escaping ([String: Any]) -> Void
  ) {
    handleMessage(message)
    replyHandler(["status": "received"])
  }

  private func handleMessage(_ message: [String: Any]) {
    guard let action = message["action"] as? String else { return }

    switch action {
    case "addWater":
      if let amount = message["amount"] as? Int {
        Task { @MainActor [weak self] in
          await self?.provider?.waterService.updateWater(by: Float(amount))
        }
      }
    default:
      break
    }
  }

  @MainActor
  private func syncCurrentStateToWatch() async {
    guard let provider = provider else { return }
    let water = await provider.waterService.fetchWater()
    let goal = await provider.waterService.fetchGoal()

    if let todayRecord = water.first(where: { $0.date.checkToday }) {
      syncToWatch(todayWater: todayRecord.value, goal: goal)
    } else {
      syncToWatch(todayWater: 0, goal: goal)
    }
  }
}
