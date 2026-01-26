import Foundation

public enum AnalyticsEvent {
  
  // MARK: - Tier 1: Core Events
  
  case waterIntake(amountMl: Int, method: IntakeMethod, hour: Int)
  case goalAchieved(goalMl: Int, actualMl: Int, streakDays: Int)
  case goalFailed(goalMl: Int, actualMl: Int, percentage: Double)
  case appOpen(hour: Int, dayOfWeek: Int, daysSinceInstall: Int)
  case screenView(screenName: String, previousScreen: String?)
  
  // MARK: - Tier 2: Onboarding Funnel
  
  case onboardingStarted(source: String?)
  case onboardingStepViewed(step: Int)
  case onboardingStepCompleted(step: Int, timeSpentSec: Int)
  case onboardingSkipped(step: Int)
  case onboardingCompleted(totalTimeSec: Int)
  case firstWaterIntake(amountMl: Int, minutesSinceInstall: Int)
  case permissionRequested(type: PermissionType)
  case permissionGranted(type: PermissionType)
  case permissionDenied(type: PermissionType)
  
  // MARK: - Tier 3: Feature Usage

  case waterSubtracted(amountMl: Int)
  case waterReset(previousAmountMl: Int)
  case quickButtonTap(amountMl: Int, buttonIndex: Int, isCustom: Bool)
  case sliderUsed(amountMl: Int)
  case goalChanged(oldGoal: Int, newGoal: Int, source: GoalChangeSource)
  case goalQuickSetUsed(newGoal: Int)
  case quickButtonCustomized(buttonIndex: Int, amountMl: Int)
  case calendarViewed(month: Int, year: Int)
  case calendarDateSelected(date: Date, hadRecords: Bool, wasAchieved: Bool)
  case historyRecordViewed(date: Date, recordCount: Int)
  case notificationSettingChanged(enabled: Bool, startTime: String?, endTime: String?, intervalHours: Int?)
  case widgetAdded(widgetType: WidgetType)
  case widgetInteraction(widgetType: WidgetType, action: WidgetAction, amountMl: Int?)
  
  // MARK: - Tier 4: HealthKit
  
  case healthKitConnected
  case healthKitDisconnected(reason: String?)
  case healthKitSyncSuccess(recordCount: Int, syncType: SyncType)
  case healthKitSyncFailed(errorCode: String, errorMessage: String)
  case weightUpdated(weightKg: Double, source: WeightSource)
  case recommendedGoalAccepted(recommendedMl: Int, weightKg: Double)
  case recommendedGoalRejected(recommendedMl: Int, customMl: Int)
  
  // MARK: - Tier 5: Social Sharing
  
  case instagramShareInitiated(destination: InstagramShareDestination, source: InstagramShareSource)
  case instagramShareCompleted(destination: InstagramShareDestination, source: InstagramShareSource)
  case instagramShareFailed(destination: InstagramShareDestination, reason: String)
  
  // MARK: - Tier 6: Retention
  
  case streakAchieved(streakDays: Int)
  case streakBroken(previousStreakDays: Int)
  case notificationReceived(notificationId: String, messageType: String)
  case notificationTapped(notificationId: String, timeToTapSec: Int)
  case notificationDismissed(notificationId: String)
  case inactiveReturn(daysInactive: Int)
  
  // MARK: - Tier 6: Monetization
  
  case adImpression(adType: AdType, adUnitId: String, screen: String)
  case adClicked(adType: AdType, adUnitId: String)
  case adClosed(adType: AdType, viewDurationSec: Int)
  case rewardedAdStarted(rewardType: String)
  case rewardedAdCompleted(rewardType: String, rewardAmount: Int)
  case premiumPromptShown(triggerPoint: String, variant: String?)
  case premiumPromptAction(action: PremiumAction)
  case purchaseStarted(productId: String, price: Double)
  case purchaseCompleted(productId: String, price: Double, currency: String)
  case purchaseFailed(productId: String, errorCode: String)
  
