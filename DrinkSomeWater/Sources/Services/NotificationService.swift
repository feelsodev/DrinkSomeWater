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
        let message = defaults.value(forkey: .notificationMessage) ?? "물 마실 시간이에요! 💧"
        
        let interval = NotificationInterval(rawValue: intervalMinutes) ?? .oneHour
        let weekdays = Set(weekdayValues.compactMap { Weekday(rawValue: $0) })
        let customTimes = customTimeDicts.compactMap { NotificationTime.from(dictionary: $0) }
        
        return NotificationSettings(
            isEnabled: isEnabled,
            startTime: NotificationTime(hour: startHour, minute: startMinute),
            endTime: NotificationTime(hour: endHour, minute: endMinute),
            interval: interval,
            enabledWeekdays: weekdays,
            customTimes: customTimes,
            customMessage: message
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
        defaults.set(value: settings.customMessage, forkey: .notificationMessage)
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
        
        var currentMinutes = startMinutes
        var notificationIndex = 0
        
        while currentMinutes <= endMinutes {
            let hour = currentMinutes / 60
            let minute = currentMinutes % 60
            
            for weekday in settings.enabledWeekdays {
                scheduleNotification(
                    identifier: "drink_\(weekday.rawValue)_\(notificationIndex)",
                    hour: hour,
                    minute: minute,
                    weekday: weekday.rawValue,
                    message: settings.customMessage
                )
            }
            
            currentMinutes += intervalMinutes
            notificationIndex += 1
        }
    }
    
    private func scheduleCustomTimeNotifications(with settings: NotificationSettings) {
        for (index, time) in settings.customTimes.enumerated() {
            for weekday in settings.enabledWeekdays {
                scheduleNotification(
                    identifier: "drink_custom_\(weekday.rawValue)_\(index)",
                    hour: time.hour,
                    minute: time.minute,
                    weekday: weekday.rawValue,
                    message: settings.customMessage
                )
            }
        }
    }
    
    private func scheduleNotification(identifier: String, hour: Int, minute: Int, weekday: Int, message: String) {
        let content = UNMutableNotificationContent()
        content.title = notificationTitle
        content.body = message
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
