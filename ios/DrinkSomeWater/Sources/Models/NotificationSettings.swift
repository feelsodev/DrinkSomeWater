import Foundation

struct NotificationTime: Codable, Equatable, Hashable {
  var hour: Int
  var minute: Int
  
  var displayString: String {
    String(format: "%02d:%02d", hour, minute)
  }
  
  static func from(dictionary: [String: Int]) -> NotificationTime? {
    guard let hour = dictionary["hour"], let minute = dictionary["minute"] else { return nil }
    return NotificationTime(hour: hour, minute: minute)
  }
  
  func toDictionary() -> [String: Int] {
    ["hour": hour, "minute": minute]
  }
}

enum NotificationInterval: Int, CaseIterable {
  case thirtyMinutes = 30
  case oneHour = 60
  case twoHours = 120
  case threeHours = 180

  var displayString: String {
     switch self {
     case .thirtyMinutes: return L.Interval.thirtyMin
     case .oneHour: return L.Interval.oneHour
     case .twoHours: return L.Interval.twoHours
     case .threeHours: return L.Interval.threeHours
     }
   }
}

enum Weekday: Int, CaseIterable {
  case sunday = 1
  case monday = 2
  case tuesday = 3
  case wednesday = 4
  case thursday = 5
  case friday = 6
  case saturday = 7

  var shortName: String {
     switch self {
     case .sunday: return L.Weekday.sun
     case .monday: return L.Weekday.mon
     case .tuesday: return L.Weekday.tue
     case .wednesday: return L.Weekday.wed
     case .thursday: return L.Weekday.thu
     case .friday: return L.Weekday.fri
     case .saturday: return L.Weekday.sat
     }
   }
}

struct NotificationSettings {
  var isEnabled: Bool
  var startTime: NotificationTime
  var endTime: NotificationTime
  var interval: NotificationInterval
  var enabledWeekdays: Set<Weekday>
  var customTimes: [NotificationTime]
  
  static var `default`: NotificationSettings {
    NotificationSettings(
      isEnabled: true,
      startTime: NotificationTime(hour: 8, minute: 0),
      endTime: NotificationTime(hour: 22, minute: 0),
      interval: .oneHour,
      enabledWeekdays: Set(Weekday.allCases),
      customTimes: []
    )
  }
}
