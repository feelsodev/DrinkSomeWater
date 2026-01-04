import Foundation
import UserNotifications

protocol NotificationServiceProtocol: AnyObject {
  func loadSettings() -> NotificationSettings
  func saveSettings(_ settings: NotificationSettings)
  func scheduleNotifications(with settings: NotificationSettings)
  func cancelAllNotifications()
  func requestAuthorization() async -> Bool
}

final class NotificationService: BaseService, NotificationServiceProtocol {
  
  private let notificationCenter = UNUserNotificationCenter.current()
  private let notificationTitle = "벌컥벌컥"
  private let maxPendingNotifications = 64
  
  func loadSettings() -> NotificationSettings {
    let defaults = provider.userDefaultsService
    
    let isEnabled = defaults.value(forkey: .notificationEnabled) ?? true
    let startHour = defaults.value(forkey: .notificationStartHour) ?? 8
    let startMinute = defaults.value(forkey: .notificationStartMinute) ?? 0
    let endHour = defaults.value(forkey: .notificationEndHour) ?? 22
    let endMinute = defaults.value(forkey: .notificationEndMinute) ?? 0
    let intervalMinutes = defaults.value(forkey: .notificationIntervalMinutes) ?? 60
    let weekdayValues = defaults.value(forkey: .notificationWeekdays) ?? Array(1...7)
    let customTimeDicts = defaults.value(forkey: .notificationCustomTimes) ?? []
    
    let interval = NotificationInterval(rawValue: intervalMinutes) ?? .oneHour
    let weekdays = Set(weekdayValues.compactMap { Weekday(rawValue: $0) })
    let customTimes = customTimeDicts.compactMap { NotificationTime.from(dictionary: $0) }
    
    return NotificationSettings(
      isEnabled: isEnabled,
      startTime: NotificationTime(hour: startHour, minute: startMinute),
      endTime: NotificationTime(hour: endHour, minute: endMinute),
      interval: interval,
      enabledWeekdays: weekdays,
      customTimes: customTimes
    )
  }
  
  func saveSettings(_ settings: NotificationSettings) {
    let defaults = provider.userDefaultsService
    
    defaults.set(value: settings.isEnabled, forkey: .notificationEnabled)
    defaults.set(value: settings.startTime.hour, forkey: .notificationStartHour)
    defaults.set(value: settings.startTime.minute, forkey: .notificationStartMinute)
    defaults.set(value: settings.endTime.hour, forkey: .notificationEndHour)
    defaults.set(value: settings.endTime.minute, forkey: .notificationEndMinute)
    defaults.set(value: settings.interval.rawValue, forkey: .notificationIntervalMinutes)
    defaults.set(value: settings.enabledWeekdays.map { $0.rawValue }, forkey: .notificationWeekdays)
    defaults.set(value: settings.customTimes.map { $0.toDictionary() }, forkey: .notificationCustomTimes)
  }
  
  func scheduleNotifications(with settings: NotificationSettings) {
    cancelAllNotifications()
    
    guard settings.isEnabled else { return }
    
    if settings.customTimes.isEmpty {
      scheduleIntervalBasedNotifications(with: settings)
    } else {
      scheduleCustomTimeNotifications(with: settings)
    }
  }
  
  func cancelAllNotifications() {
    notificationCenter.removeAllPendingNotificationRequests()
  }
  
  func requestAuthorization() async -> Bool {
    do {
      return try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
    } catch {
      print("Notification authorization error: \(error)")
      return false
    }
  }
  
  private func scheduleIntervalBasedNotifications(with settings: NotificationSettings) {
    let startMinutes = settings.startTime.hour * 60 + settings.startTime.minute
    let endMinutes = settings.endTime.hour * 60 + settings.endTime.minute
    let intervalMinutes = settings.interval.rawValue
    
    var timeSlots: [(hour: Int, minute: Int)] = []
    var currentMinutes = startMinutes
    while currentMinutes <= endMinutes {
      timeSlots.append((currentMinutes / 60, currentMinutes % 60))
      currentMinutes += intervalMinutes
    }
    
    let weekdays = Array(settings.enabledWeekdays)
    let totalRequired = timeSlots.count * weekdays.count
    
    var scheduledCount = 0
    
    if totalRequired <= maxPendingNotifications {
      for (index, slot) in timeSlots.enumerated() {
        for weekday in weekdays {
          scheduleNotification(
            identifier: "drink_\(weekday.rawValue)_\(index)",
            hour: slot.hour,
            minute: slot.minute,
            weekday: weekday.rawValue
          )
          scheduledCount += 1
        }
      }
    } else {
      let slotsPerWeekday = max(1, maxPendingNotifications / weekdays.count)
      let stride = max(1, timeSlots.count / slotsPerWeekday)
      
      for weekday in weekdays {
        var slotIndex = 0
        var notificationIndex = 0
        while slotIndex < timeSlots.count && scheduledCount < maxPendingNotifications {
          let slot = timeSlots[slotIndex]
          scheduleNotification(
            identifier: "drink_\(weekday.rawValue)_\(notificationIndex)",
            hour: slot.hour,
            minute: slot.minute,
            weekday: weekday.rawValue
          )
          scheduledCount += 1
          notificationIndex += 1
          slotIndex += stride
        }
      }
    }
  }
  
  private func scheduleCustomTimeNotifications(with settings: NotificationSettings) {
    let weekdays = Array(settings.enabledWeekdays)
    let totalRequired = settings.customTimes.count * weekdays.count
    var scheduledCount = 0
    
    for (index, time) in settings.customTimes.enumerated() {
      for weekday in weekdays {
        guard scheduledCount < maxPendingNotifications else { return }
        scheduleNotification(
          identifier: "drink_custom_\(weekday.rawValue)_\(index)",
          hour: time.hour,
          minute: time.minute,
          weekday: weekday.rawValue
        )
        scheduledCount += 1
      }
    }
  }
  
  private func scheduleNotification(identifier: String, hour: Int, minute: Int, weekday: Int) {
    let content = UNMutableNotificationContent()
    content.title = notificationTitle
    content.body = NotificationMessages.random
    content.sound = .default
    
    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar.current
    dateComponents.hour = hour
    dateComponents.minute = minute
    dateComponents.weekday = weekday
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    
    notificationCenter.add(request) { error in
      if let error = error {
        print("Failed to schedule notification: \(error)")
      }
    }
  }
}
