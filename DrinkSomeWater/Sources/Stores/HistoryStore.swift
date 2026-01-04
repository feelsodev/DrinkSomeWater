import Foundation
import Observation

@MainActor
@Observable
final class HistoryStore {
  enum Action {
    case viewDidLoad
    case selectDate(Date)
  }
  
  private let provider: ServiceProviderProtocol
  
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
  
  func send(_ action: Action) async {
    switch action {
    case .viewDidLoad:
      waterRecordList = await provider.waterService.fetchWater()
      successDates = waterRecordList.filter { $0.isSuccess }.map { $0.date.dateToString }
      
    case .selectDate(let date):
      let dateString = date.dateToString
      selectedRecord = waterRecordList.first { $0.date.dateToString == dateString }
    }
  }
}