  // MARK: - Event Name & Parameters
  
  public var name: String {
    switch self {
    case .waterIntake: return "water_intake"
    case .goalAchieved: return "goal_achieved"
    case .goalFailed: return "goal_failed"
    case .appOpen: return "app_open"
    case .screenView: return "screen_view"
    case .onboardingStarted: return "onboarding_started"
    case .onboardingStepViewed: return "onboarding_step_viewed"
    case .onboardingStepCompleted: return "onboarding_step_completed"
    case .onboardingSkipped: return "onboarding_skipped"
    case .onboardingCompleted: return "onboarding_completed"
    case .firstWaterIntake: return "first_water_intake"
    case .permissionRequested: return "permission_requested"
    case .permissionGranted: return "permission_granted"
    case .permissionDenied: return "permission_denied"
    case .waterSubtracted: return "water_subtracted"
    case .waterReset: return "water_reset"
    case .quickButtonTap: return "quick_button_tap"
    case .sliderUsed: return "slider_used"
    case .goalChanged: return "goal_changed"
    case .goalQuickSetUsed: return "goal_quick_set_used"
    case .quickButtonCustomized: return "quick_button_customized"
    case .calendarViewed: return "calendar_viewed"
    case .calendarDateSelected: return "calendar_date_selected"
    case .historyRecordViewed: return "history_record_viewed"
    case .notificationSettingChanged: return "notification_setting_changed"
    case .widgetAdded: return "widget_added"
    case .widgetInteraction: return "widget_interaction"
    case .healthKitConnected: return "healthkit_connected"
    case .healthKitDisconnected: return "healthkit_disconnected"
    case .healthKitSyncSuccess: return "healthkit_sync_success"
    case .healthKitSyncFailed: return "healthkit_sync_failed"
    case .weightUpdated: return "weight_updated"
    case .recommendedGoalAccepted: return "recommended_goal_accepted"
    case .recommendedGoalRejected: return "recommended_goal_rejected"
    case .streakAchieved: return "streak_achieved"
    case .streakBroken: return "streak_broken"
    case .notificationReceived: return "notification_received"
    case .notificationTapped: return "notification_tapped"
    case .notificationDismissed: return "notification_dismissed"
    case .inactiveReturn: return "inactive_return"
    case .adImpression: return "ad_impression"
    case .adClicked: return "ad_clicked"
    case .adClosed: return "ad_closed"
    case .rewardedAdStarted: return "rewarded_ad_started"
    case .rewardedAdCompleted: return "rewarded_ad_completed"
    case .premiumPromptShown: return "premium_prompt_shown"
    case .premiumPromptAction: return "premium_prompt_action"
    case .purchaseStarted: return "purchase_started"
    case .purchaseCompleted: return "purchase_completed"
    case .purchaseFailed: return "purchase_failed"
    case .instagramShareInitiated: return "instagram_share_initiated"
    case .instagramShareCompleted: return "instagram_share_completed"
    case .instagramShareFailed: return "instagram_share_failed"
    }
  }
  
