import Foundation
import Observation
import HealthKit
import UserNotifications

@MainActor
@Observable
final class OnboardingStore {
    enum Action {
        case setGoal(Int)
        case requestHealthKitPermission
        case requestNotificationPermission
        case completeOnboarding
        case skip
    }
    
    let provider: ServiceProviderProtocol
    
    var currentPage: Int = 0
    var goal: Int = 2000
    var isHealthKitAuthorized: Bool = false
    var isNotificationAuthorized: Bool = false
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func send(_ action: Action) async {
        switch action {
        case .setGoal(let value):
            goal = value
            provider.userDefaultsService.set(value: value, forkey: .goal)
            WidgetDataManager.shared.updateGoal(value)
            
        case .requestHealthKitPermission:
            isHealthKitAuthorized = await provider.healthKitService.requestAuthorization()
            
        case .requestNotificationPermission:
            do {
                let center = UNUserNotificationCenter.current()
                isNotificationAuthorized = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                if isNotificationAuthorized {
                    let settings = provider.notificationService.loadSettings()
                    provider.notificationService.scheduleNotifications(with: settings)
                }
            } catch {
                isNotificationAuthorized = false
            }
            
        case .completeOnboarding:
            provider.userDefaultsService.set(value: true, forkey: .onboardingCompleted)
            
        case .skip:
            provider.userDefaultsService.set(value: goal, forkey: .goal)
            WidgetDataManager.shared.updateGoal(goal)
            provider.userDefaultsService.set(value: true, forkey: .onboardingCompleted)
        }
    }
}
