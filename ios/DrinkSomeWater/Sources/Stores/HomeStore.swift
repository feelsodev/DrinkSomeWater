import Foundation
import Observation
import Analytics

@MainActor
@Observable
final class HomeStore {
  enum Action {
    case refresh
    case refreshGoal
    case refreshQuickButtons
    case addWater(Int)
    case subtractWater(Int)
    case resetTodayWater
    case checkNotificationPermission
    case dismissNotificationBanner
    case rewardedAdCompleted(success: Bool)
  }
  
  let provider: ServiceProviderProtocol
  
  var total: Float = 0
  var ml: Float = 0
  var progress: Float { total == 0 ? 0 : ml / total }
  var remainingMl: Int { max(0, Int(total - ml)) }
  var remainingCups: Int { remainingMl / 250 }
  
  static let defaultQuickButtons = [100, 200, 300, 500]
  var quickButtons: [Int] = HomeStore.defaultQuickButtons

  var showNotificationBanner: Bool = false
  var shouldRequestReview: Bool = false
  var showingRewardedAd: Bool = false
  var pendingWaterAmount: Int?
  
  init(provider: ServiceProviderProtocol) {
    self.provider = provider
    loadQuickButtons()
  }
  
  func send(_ action: Action) async {
    switch action {
    case .refresh:
      let records = await provider.waterService.fetchWater()
      if let todayRecord = records.first(where: { $0.date.checkToday }) {
        ml = Float(todayRecord.value)
      }
      
    case .refreshGoal:
      let goal = await provider.waterService.fetchGoal()
      total = Float(goal)
      
    case .refreshQuickButtons:
      loadQuickButtons()
      
    case .addWater(let amount):
      if provider.storeKitService.isSubscribed {
        await recordWater(amount: amount)
      } else {
        let shouldShowAd = provider.freeDrinkCounterService.recordDrink()
        if shouldShowAd {
          pendingWaterAmount = amount
          showingRewardedAd = true
        } else {
          await recordWater(amount: amount)
        }
      }

    case .rewardedAdCompleted(_):
      if let amount = pendingWaterAmount {
        await recordWater(amount: amount)
      }
      pendingWaterAmount = nil
      showingRewardedAd = false

    case .subtractWater(let amount):
      let newValue = max(0, Int(ml) - amount)
      let diff = Int(ml) - newValue
      if diff > 0 {
        _ = await provider.waterService.updateWater(by: Float(-diff))
        await send(.refresh)
        Analytics.shared.log(.waterSubtracted(amountMl: diff))
      }

    case .resetTodayWater:
      let previousAmount = Int(ml)
      _ = await provider.waterService.resetTodayWater()
      await send(.refresh)
      Analytics.shared.log(.waterReset(previousAmountMl: previousAmount))

    case .checkNotificationPermission:
      let isAuthorized = await provider.notificationService.checkAuthorizationStatus()
      let isDismissed = provider.userDefaultsService.value(forkey: .notificationBannerDismissed) ?? false
      showNotificationBanner = !isAuthorized && !isDismissed

    case .dismissNotificationBanner:
      provider.userDefaultsService.set(value: true, forkey: .notificationBannerDismissed)
      showNotificationBanner = false
    }
  }
  
  private func recordWater(amount: Int) async {
    let wasAchieved = ml >= total
    _ = await provider.waterService.updateWater(by: Float(amount))
    await send(.refresh)

    Analytics.shared.logWaterIntake(amountMl: amount, method: .quickButton)

    if !wasAchieved && ml >= total {
      let streakDays = calculateStreak()
      Analytics.shared.logGoalAchieved(goalMl: Int(total), actualMl: Int(ml), streakDays: streakDays)
      
      provider.reviewEligibilityService.recordGoalCompletion()
      if provider.reviewEligibilityService.shouldRequestReview() {
        provider.reviewEligibilityService.markReviewRequested()
        Analytics.shared.log(.reviewRequested(
          completionCount: provider.reviewEligibilityService.goalCompletionCount,
          daysSinceInstall: provider.reviewEligibilityService.daysSinceInstall
        ))
        shouldRequestReview = true
      }
    }
  }
  
  private func loadQuickButtons() {
    if let buttons = provider.userDefaultsService.value(forkey: .quickButtons), !buttons.isEmpty {
      quickButtons = buttons
    }
  }
  
  func calculateStreak() -> Int {
    guard let records = provider.userDefaultsService.value(forkey: .current) else { return 1 }
    let waterRecords = records.compactMap(WaterRecord.init).filter { $0.isSuccess }.sorted { $0.date > $1.date }
    
    var streak = 0
    var currentDate = Date()
    let calendar = Calendar.current
    
    for record in waterRecords {
      let daysDiff = calendar.dateComponents([.day], from: record.date, to: currentDate).day ?? 0
      if daysDiff <= 1 {
        streak += 1
        currentDate = record.date
      } else {
        break
      }
    }
    return max(1, streak)
  }
}