  public var parameters: [String: Any] {
    switch self {
    case .waterIntake(let amountMl, let method, let hour):
      return ["amount_ml": amountMl, "method": method.rawValue, "hour": hour]
      
    case .goalAchieved(let goalMl, let actualMl, let streakDays):
      return ["goal_ml": goalMl, "actual_ml": actualMl, "streak_days": streakDays]
      
    case .goalFailed(let goalMl, let actualMl, let percentage):
      return ["goal_ml": goalMl, "actual_ml": actualMl, "percentage": percentage]
      
    case .appOpen(let hour, let dayOfWeek, let daysSinceInstall):
      return ["hour": hour, "day_of_week": dayOfWeek, "days_since_install": daysSinceInstall]
      
    case .screenView(let screenName, let previousScreen):
      var params: [String: Any] = ["screen_name": screenName]
      if let prev = previousScreen { params["previous_screen"] = prev }
      return params
      
    case .onboardingStarted(let source):
      var params: [String: Any] = [:]
      if let src = source { params["source"] = src }
      return params
      
    case .onboardingStepViewed(let step):
      return ["step": step]
      
    case .onboardingStepCompleted(let step, let timeSpentSec):
      return ["step": step, "time_spent_sec": timeSpentSec]
      
    case .onboardingSkipped(let step):
      return ["step": step]
      
    case .onboardingCompleted(let totalTimeSec):
      return ["total_time_sec": totalTimeSec]
      
    case .firstWaterIntake(let amountMl, let minutesSinceInstall):
      return ["amount_ml": amountMl, "minutes_since_install": minutesSinceInstall]
      
    case .permissionRequested(let type), .permissionGranted(let type), .permissionDenied(let type):
      return ["type": type.rawValue]
      
    case .waterSubtracted(let amountMl):
      return ["amount_ml": amountMl]

    case .waterReset(let previousAmountMl):
      return ["previous_amount_ml": previousAmountMl]

    case .quickButtonTap(let amountMl, let buttonIndex, let isCustom):
      return ["amount_ml": amountMl, "button_index": buttonIndex, "is_custom": isCustom]
      
    case .sliderUsed(let amountMl):
      return ["amount_ml": amountMl]
      
    case .goalChanged(let oldGoal, let newGoal, let source):
      return ["old_goal": oldGoal, "new_goal": newGoal, "source": source.rawValue]
      
    case .goalQuickSetUsed(let newGoal):
      return ["new_goal": newGoal]
      
    case .quickButtonCustomized(let buttonIndex, let amountMl):
      return ["button_index": buttonIndex, "amount_ml": amountMl]
      
    case .calendarViewed(let month, let year):
      return ["month": month, "year": year]
      
    case .calendarDateSelected(let date, let hadRecords, let wasAchieved):
      let formatter = ISO8601DateFormatter()
      return ["date": formatter.string(from: date), "had_records": hadRecords, "was_achieved": wasAchieved]
      
    case .historyRecordViewed(let date, let recordCount):
      let formatter = ISO8601DateFormatter()
      return ["date": formatter.string(from: date), "record_count": recordCount]
      
    case .notificationSettingChanged(let enabled, let startTime, let endTime, let intervalHours):
      var params: [String: Any] = ["enabled": enabled]
      if let start = startTime { params["start_time"] = start }
      if let end = endTime { params["end_time"] = end }
      if let interval = intervalHours { params["interval_hours"] = interval }
      return params
      
    case .widgetAdded(let widgetType):
      return ["widget_type": widgetType.rawValue]
      
    case .widgetInteraction(let widgetType, let action, let amountMl):
      var params: [String: Any] = ["widget_type": widgetType.rawValue, "action": action.rawValue]
      if let amount = amountMl { params["amount_ml"] = amount }
      return params
      
    case .healthKitConnected:
      return [:]
      
    case .healthKitDisconnected(let reason):
      var params: [String: Any] = [:]
      if let r = reason { params["reason"] = r }
      return params
      
    case .healthKitSyncSuccess(let recordCount, let syncType):
      return ["record_count": recordCount, "sync_type": syncType.rawValue]
      
    case .healthKitSyncFailed(let errorCode, let errorMessage):
      return ["error_code": errorCode, "error_message": errorMessage]
      
    case .weightUpdated(let weightKg, let source):
      return ["weight_kg": weightKg, "source": source.rawValue]
      
    case .recommendedGoalAccepted(let recommendedMl, let weightKg):
      return ["recommended_ml": recommendedMl, "weight_kg": weightKg]
      
    case .recommendedGoalRejected(let recommendedMl, let customMl):
      return ["recommended_ml": recommendedMl, "custom_ml": customMl]
      
    case .streakAchieved(let streakDays):
      return ["streak_days": streakDays]
      
    case .streakBroken(let previousStreakDays):
      return ["previous_streak_days": previousStreakDays]
      
    case .notificationReceived(let notificationId, let messageType):
      return ["notification_id": notificationId, "message_type": messageType]
      
    case .notificationTapped(let notificationId, let timeToTapSec):
      return ["notification_id": notificationId, "time_to_tap_sec": timeToTapSec]
      
    case .notificationDismissed(let notificationId):
      return ["notification_id": notificationId]
      
    case .inactiveReturn(let daysInactive):
      return ["days_inactive": daysInactive]
      
    case .adImpression(let adType, let adUnitId, let screen):
      return ["ad_type": adType.rawValue, "ad_unit_id": adUnitId, "screen": screen]
      
    case .adClicked(let adType, let adUnitId):
      return ["ad_type": adType.rawValue, "ad_unit_id": adUnitId]
      
    case .adClosed(let adType, let viewDurationSec):
      return ["ad_type": adType.rawValue, "view_duration_sec": viewDurationSec]
      
    case .rewardedAdStarted(let rewardType):
      return ["reward_type": rewardType]
      
    case .rewardedAdCompleted(let rewardType, let rewardAmount):
      return ["reward_type": rewardType, "reward_amount": rewardAmount]
      
    case .premiumPromptShown(let triggerPoint, let variant):
      var params: [String: Any] = ["trigger_point": triggerPoint]
      if let v = variant { params["variant"] = v }
      return params
      
    case .premiumPromptAction(let action):
      return ["action": action.rawValue]
      
    case .purchaseStarted(let productId, let price):
      return ["product_id": productId, "price": price]
      
    case .purchaseCompleted(let productId, let price, let currency):
      return ["product_id": productId, "price": price, "currency": currency]
      
    case .purchaseFailed(let productId, let errorCode):
      return ["product_id": productId, "error_code": errorCode]
      
    case .instagramShareInitiated(let destination, let source):
      return ["destination": destination.rawValue, "source": source.rawValue]
      
    case .instagramShareCompleted(let destination, let source):
      return ["destination": destination.rawValue, "source": source.rawValue]
      
    case .instagramShareFailed(let destination, let reason):
      return ["destination": destination.rawValue, "reason": reason]
    }
  }
}

