import Foundation

public enum AnalyticsUserProperty: String, CaseIterable, Sendable {
  case dailyGoalMl = "daily_goal_ml"
  case weightKg = "weight_kg"
  case notificationEnabled = "notification_enabled"
  case healthKitEnabled = "healthkit_enabled"
  case onboardingCompleted = "onboarding_completed"
  case daysSinceInstall = "days_since_install"
  case totalIntakeCount = "total_intake_count"
  case currentStreak = "current_streak"
  case userSegment = "user_segment"
  case premiumStatus = "premium_status"
  case appVersion = "app_version"
  case iosVersion = "ios_version"
}

public enum UserSegment: String, Sendable {
  case light = "light"
  case medium = "medium"
  case heavy = "heavy"
}

public enum PremiumStatus: String, Sendable {
  case free = "free"
  case premium = "premium"
}
