import Foundation
import Observation

@MainActor
@Observable
final class HomeStore {
  enum Action {
    case refresh
    case refreshGoal
    case refreshQuickButtons
    case addWater(Int)
  }
  
  let provider: ServiceProviderProtocol
  
  var total: Float = 0
  var ml: Float = 0
  var progress: Float { total == 0 ? 0 : ml / total }
  var remainingMl: Int { max(0, Int(total - ml)) }
  var remainingCups: Int { remainingMl / 250 }
  
  static let defaultQuickButtons = [100, 200, 300, 500]
  var quickButtons: [Int] = HomeStore.defaultQuickButtons
  
  init(provider: ServiceProviderProtocol) {
    self.provider = provider
    loadQuickButtons()
  }
  
  func send(_ action: Action) async {
    switch action {
    case .refresh:
      let records = await provider.waterService.fetchWater()
      if let todayRecord = records.first(where: { $0.date.checkToday }) {
        ml = Float(todayRecord.value)
      }
      
    case .refreshGoal:
      let goal = await provider.waterService.fetchGoal()
      total = Float(goal)
      
    case .refreshQuickButtons:
      loadQuickButtons()
      
    case .addWater(let amount):
      _ = await provider.waterService.updateWater(by: Float(amount))
      await send(.refresh)
    }
  }
  
  private func loadQuickButtons() {
    if let buttons = provider.userDefaultsService.value(forkey: .quickButtons), !buttons.isEmpty {
      quickButtons = buttons
    }
  }
}
