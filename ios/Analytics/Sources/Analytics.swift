import Foundation
import UIKit

#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

#if canImport(FirebaseCrashlytics)
import FirebaseCrashlytics
#endif

@MainActor
public final class Analytics: Sendable {
  
  public static let shared = Analytics()
  
  private let installDateKey = "analytics_install_date"
  private var previousScreen: String?
  
  private init() {}
  
  public func configure() {
    setInstallDateIfNeeded()
    updateDaysSinceInstall()
    setAppVersion()
    print("[Analytics] Configured")
  }
  
  public func log(_ event: AnalyticsEvent) {
    #if canImport(FirebaseAnalytics)
    FirebaseAnalytics.Analytics.logEvent(event.name, parameters: event.parameters)
    #endif
    #if DEBUG
    print("[Analytics] Event: \(event.name) | Params: \(event.parameters)")
    #endif
  }
  
  public func logScreenView(_ screenName: String) {
    let event = AnalyticsEvent.screenView(screenName: screenName, previousScreen: previousScreen)
    log(event)
    previousScreen = screenName
  }
  
  public func setUserProperty(_ property: AnalyticsUserProperty, value: String?) {
    #if canImport(FirebaseAnalytics)
    FirebaseAnalytics.Analytics.setUserProperty(value, forName: property.rawValue)
    #endif
    #if DEBUG
    print("[Analytics] UserProperty: \(property.rawValue) = \(value ?? "nil")")
    #endif
  }
  
  public func setUserProperty(_ property: AnalyticsUserProperty, value: Int) {
    setUserProperty(property, value: String(value))
  }
  
  public func setUserProperty(_ property: AnalyticsUserProperty, value: Double) {
    setUserProperty(property, value: String(format: "%.1f", value))
  }
  
  public func setUserProperty(_ property: AnalyticsUserProperty, value: Bool) {
    setUserProperty(property, value: value ? "true" : "false")
  }
  
  public func setDailyGoal(_ goalMl: Int) {
    setUserProperty(.dailyGoalMl, value: goalMl)
  }
  
  public func setWeight(_ weightKg: Double) {
    setUserProperty(.weightKg, value: weightKg)
  }
  
  public func setNotificationEnabled(_ enabled: Bool) {
    setUserProperty(.notificationEnabled, value: enabled)
  }
  
  public func setHealthKitEnabled(_ enabled: Bool) {
    setUserProperty(.healthKitEnabled, value: enabled)
  }
  
  public func setOnboardingCompleted(_ completed: Bool) {
    setUserProperty(.onboardingCompleted, value: completed)
  }
  
  public func setTotalIntakeCount(_ count: Int) {
    setUserProperty(.totalIntakeCount, value: count)
  }
  
  public func setCurrentStreak(_ days: Int) {
    setUserProperty(.currentStreak, value: days)
  }
  
  public func setUserSegment(_ segment: UserSegment) {
    setUserProperty(.userSegment, value: segment.rawValue)
  }
  
  public func setPremiumStatus(_ status: PremiumStatus) {
    setUserProperty(.premiumStatus, value: status.rawValue)
  }
  
  public func setUserId(_ userId: String) {
    #if canImport(FirebaseAnalytics)
    FirebaseAnalytics.Analytics.setUserID(userId)
    #endif
    #if canImport(FirebaseCrashlytics)
    Crashlytics.crashlytics().setUserID(userId)
    #endif
  }
  
  public func recordError(_ error: Error, context: [String: Any]? = nil) {
    #if canImport(FirebaseCrashlytics)
    Crashlytics.crashlytics().record(error: error, userInfo: context)
    #endif
  }
  
  public func log(message: String) {
    #if canImport(FirebaseCrashlytics)
    Crashlytics.crashlytics().log(message)
    #endif
  }
  
  public func setCrashlyticsKey(_ key: String, value: Any) {
    #if canImport(FirebaseCrashlytics)
    Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    #endif
  }
  
  public func logWaterIntake(amountMl: Int, method: IntakeMethod) {
    let hour = Calendar.current.component(.hour, from: Date())
    log(.waterIntake(amountMl: amountMl, method: method, hour: hour))
  }
  
  public func logGoalAchieved(goalMl: Int, actualMl: Int, streakDays: Int) {
    log(.goalAchieved(goalMl: goalMl, actualMl: actualMl, streakDays: streakDays))
  }
  
  public func logAppOpen() {
    let now = Date()
    let hour = Calendar.current.component(.hour, from: now)
    let dayOfWeek = Calendar.current.component(.weekday, from: now)
    let daysSinceInstall = calculateDaysSinceInstall()
    log(.appOpen(hour: hour, dayOfWeek: dayOfWeek, daysSinceInstall: daysSinceInstall))
  }
  
  public func logFirstWaterIntake(amountMl: Int) {
    let minutesSinceInstall = calculateMinutesSinceInstall()
    log(.firstWaterIntake(amountMl: amountMl, minutesSinceInstall: minutesSinceInstall))
  }
  
  private func setInstallDateIfNeeded() {
    if UserDefaults.standard.object(forKey: installDateKey) == nil {
      UserDefaults.standard.set(Date(), forKey: installDateKey)
    }
  }
  
  private func calculateDaysSinceInstall() -> Int {
    guard let installDate = UserDefaults.standard.object(forKey: installDateKey) as? Date else {
      return 0
    }
    return Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
  }
  
  private func calculateMinutesSinceInstall() -> Int {
    guard let installDate = UserDefaults.standard.object(forKey: installDateKey) as? Date else {
      return 0
    }
    return Calendar.current.dateComponents([.minute], from: installDate, to: Date()).minute ?? 0
  }
  
  private func updateDaysSinceInstall() {
    let days = calculateDaysSinceInstall()
    setUserProperty(.daysSinceInstall, value: days)
  }
  
  private func setAppVersion() {
    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
      setUserProperty(.appVersion, value: version)
    }
    let iosVersion = UIDevice.current.systemVersion
    setUserProperty(.iosVersion, value: iosVersion)
  }
}