// MARK: - Supporting Types

public enum IntakeMethod: String, Sendable {
  case quickButton = "quick_button"
  case slider = "slider"
  case widget = "widget"
  case shortcut = "shortcut"
}

public enum PermissionType: String, Sendable {
  case notification = "notification"
  case healthKit = "healthkit"
}

public enum GoalChangeSource: String, Sendable {
  case settings = "settings"
  case onboarding = "onboarding"
  case quickSet = "quick_set"
  case recommendation = "recommendation"
}

public enum WidgetType: String, Sendable {
  case small = "small"
  case medium = "medium"
  case large = "large"
  case lockScreen = "lock_screen"
}

public enum WidgetAction: String, Sendable {
  case addWater = "add_water"
  case openApp = "open_app"
}

public enum SyncType: String, Sendable {
  case manual = "manual"
  case automatic = "automatic"
  case background = "background"
}

public enum WeightSource: String, Sendable {
  case manual = "manual"
  case healthKit = "healthkit"
}

public enum AdType: String, Sendable {
  case banner = "banner"
  case native = "native"
  case rewarded = "rewarded"
  case interstitial = "interstitial"
}

public enum PremiumAction: String, Sendable {
  case purchase = "purchase"
  case dismiss = "dismiss"
  case later = "later"
}

public enum InstagramShareDestination: String, Sendable {
  case stories = "stories"
  case feed = "feed"
}

public enum InstagramShareSource: String, Sendable {
  case home = "home"
  case history = "history"
}
