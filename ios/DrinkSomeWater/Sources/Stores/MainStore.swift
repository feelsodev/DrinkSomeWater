import Foundation
import Observation

@MainActor
@Observable
final class MainStore {
  enum Action {
    case refresh
    case refreshGoal
  }
  
  private let provider: ServiceProviderProtocol
  
  var total: Float = 0
  var ml: Float = 0
  var progress: Float { total == 0 ? 0 : ml / total }
  
  init(provider: ServiceProviderProtocol) {
    self.provider = provider
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
    }
  }
  
  func createDrinkStore() -> DrinkStore {
    DrinkStore(provider: provider)
  }
  
  func createSettingStore() -> SettingStore {
    SettingStore(provider: provider)
  }
  
  func createCalendarStore() -> CalendarStore {
    CalendarStore(provider: provider)
  }
}
