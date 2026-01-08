import Foundation
import Observation
import HealthKit
import UserNotifications
import Analytics

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
      let oldGoal = goal
      goal = value
      provider.userDefaultsService.set(value: value, forkey: .goal)
      WidgetDataManager.shared.updateGoal(value)
      Analytics.shared.log(.goalChanged(oldGoal: oldGoal, newGoal: value, source: .onboarding))
      Analytics.shared.setDailyGoal(value)
      
    case .requestHealthKitPermission:
      Analytics.shared.log(.permissionRequested(type: .healthKit))
      isHealthKitAuthorized = await provider.healthKitService.requestAuthorization()
      if isHealthKitAuthorized {
        Analytics.shared.log(.permissionGranted(type: .healthKit))
        Analytics.shared.setHealthKitEnabled(true)
      } else {
        Analytics.shared.log(.permissionDenied(type: .healthKit))
      }
      
    case .requestNotificationPermission:
      Analytics.shared.log(.permissionRequested(type: .notification))
      do {
        let center = UNUserNotificationCenter.current()
        isNotificationAuthorized = try await center.requestAuthorization(options: [.alert, .badge, .sound])
        if isNotificationAuthorized {
          Analytics.shared.log(.permissionGranted(type: .notification))
          Analytics.shared.setNotificationEnabled(true)
          let settings = provider.notificationService.loadSettings()
          provider.notificationService.scheduleNotifications(with: settings)
        } else {
          Analytics.shared.log(.permissionDenied(type: .notification))
        }
      } catch {
        isNotificationAuthorized = false
        Analytics.shared.log(.permissionDenied(type: .notification))
      }
      
    case .completeOnboarding:
      provider.userDefaultsService.set(value: true, forkey: .onboardingCompleted)
      Analytics.shared.log(.onboardingCompleted(totalTimeSec: 0))
      Analytics.shared.setOnboardingCompleted(true)
      
    case .skip:
      provider.userDefaultsService.set(value: goal, forkey: .goal)
      WidgetDataManager.shared.updateGoal(goal)
      provider.userDefaultsService.set(value: true, forkey: .onboardingCompleted)
      Analytics.shared.log(.onboardingSkipped(step: currentPage))
      Analytics.shared.setOnboardingCompleted(true)
      Analytics.shared.setDailyGoal(goal)
    }
  }
}
