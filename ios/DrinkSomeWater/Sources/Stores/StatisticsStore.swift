import Foundation
import Observation
import Analytics

enum StatisticsPeriod: CaseIterable {
  case week
  case month
  
  var displayName: String {
    switch self {
    case .week: return L.Statistics.period7days
    case .month: return L.Statistics.period30days
    }
  }
  
  var analyticsValue: String {
    switch self {
    case .week: return "7days"
    case .month: return "30days"
    }
  }
  
  var days: Int {
    switch self {
    case .week: return 7
    case .month: return 30
    }
  }
}

@MainActor
@Observable
final class StatisticsStore {
  enum Action {
    case viewDidLoad
    case selectPeriod(StatisticsPeriod)
  }
  
  let provider: ServiceProviderProtocol
  
  var selectedPeriod: StatisticsPeriod = .week
  var waterRecords: [WaterRecord] = []
  var isLoading: Bool = false
  
  var dailyAverage: Int {
    let periodDays = selectedPeriod.days
    let filteredRecords = getRecordsForPeriod()
    guard !filteredRecords.isEmpty else { return 0 }
    let totalMl = filteredRecords.reduce(0) { $0 + $1.value }
    return totalMl / periodDays
  }
  
  var goalAchievementRate: Double {
    let filteredRecords = getRecordsForPeriod()
    guard !filteredRecords.isEmpty else { return 0.0 }
    let successCount = filteredRecords.filter { $0.isSuccess }.count
    return Double(successCount) / Double(filteredRecords.count)
  }
  
  var currentStreak: Int {
    let days = uniqueSuccessDays()
    guard !days.isEmpty else { return 0 }
    
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    
    var streak = 0
    var expectedDay = today
    
    for day in days {
      if day == expectedDay {
        streak += 1
        expectedDay = calendar.date(byAdding: .day, value: -1, to: expectedDay)!
      } else if day == calendar.date(byAdding: .day, value: -1, to: today)! && streak == 0 {
        streak += 1
        expectedDay = calendar.date(byAdding: .day, value: -1, to: day)!
      } else if day < expectedDay {
        break
      }
    }
    return streak
  }
  
  var longestStreak: Int {
    let days = uniqueSuccessDays().sorted()
    guard !days.isEmpty else { return 0 }
    
    let calendar = Calendar.current
    var longest = 1
    var current = 1
    
    for i in 1..<days.count {
      let expectedNextDay = calendar.date(byAdding: .day, value: 1, to: days[i - 1])!
      if days[i] == expectedNextDay {
        current += 1
        longest = max(longest, current)
      } else {
        current = 1
      }
    }
    
    return longest
  }
  
  private func uniqueSuccessDays() -> [Date] {
    let calendar = Calendar.current
    let successDates = waterRecords
      .filter { $0.isSuccess }
      .map { calendar.startOfDay(for: $0.date) }
    return Array(Set(successDates)).sorted(by: >)
  }
  
  var dailyData: [(date: Date, amount: Int, goal: Int)] {
    let filteredRecords = getRecordsForPeriod().sorted { $0.date < $1.date }
    return filteredRecords.map { record in
      (date: record.date, amount: record.value, goal: record.goal)
    }
  }
  
  init(provider: ServiceProviderProtocol) {
    self.provider = provider
  }
  
  func send(_ action: Action) async {
    switch action {
    case .viewDidLoad:
      isLoading = true
      waterRecords = await provider.waterService.fetchWater()
      isLoading = false
      
    case .selectPeriod(let period):
      selectedPeriod = period
      Analytics.shared.log(.statisticsPeriodSelected(period: period.analyticsValue))
    }
  }
  
  private func getRecordsForPeriod() -> [WaterRecord] {
    let calendar = Calendar.current
    let now = Date()
    let startOfToday = calendar.startOfDay(for: now)
    let startDate = calendar.date(byAdding: .day, value: -(selectedPeriod.days - 1), to: startOfToday) ?? startOfToday
    
    return waterRecords.filter { record in
      let recordDay = calendar.startOfDay(for: record.date)
      return recordDay >= startDate && recordDay <= startOfToday
    }
  }
}
