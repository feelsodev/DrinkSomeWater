import Foundation
import Observation

@MainActor
@Observable
final class SettingsStore {
  enum Action {
    case loadGoal
    case updateGoal(Int)
    case loadQuickButtons
    case updateQuickButtons([Int])
  }
  
  let provider: ServiceProviderProtocol
  
  var goalValue: Int = 2000
  var quickButtons: [Int] = [100, 200, 300, 500]
  
  var appVersion: String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
  }
  
  init(provider: ServiceProviderProtocol) {
    self.provider = provider
    loadQuickButtonsSync()
  }
  
  private func loadQuickButtonsSync() {
    if let buttons = provider.userDefaultsService.value(forkey: .quickButtons), !buttons.isEmpty {
      quickButtons = buttons
    }
  }
  
  func send(_ action: Action) async {
    switch action {
    case .loadGoal:
      let goal = await provider.waterService.fetchGoal()
      goalValue = goal - goal % 100
      
    case .updateGoal(let value):
      let roundedValue = value - value % 100
      goalValue = roundedValue
      _ = await provider.waterService.updateGoal(to: roundedValue)
      
    case .loadQuickButtons:
      if let buttons = provider.userDefaultsService.value(forkey: .quickButtons), !buttons.isEmpty {
        quickButtons = buttons
      }
      
    case .updateQuickButtons(let buttons):
      quickButtons = buttons
      provider.userDefaultsService.set(value: buttons, forkey: .quickButtons)
    }
  }
}
