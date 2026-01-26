import Foundation
import Observation
import Analytics

@MainActor
@Observable
final class HistoryStore {
  enum Action {
    case viewDidLoad
    case selectDate(Date)
  }
  
  let provider: ServiceProviderProtocol
  
  var waterRecordList: [WaterRecord] = []
  var successDates: [String] = []
  var selectedRecord: WaterRecord?
  
  var monthlySuccessCount: Int {
    let calendar = Calendar.current
    let now = Date()
    return waterRecordList.filter { record in
      calendar.isDate(record.date, equalTo: now, toGranularity: .month) && record.isSuccess
    }.count
  }
  
  var monthlyTotalDays: Int {
    let calendar = Calendar.current
    let now = Date()
    return waterRecordList.filter { record in
      calendar.isDate(record.date, equalTo: now, toGranularity: .month)
    }.count
  }
  
  init(provider: ServiceProviderProtocol) {
    self.provider = provider
  }
  
  func calculateStreakForDate(_ date: Date) -> Int {
    let waterRecords = waterRecordList.filter { $0.isSuccess }.sorted { $0.date > $1.date }
    
    var streak = 0
    var currentDate = date
    let calendar = Calendar.current
    
    let targetDateString = date.dateToString
    guard waterRecords.contains(where: { $0.date.dateToString == targetDateString }) else {
      return 0
    }
    
    for record in waterRecords {
      let daysDiff = calendar.dateComponents([.day], from: record.date, to: currentDate).day ?? 0
      if daysDiff <= 1 && daysDiff >= 0 {
        streak += 1
        currentDate = record.date
      } else if record.date < currentDate {
        break
      }
    }
    return max(1, streak)
  }
  
  func send(_ action: Action) async {
    switch action {
    case .viewDidLoad:
      waterRecordList = await provider.waterService.fetchWater()
      successDates = waterRecordList.filter { $0.isSuccess }.map { $0.date.dateToString }
      
    case .selectDate(let date):
      let dateString = date.dateToString
      selectedRecord = waterRecordList.first { $0.date.dateToString == dateString }
      
      let hadRecords = selectedRecord != nil
      let wasAchieved = selectedRecord?.isSuccess ?? false
      Analytics.shared.log(.calendarDateSelected(date: date, hadRecords: hadRecords, wasAchieved: wasAchieved))
    }
  }
}
