import Foundation
import Observation
import Analytics

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
      let wasAchieved = ml >= total
      _ = await provider.waterService.updateWater(by: Float(amount))
      await send(.refresh)
      
      Analytics.shared.logWaterIntake(amountMl: amount, method: .quickButton)
      
      if !wasAchieved && ml >= total {
        let streakDays = calculateStreak()
        Analytics.shared.logGoalAchieved(goalMl: Int(total), actualMl: Int(ml), streakDays: streakDays)
      }
    }
  }
  
  private func loadQuickButtons() {
    if let buttons = provider.userDefaultsService.value(forkey: .quickButtons), !buttons.isEmpty {
      quickButtons = buttons
    }
  }
  
  private func calculateStreak() -> Int {
    guard let records = provider.userDefaultsService.value(forkey: .current) else { return 1 }
    let waterRecords = records.compactMap(WaterRecord.init).filter { $0.isSuccess }.sorted { $0.date > $1.date }
    
    var streak = 0
    var currentDate = Date()
    let calendar = Calendar.current
    
    for record in waterRecords {
      let daysDiff = calendar.dateComponents([.day], from: record.date, to: currentDate).day ?? 0
      if daysDiff <= 1 {
        streak += 1
        currentDate = record.date
      } else {
        break
      }
    }
    return max(1, streak)
  }
}
