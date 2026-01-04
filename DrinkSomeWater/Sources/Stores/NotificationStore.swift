import Foundation
import Observation

@MainActor
@Observable
final class NotificationStore {
    enum Action {
        case load
        case toggleEnabled(Bool)
        case updateStartTime(NotificationTime)
        case updateEndTime(NotificationTime)
        case updateInterval(NotificationInterval)
        case toggleWeekday(Weekday)
        case addCustomTime(NotificationTime)
        case removeCustomTime(NotificationTime)
        case updateMessage(String)
        case save
    }
    
    let provider: ServiceProviderProtocol
    
    var settings: NotificationSettings = .default
    var isAuthorized: Bool = false
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func send(_ action: Action) async {
        switch action {
        case .load:
            settings = provider.notificationService.loadSettings()
            isAuthorized = await provider.notificationService.requestAuthorization()
            
        case .toggleEnabled(let enabled):
            settings.isEnabled = enabled
            await applySettings()
            
        case .updateStartTime(let time):
            settings.startTime = time
            await applySettings()
            
        case .updateEndTime(let time):
            settings.endTime = time
            await applySettings()
            
        case .updateInterval(let interval):
            settings.interval = interval
            await applySettings()
            
        case .toggleWeekday(let weekday):
            if settings.enabledWeekdays.contains(weekday) {
                settings.enabledWeekdays.remove(weekday)
            } else {
                settings.enabledWeekdays.insert(weekday)
            }
            await applySettings()
            
        case .addCustomTime(let time):
            if !settings.customTimes.contains(time) {
                settings.customTimes.append(time)
                settings.customTimes.sort { ($0.hour * 60 + $0.minute) < ($1.hour * 60 + $1.minute) }
            }
            await applySettings()
            
        case .removeCustomTime(let time):
            settings.customTimes.removeAll { $0 == time }
            await applySettings()
            
        case .updateMessage(let message):
            settings.customMessage = message
            await applySettings()
            
        case .save:
            await applySettings()
        }
    }
    
    private func applySettings() async {
        provider.notificationService.saveSettings(settings)
        provider.notificationService.scheduleNotifications(with: settings)
    }
}
