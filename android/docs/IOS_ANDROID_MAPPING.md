# iOS - Android File Mapping Table

> 💧 Gulp iOS → Android code porting reference document

---

## Meta Information

| Field | Value |
|-------|-------|
| **Version** | 1.0.0 |
| **Last Updated** | 2026-01-20 |
| **iOS Version** | 26.2.0 |

---

## Table of Contents

1. [Architecture Mapping](#1-architecture-mapping)
2. [Model Mapping](#2-model-mapping)
3. [Service Mapping](#3-service-mapping)
4. [Store/ViewModel Mapping](#4-storeviewmodel-mapping)
5. [View/Screen Mapping](#5-viewscreen-mapping)
6. [Component Mapping](#6-component-mapping)
7. [Widget Mapping](#7-widget-mapping)
8. [Watch/Wear OS Mapping](#8-watchwear-os-mapping)
9. [Utility Mapping](#9-utility-mapping)

---

## Status Legend

| Status | Meaning |
|--------|---------|
| ⏳ | Pending |
| 🚧 | In progress |
| ✅ | Complete |
| 🔄 | Needs refactoring |
| ❌ | Not applicable (not needed on Android) |

---

## 1. Architecture Mapping

### 1.1 Pattern Comparison

| iOS | Android | Description |
|-----|---------|-------------|
| `@Observable` | `StateFlow` | State observation |
| `@MainActor` | `viewModelScope` | Main thread |
| `send(_ action:)` | `onEvent(event:)` | Action dispatch |
| `Action enum` | `sealed class Event` | Event definition |
| `var state` | `data class UiState` | State definition |
| `async/await` | `suspend` | Async |
| Protocol | Interface | Abstraction |

### 1.2 Structure Comparison

```
iOS:                              Android:
┌─────────────────┐              ┌─────────────────┐
│   SwiftUI View  │              │ Compose Screen  │
│   @Bindable     │              │ collectAsState  │
└────────┬────────┘              └────────┬────────┘
         │                                │
         ▼                                ▼
┌─────────────────┐              ┌─────────────────┐
│     Store       │              │   ViewModel     │
│  @Observable    │              │   StateFlow     │
│  send(action)   │              │   onEvent()     │
└────────┬────────┘              └────────┬────────┘
         │                                │
         ▼                                ▼
┌─────────────────┐              ┌─────────────────┐
│    Service      │              │   Repository    │
│    Protocol     │              │   Interface     │
└─────────────────┘              └─────────────────┘
```

---

## 2. Model Mapping

| iOS File | Android File | Status | Notes |
|----------|-------------|--------|-------|
| `Models/WaterRecord.swift` | `domain/model/WaterRecord.kt` | ⏳ | data class |
| `Models/UserProfile.swift` | `domain/model/UserProfile.kt` | ⏳ | data class |
| `Models/NotificationSettings.swift` | `domain/model/NotificationSettings.kt` | ⏳ | data class |
| `Models/ModelType.swift` | ❌ | ❌ | Not needed in Kotlin |
| `Models/Info.swift` | `domain/model/SettingsItem.kt` | ⏳ | Settings item |
| `Models/AppVersion.swift` | `domain/model/AppVersion.kt` | ⏳ | - |
| `Models/AppUpdateConfig.swift` | `domain/model/AppUpdateConfig.kt` | ⏳ | - |

### 2.1 WaterRecord Detailed Mapping

**iOS (WaterRecord.swift)**
```swift
struct WaterRecord: ModelType, Identifiable {
    var id: String { date.dateToString }
    var date: Date
    var value: Int
    var isSuccess: Bool
    var goal: Int
}
```

**Android (WaterRecord.kt)**
```kotlin
@Serializable
data class WaterRecord(
    val date: LocalDate,
    val value: Int,
    val isSuccess: Boolean,
    val goal: Int
) {
    val id: String get() = date.toString()
    val progress: Float get() = if (goal == 0) 0f else value.toFloat() / goal
    val remainingMl: Int get() = maxOf(0, goal - value)
    val remainingCups: Int get() = remainingMl / 250
}
```

---

## 3. Service Mapping

| iOS File | Android File | Status | Notes |
|----------|-------------|--------|-------|
| `Services/WaterService.swift` | `data/repository/WaterRepositoryImpl.kt` | ⏳ | Repository pattern |
| `Services/UserDefaultsService.swift` | `data/datastore/WaterDataStore.kt` | ⏳ | DataStore |
| `Services/HealthKitService.swift` | `service/health/HealthConnectHelper.kt` | ⏳ | Health Connect |
| `Services/NotificationService.swift` | `service/notification/NotificationHelper.kt` | ⏳ | WorkManager |
| `Services/WatchConnectivityService.swift` | `service/sync/DataLayerHelper.kt` | ⏳ | Wear Data Layer |
| `Services/AlertService.swift` | ❌ | ❌ | Uses Compose Dialog |
| `Services/AdMobService.swift` | `service/ad/AdMobHelper.kt` | ⏳ | - |
| `Services/RemoteConfigService.swift` | `service/config/RemoteConfigHelper.kt` | ⏳ | - |
| `Services/AppUpdateChecker.swift` | `service/update/AppUpdateChecker.kt` | ⏳ | - |
| `Services/ServiceProvider.swift` | ❌ | ❌ | Uses Hilt DI |
| `Services/BaseService.swift` | ❌ | ❌ | Not needed |

### 3.1 WaterService → WaterRepository Detailed Mapping

**iOS (WaterService.swift)**
```swift
@MainActor
protocol WaterServiceProtocol: AnyObject {
    func fetchWater() async -> [WaterRecord]
    func fetchGoal() async -> Int
    func updateWater(by ml: Float) async -> [WaterRecord]
    func updateGoal(to ml: Int) async -> Int
    func resetTodayWater() async -> [WaterRecord]
}
```

**Android (WaterRepository.kt)**
```kotlin
interface WaterRepository {
    suspend fun getTodayRecord(): WaterRecord?
    suspend fun getAllRecords(): List<WaterRecord>
    suspend fun getGoal(): Int
    suspend fun addWater(amount: Int)
    suspend fun subtractWater(amount: Int)
    suspend fun updateGoal(goal: Int)
    suspend fun resetToday()
    fun observeTodayRecord(): Flow<WaterRecord?>
}
```

---

## 4. Store/ViewModel Mapping

| iOS File | Android File | Status | Notes |
|----------|-------------|--------|-------|
| `Stores/HomeStore.swift` | `ui/home/HomeViewModel.kt` | ⏳ | MVI |
| `Stores/HistoryStore.swift` | `ui/history/HistoryViewModel.kt` | ⏳ | MVI |
| `Stores/SettingsStore.swift` | `ui/settings/SettingsViewModel.kt` | ⏳ | MVI |
| `Stores/OnboardingStore.swift` | `ui/onboarding/OnboardingViewModel.kt` | ⏳ | MVI |
| `Stores/ProfileStore.swift` | `ui/settings/ProfileViewModel.kt` | ⏳ | MVI |
| `Stores/NotificationStore.swift` | `ui/settings/NotificationViewModel.kt` | ⏳ | MVI |
| `Stores/CalendarStore.swift` | ❌ | ❌ | Merged into HistoryViewModel |
| `Stores/MainStore.swift` | ❌ | ❌ | Not needed |
| `Stores/DrinkStore.swift` | ❌ | ❌ | Merged into HomeViewModel |
| `Stores/SettingStore.swift` | ❌ | ❌ | Merged into SettingsViewModel |
| `Stores/InformationStore.swift` | ❌ | ❌ | Merged into SettingsViewModel |
| `Stores/ObservationToken.swift` | ❌ | ❌ | Uses StateFlow |

### 4.1 HomeStore → HomeViewModel Detailed Mapping

**iOS Action → Android Event**

| iOS Action | Android Event |
|------------|---------------|
| `.refresh` | `Refresh` |
| `.refreshGoal` | `RefreshGoal` |
| `.refreshQuickButtons` | `RefreshQuickButtons` |
| `.addWater(Int)` | `AddWater(amount: Int)` |
| `.subtractWater(Int)` | `SubtractWater(amount: Int)` |
| `.resetTodayWater` | `ResetToday` |
| `.checkNotificationPermission` | `CheckNotificationPermission` |
| `.dismissNotificationBanner` | `DismissNotificationBanner` |

**iOS State → Android UiState**

| iOS Property | Android UiState Field |
|--------------|----------------------|
| `total: Float` | `goalMl: Int` |
| `ml: Float` | `currentMl: Int` |
| `progress: Float` | `progress: Float` (computed) |
| `remainingMl: Int` | `remainingMl: Int` (computed) |
| `remainingCups: Int` | `remainingCups: Int` (computed) |
| `quickButtons: [Int]` | `quickButtons: List<Int>` |
| `showNotificationBanner: Bool` | `showNotificationBanner: Boolean` |
| - | `isSubtractMode: Boolean` |
| - | `isLoading: Boolean` |
| - | `isGoalAchieved: Boolean` (computed) |

---

## 5. View/Screen Mapping

| iOS File | Android File | Status | Notes |
|----------|-------------|--------|-------|
| `Views/MainTabView.swift` | `ui/navigation/AppNavigation.kt` | ⏳ | Navigation Compose |
| `Views/HomeView.swift` | `ui/home/HomeScreen.kt` | ⏳ | Compose |
| `Views/HistoryView.swift` | `ui/history/HistoryScreen.kt` | ⏳ | Compose |
| `Views/AppGuideView.swift` | `ui/settings/WidgetGuideScreen.kt` | ⏳ | Compose |
| `ViewController/Settings/SettingsViewController.swift` | `ui/settings/SettingsScreen.kt` | ⏳ | Compose |
| `ViewController/Settings/NotificationSettingViewController.swift` | `ui/settings/NotificationSettingScreen.kt` | ⏳ | Compose |
| `ViewController/Settings/ProfileSettingViewController.swift` | `ui/settings/ProfileSettingScreen.kt` | ⏳ | Compose |
| `ViewController/Settings/WidgetGuideViewController.swift` | `ui/settings/WidgetGuideScreen.kt` | ⏳ | Compose |
| `ViewController/Onboarding/OnboardingViewController.swift` | `ui/onboarding/OnboardingScreen.kt` | ⏳ | Compose |
| `ViewController/Onboarding/OnboardingPageViewController.swift` | ❌ | ❌ | Uses HorizontalPager |
| `ViewController/BaseComponent/BaseViewController.swift` | ❌ | ❌ | Not needed |
| `IntroViewController.swift` | `ui/splash/SplashScreen.kt` | ⏳ | Compose |
| `SceneDelegate.swift` | `MainActivity.kt` | ⏳ | Activity |
| `AppDelegate.swift` | `DrinkSomeWaterApp.kt` | ⏳ | Application |

### 5.1 HomeView Component Mapping

| iOS Component | Android Composable |
|---------------|-------------------|
| `headerSection` | `HomeHeader()` |
| `messageCard` | `MotivationCard()` |
| `notificationBanner` | `NotificationBanner()` |
| `bottleSection` | `BottleSection()` |
| `quickButtonsSection` | `QuickButtonsSection()` |
| `GoalSettingView` | `GoalSettingSheet()` |
| `QuickButtonSettingView` | `QuickButtonSettingSheet()` |
| `WaterAdjustmentView` | `WaterAdjustmentSheet()` |

### 5.2 HistoryView Component Mapping

| iOS Component | Android Composable |
|---------------|-------------------|
| `HistoryCalendarTab` | `CalendarTab()` |
| `HistoryListTab` | `ListTab()` |
| `HistoryTimelineTab` | `TimelineTab()` |
| `RecordCard` | `RecordCard()` |
| `ListRecordRow` | `RecordListItem()` |
| `TimelineRecordRow` | `TimelineRecordItem()` |
| `TimelineMonthSection` | `TimelineMonthSection()` |
| `LegendItem` | `LegendItem()` |
| `monthSummaryBadge` | `MonthSummaryBadge()` |
| `modePicker` | `ViewModePicker()` |

---

## 6. Component Mapping

| iOS File | Android File | Status | Notes |
|----------|-------------|--------|-------|
| `Vendor/WaveAnimationView.swift` | `ui/components/WaveAnimation.kt` | ⏳ | Compose Canvas |
| `ViewComponent/WaveAnimationViewRepresentable.swift` | ❌ | ❌ | Uses Compose directly |
| `ViewComponent/FSCalendarRepresentable.swift` | `ui/components/CustomCalendar.kt` | ⏳ | Custom implementation |
| `ViewComponent/Beaker.swift` | `ui/components/BottleView.kt` | ⏳ | Compose |
| `ViewComponent/WaterRecordResultView.swift` | `ui/components/RecordCard.kt` | ⏳ | Compose |
| `ViewComponent/CalendarDescriptView.swift` | ❌ | ❌ | Merged into CustomCalendar |
| `ViewComponent/NativeAdView.swift` | `ui/components/NativeAdView.kt` | ⏳ | Compose |
| `ViewComponent/NativeAdTableViewCell.swift` | ❌ | ❌ | Uses Compose directly |
| `ViewComponent/IntrinsicTableView.swift` | ❌ | ❌ | Uses LazyColumn |
| `ViewController/Settings/SettingsCell.swift` | ❌ | ❌ | Uses Compose directly |
| `ViewController/BaseComponent/BaseTableViewCell.swift` | ❌ | ❌ | Not needed |

### 6.1 WaveAnimationView Detailed Mapping

**iOS**
```swift
class WaveAnimationView: UIView {
    var progress: Float
    var frontColor: UIColor
    var backColor: UIColor
    // Animation via CADisplayLink
}
```

**Android**
```kotlin
@Composable
fun WaveAnimation(
    progress: Float,
    frontColor: Color,
    backColor: Color,
    modifier: Modifier = Modifier
) {
    val infiniteTransition = rememberInfiniteTransition()
    val waveOffset by infiniteTransition.animateFloat(...)
    
    Canvas(modifier = modifier) {
        // Draw wave with drawPath
    }
}
```

---

## 7. Widget Mapping

| iOS File | Android File | Status | Notes |
|----------|-------------|--------|-------|
| `DrinkSomeWaterWidget/DrinkSomeWaterWidget.swift` | `widget/WaterGlanceWidget.kt` | ⏳ | Glance |
| `DrinkSomeWaterWidget/WaterEntry.swift` | `widget/WaterWidgetState.kt` | ⏳ | - |
| `DrinkSomeWaterWidget/WaterProvider.swift` | `widget/WaterWidgetReceiver.kt` | ⏳ | - |
| `DrinkSomeWaterWidget/Views/SmallWidgetView.swift` | `widget/ui/SmallWidget.kt` | ⏳ | Glance |
| `DrinkSomeWaterWidget/Views/MediumWidgetView.swift` | `widget/ui/MediumWidget.kt` | ⏳ | Glance |
| `DrinkSomeWaterWidget/Views/LargeWidgetView.swift` | `widget/ui/LargeWidget.kt` | ⏳ | Glance |
| `DrinkSomeWaterWidget/Views/LockScreenWidgetView.swift` | ❌ | ❌ | No lock screen widget on Android |
| `DrinkSomeWaterWidget/Intents/AddWaterIntent.swift` | `widget/action/AddWaterAction.kt` | ⏳ | ActionCallback |
| `Shared/WidgetDataManager.swift` | `widget/data/WidgetDataManager.kt` | ⏳ | DataStore |

### 7.1 Widget Size Mapping

| iOS Family | Android Size | Size |
|------------|--------------|------|
| `.systemSmall` | `DpSize(110.dp, 110.dp)` | 2x2 |
| `.systemMedium` | `DpSize(250.dp, 110.dp)` | 4x2 |
| `.systemLarge` | `DpSize(250.dp, 250.dp)` | 4x4 |
| `.accessoryCircular` | ❌ | Not applicable |
| `.accessoryRectangular` | ❌ | Not applicable |
| `.accessoryInline` | ❌ | Not applicable |

---

## 8. Watch/Wear OS Mapping

| iOS File | Android File | Status | Notes |
|----------|-------------|--------|-------|
| `DrinkSomeWaterWatch/Sources/DrinkSomeWaterWatchApp.swift` | `wear/WearApplication.kt` | ⏳ | Application |
| `DrinkSomeWaterWatch/Sources/Stores/WatchStore.swift` | `wear/WatchViewModel.kt` | ⏳ | ViewModel |
| `DrinkSomeWaterWatch/Sources/Views/ContentView.swift` | `wear/ui/WearNavigation.kt` | ⏳ | Navigation |
| `DrinkSomeWaterWatch/Sources/Views/HomeView.swift` | `wear/ui/HomeScreen.kt` | ⏳ | Wear Compose |
| `DrinkSomeWaterWatch/Sources/Views/QuickAddView.swift` | `wear/ui/QuickAddScreen.kt` | ⏳ | Wear Compose |
| `DrinkSomeWaterWatch/Sources/Views/CustomAmountView.swift` | `wear/ui/CustomAmountScreen.kt` | ⏳ | Wear Compose |
| `DrinkSomeWaterWatch/Sources/Complications/WaterComplication.swift` | `wear/complication/WaterComplicationService.kt` | ⏳ | Complication |
| `DrinkSomeWaterWatch/Sources/Complications/DrinkSomeWaterWidgetBundle.swift` | `wear/tile/WaterTileService.kt` | ⏳ | Tile |

### 8.1 Watch Communication Mapping

| iOS (WatchConnectivity) | Android (Data Layer) |
|-------------------------|----------------------|
| `WCSession.default` | `Wearable.getDataClient()` |
| `sendMessage(_:)` | `messageClient.sendMessage()` |
| `transferUserInfo(_:)` | `dataClient.putDataItem()` |
| `WCSessionDelegate` | `WearableListenerService` |
| `didReceiveMessage(_:)` | `onMessageReceived()` |
| `didReceiveUserInfo(_:)` | `onDataChanged()` |

---

## 9. Utility Mapping

| iOS File | Android File | Status | Notes |
|----------|-------------|--------|-------|
| `Extensions-Utillities/Date+Ext.swift` | `util/DateExtensions.kt` | ⏳ | - |
| `Extensions-Utillities/Float+Ext.swift` | ❌ | ❌ | Uses Kotlin stdlib |
| `Extensions-Utillities/String+Ext.swift` | ❌ | ❌ | Uses Kotlin stdlib |
| `Extensions-Utillities/UIView+Ext.swift` | ❌ | ❌ | Uses Compose Modifier |
| `Types/UserDefaultsKey.swift` | `data/datastore/PreferencesKeys.kt` | ⏳ | - |
| `StaticComponent/NotificationMessages.swift` | `service/notification/NotificationMessages.kt` | ⏳ | - |
| `StaticComponent/WaterImage.swift` | ❌ | ❌ | Uses Drawable |
| `DesignSystem/DesignTokens.swift` | `ui/theme/DesignTokens.kt` | ⏳ | - |

### 9.1 DesignTokens Mapping

| iOS | Android |
|-----|---------|
| `DS.Spacing.xs` (8) | `DS.Spacing.xs` (8.dp) |
| `DS.Spacing.sm` (12) | `DS.Spacing.sm` (12.dp) |
| `DS.Spacing.md` (16) | `DS.Spacing.md` (16.dp) |
| `DS.Size.cornerRadiusMedium` (12) | `DS.Size.cornerRadiusMedium` (12.dp) |
| `DS.Color.primary` (#59BFF2) | `DS.Colors.primary` (Color(0xFF59BFF2)) |
| `DS.Font.display` (48, bold) | `DS.Typography.display` (48.sp, Bold) |
| `DS.SwiftUIFont.body` | `MaterialTheme.typography.bodyLarge` |
| `DS.SwiftUIColor.primary` | `MaterialTheme.colorScheme.primary` |

---

## 10. Analytics Mapping

| iOS File | Android File | Status | Notes |
|----------|-------------|--------|-------|
| `Analytics/Sources/Analytics.swift` | `analytics/AnalyticsTracker.kt` | ⏳ | - |
| `Analytics/Sources/AnalyticsEvent.swift` | `analytics/AnalyticsEvent.kt` | ⏳ | sealed class |
| `Analytics/Sources/AnalyticsUserProperty.swift` | `analytics/UserProperty.kt` | ⏳ | - |

### 10.1 Analytics Event Mapping

| iOS Event | Android Event |
|-----------|---------------|
| `.waterIntake(amountMl:, method:, hour:)` | `WaterIntake(amountMl, method, hour)` |
| `.goalAchieved(goalMl:, actualMl:, streakDays:)` | `GoalAchieved(goalMl, actualMl, streakDays)` |
| `.waterSubtracted(amountMl:)` | `WaterSubtracted(amountMl)` |
| `.waterReset(previousAmountMl:)` | `WaterReset(previousAmountMl)` |
| `.goalChanged(oldGoal:, newGoal:, source:)` | `GoalChanged(oldGoal, newGoal, source)` |
| `.calendarDateSelected(date:, hadRecords:, wasAchieved:)` | `CalendarDateSelected(date, hadRecords, wasAchieved)` |

---

## Appendix: Quick Reference

### A. File Search Paths

| Feature | iOS Path | Android Path |
|---------|---------|-------------|
| Models | `DrinkSomeWater/Sources/Models/` | `app/.../domain/model/` |
| Services | `DrinkSomeWater/Sources/Services/` | `app/.../data/repository/` |
| Store/VM | `DrinkSomeWater/Sources/Stores/` | `app/.../ui/[feature]/` |
| Views | `DrinkSomeWater/Sources/Views/` | `app/.../ui/[feature]/` |
| Components | `DrinkSomeWater/Sources/ViewComponent/` | `app/.../ui/components/` |
| Design | `DrinkSomeWater/Sources/DesignSystem/` | `app/.../ui/theme/` |
| Utilities | `DrinkSomeWater/Sources/Extensions-Utillities/` | `app/.../util/` |
| Widget | `DrinkSomeWaterWidget/` | `widget/` |
| Watch | `DrinkSomeWaterWatch/` | `wear/` |
| Analytics | `Analytics/` | `analytics/` |

### B. Related Documents

- [Project Plan](./ANDROID_PROJECT_PLAN.md)
- [TDD Guide](./ANDROID_TDD_GUIDE.md)
- [iOS Project Documentation](../../ios/docs/IOS_PROJECT_DOCUMENTATION.md)
- [iOS Tech Spec](../../ios/docs/TECH_SPEC.md)
