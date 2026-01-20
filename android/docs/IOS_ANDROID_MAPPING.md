# iOS - Android 파일 매핑 테이블

> 💧 벌컥벌컥 iOS → Android 코드 포팅 참조 문서

---

## 메타 정보

| 항목 | 값 |
|------|-----|
| **버전** | 1.0.0 |
| **최종 업데이트** | 2026-01-20 |
| **iOS 버전** | 26.2.0 |

---

## 목차

1. [아키텍처 매핑](#1-아키텍처-매핑)
2. [모델 매핑](#2-모델-매핑)
3. [서비스 매핑](#3-서비스-매핑)
4. [Store/ViewModel 매핑](#4-storeviewmodel-매핑)
5. [View/Screen 매핑](#5-viewscreen-매핑)
6. [컴포넌트 매핑](#6-컴포넌트-매핑)
7. [위젯 매핑](#7-위젯-매핑)
8. [Watch/Wear OS 매핑](#8-watchwear-os-매핑)
9. [유틸리티 매핑](#9-유틸리티-매핑)

---

## 상태 범례

| 상태 | 의미 |
|------|------|
| ⏳ | 대기 중 |
| 🚧 | 진행 중 |
| ✅ | 완료 |
| 🔄 | 리팩토링 필요 |
| ❌ | 해당 없음 (Android에서 불필요) |

---

## 1. 아키텍처 매핑

### 1.1 패턴 비교

| iOS | Android | 설명 |
|-----|---------|------|
| `@Observable` | `StateFlow` | 상태 관찰 |
| `@MainActor` | `viewModelScope` | 메인 스레드 |
| `send(_ action:)` | `onEvent(event:)` | 액션 전달 |
| `Action enum` | `sealed class Event` | 이벤트 정의 |
| `var state` | `data class UiState` | 상태 정의 |
| `async/await` | `suspend` | 비동기 |
| Protocol | Interface | 추상화 |

### 1.2 구조 비교

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

## 2. 모델 매핑

| iOS 파일 | Android 파일 | 상태 | 비고 |
|----------|-------------|------|------|
| `Models/WaterRecord.swift` | `domain/model/WaterRecord.kt` | ⏳ | data class |
| `Models/UserProfile.swift` | `domain/model/UserProfile.kt` | ⏳ | data class |
| `Models/NotificationSettings.swift` | `domain/model/NotificationSettings.kt` | ⏳ | data class |
| `Models/ModelType.swift` | ❌ | ❌ | Kotlin에서 불필요 |
| `Models/Info.swift` | `domain/model/SettingsItem.kt` | ⏳ | 설정 아이템 |
| `Models/AppVersion.swift` | `domain/model/AppVersion.kt` | ⏳ | - |
| `Models/AppUpdateConfig.swift` | `domain/model/AppUpdateConfig.kt` | ⏳ | - |

### 2.1 WaterRecord 상세 매핑

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

## 3. 서비스 매핑

| iOS 파일 | Android 파일 | 상태 | 비고 |
|----------|-------------|------|------|
| `Services/WaterService.swift` | `data/repository/WaterRepositoryImpl.kt` | ⏳ | Repository 패턴 |
| `Services/UserDefaultsService.swift` | `data/datastore/WaterDataStore.kt` | ⏳ | DataStore |
| `Services/HealthKitService.swift` | `service/health/HealthConnectHelper.kt` | ⏳ | Health Connect |
| `Services/NotificationService.swift` | `service/notification/NotificationHelper.kt` | ⏳ | WorkManager |
| `Services/WatchConnectivityService.swift` | `service/sync/DataLayerHelper.kt` | ⏳ | Wear Data Layer |
| `Services/AlertService.swift` | ❌ | ❌ | Compose Dialog 사용 |
| `Services/AdMobService.swift` | `service/ad/AdMobHelper.kt` | ⏳ | - |
| `Services/RemoteConfigService.swift` | `service/config/RemoteConfigHelper.kt` | ⏳ | - |
| `Services/AppUpdateChecker.swift` | `service/update/AppUpdateChecker.kt` | ⏳ | - |
| `Services/ServiceProvider.swift` | ❌ | ❌ | Hilt DI 사용 |
| `Services/BaseService.swift` | ❌ | ❌ | 불필요 |

### 3.1 WaterService → WaterRepository 상세 매핑

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

## 4. Store/ViewModel 매핑

| iOS 파일 | Android 파일 | 상태 | 비고 |
|----------|-------------|------|------|
| `Stores/HomeStore.swift` | `ui/home/HomeViewModel.kt` | ⏳ | MVI |
| `Stores/HistoryStore.swift` | `ui/history/HistoryViewModel.kt` | ⏳ | MVI |
| `Stores/SettingsStore.swift` | `ui/settings/SettingsViewModel.kt` | ⏳ | MVI |
| `Stores/OnboardingStore.swift` | `ui/onboarding/OnboardingViewModel.kt` | ⏳ | MVI |
| `Stores/ProfileStore.swift` | `ui/settings/ProfileViewModel.kt` | ⏳ | MVI |
| `Stores/NotificationStore.swift` | `ui/settings/NotificationViewModel.kt` | ⏳ | MVI |
| `Stores/CalendarStore.swift` | ❌ | ❌ | HistoryViewModel에 통합 |
| `Stores/MainStore.swift` | ❌ | ❌ | 불필요 |
| `Stores/DrinkStore.swift` | ❌ | ❌ | HomeViewModel에 통합 |
| `Stores/SettingStore.swift` | ❌ | ❌ | SettingsViewModel에 통합 |
| `Stores/InformationStore.swift` | ❌ | ❌ | SettingsViewModel에 통합 |
| `Stores/ObservationToken.swift` | ❌ | ❌ | StateFlow 사용 |

### 4.1 HomeStore → HomeViewModel 상세 매핑

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

## 5. View/Screen 매핑

| iOS 파일 | Android 파일 | 상태 | 비고 |
|----------|-------------|------|------|
| `Views/MainTabView.swift` | `ui/navigation/AppNavigation.kt` | ⏳ | Navigation Compose |
| `Views/HomeView.swift` | `ui/home/HomeScreen.kt` | ⏳ | Compose |
| `Views/HistoryView.swift` | `ui/history/HistoryScreen.kt` | ⏳ | Compose |
| `Views/AppGuideView.swift` | `ui/settings/WidgetGuideScreen.kt` | ⏳ | Compose |
| `ViewController/Settings/SettingsViewController.swift` | `ui/settings/SettingsScreen.kt` | ⏳ | Compose |
| `ViewController/Settings/NotificationSettingViewController.swift` | `ui/settings/NotificationSettingScreen.kt` | ⏳ | Compose |
| `ViewController/Settings/ProfileSettingViewController.swift` | `ui/settings/ProfileSettingScreen.kt` | ⏳ | Compose |
| `ViewController/Settings/WidgetGuideViewController.swift` | `ui/settings/WidgetGuideScreen.kt` | ⏳ | Compose |
| `ViewController/Onboarding/OnboardingViewController.swift` | `ui/onboarding/OnboardingScreen.kt` | ⏳ | Compose |
| `ViewController/Onboarding/OnboardingPageViewController.swift` | ❌ | ❌ | HorizontalPager 사용 |
| `ViewController/BaseComponent/BaseViewController.swift` | ❌ | ❌ | 불필요 |
| `IntroViewController.swift` | `ui/splash/SplashScreen.kt` | ⏳ | Compose |
| `SceneDelegate.swift` | `MainActivity.kt` | ⏳ | Activity |
| `AppDelegate.swift` | `DrinkSomeWaterApp.kt` | ⏳ | Application |

### 5.1 HomeView 컴포넌트 매핑

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

### 5.2 HistoryView 컴포넌트 매핑

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

## 6. 컴포넌트 매핑

| iOS 파일 | Android 파일 | 상태 | 비고 |
|----------|-------------|------|------|
| `Vendor/WaveAnimationView.swift` | `ui/components/WaveAnimation.kt` | ⏳ | Compose Canvas |
| `ViewComponent/WaveAnimationViewRepresentable.swift` | ❌ | ❌ | Compose 직접 사용 |
| `ViewComponent/FSCalendarRepresentable.swift` | `ui/components/CustomCalendar.kt` | ⏳ | 커스텀 구현 |
| `ViewComponent/Beaker.swift` | `ui/components/BottleView.kt` | ⏳ | Compose |
| `ViewComponent/WaterRecordResultView.swift` | `ui/components/RecordCard.kt` | ⏳ | Compose |
| `ViewComponent/CalendarDescriptView.swift` | ❌ | ❌ | CustomCalendar에 통합 |
| `ViewComponent/NativeAdView.swift` | `ui/components/NativeAdView.kt` | ⏳ | Compose |
| `ViewComponent/NativeAdTableViewCell.swift` | ❌ | ❌ | Compose 직접 사용 |
| `ViewComponent/IntrinsicTableView.swift` | ❌ | ❌ | LazyColumn 사용 |
| `ViewController/Settings/SettingsCell.swift` | ❌ | ❌ | Compose 직접 사용 |
| `ViewController/BaseComponent/BaseTableViewCell.swift` | ❌ | ❌ | 불필요 |

### 6.1 WaveAnimationView 상세 매핑

**iOS**
```swift
class WaveAnimationView: UIView {
    var progress: Float
    var frontColor: UIColor
    var backColor: UIColor
    // CADisplayLink로 애니메이션
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
        // drawPath로 물결 그리기
    }
}
```

---

## 7. 위젯 매핑

| iOS 파일 | Android 파일 | 상태 | 비고 |
|----------|-------------|------|------|
| `DrinkSomeWaterWidget/DrinkSomeWaterWidget.swift` | `widget/WaterGlanceWidget.kt` | ⏳ | Glance |
| `DrinkSomeWaterWidget/WaterEntry.swift` | `widget/WaterWidgetState.kt` | ⏳ | - |
| `DrinkSomeWaterWidget/WaterProvider.swift` | `widget/WaterWidgetReceiver.kt` | ⏳ | - |
| `DrinkSomeWaterWidget/Views/SmallWidgetView.swift` | `widget/ui/SmallWidget.kt` | ⏳ | Glance |
| `DrinkSomeWaterWidget/Views/MediumWidgetView.swift` | `widget/ui/MediumWidget.kt` | ⏳ | Glance |
| `DrinkSomeWaterWidget/Views/LargeWidgetView.swift` | `widget/ui/LargeWidget.kt` | ⏳ | Glance |
| `DrinkSomeWaterWidget/Views/LockScreenWidgetView.swift` | ❌ | ❌ | Android 잠금화면 위젯 없음 |
| `DrinkSomeWaterWidget/Intents/AddWaterIntent.swift` | `widget/action/AddWaterAction.kt` | ⏳ | ActionCallback |
| `Shared/WidgetDataManager.swift` | `widget/data/WidgetDataManager.kt` | ⏳ | DataStore |

### 7.1 위젯 크기 매핑

| iOS Family | Android Size | 크기 |
|------------|--------------|------|
| `.systemSmall` | `DpSize(110.dp, 110.dp)` | 2x2 |
| `.systemMedium` | `DpSize(250.dp, 110.dp)` | 4x2 |
| `.systemLarge` | `DpSize(250.dp, 250.dp)` | 4x4 |
| `.accessoryCircular` | ❌ | 해당 없음 |
| `.accessoryRectangular` | ❌ | 해당 없음 |
| `.accessoryInline` | ❌ | 해당 없음 |

---

## 8. Watch/Wear OS 매핑

| iOS 파일 | Android 파일 | 상태 | 비고 |
|----------|-------------|------|------|
| `DrinkSomeWaterWatch/Sources/DrinkSomeWaterWatchApp.swift` | `wear/WearApplication.kt` | ⏳ | Application |
| `DrinkSomeWaterWatch/Sources/Stores/WatchStore.swift` | `wear/WatchViewModel.kt` | ⏳ | ViewModel |
| `DrinkSomeWaterWatch/Sources/Views/ContentView.swift` | `wear/ui/WearNavigation.kt` | ⏳ | Navigation |
| `DrinkSomeWaterWatch/Sources/Views/HomeView.swift` | `wear/ui/HomeScreen.kt` | ⏳ | Wear Compose |
| `DrinkSomeWaterWatch/Sources/Views/QuickAddView.swift` | `wear/ui/QuickAddScreen.kt` | ⏳ | Wear Compose |
| `DrinkSomeWaterWatch/Sources/Views/CustomAmountView.swift` | `wear/ui/CustomAmountScreen.kt` | ⏳ | Wear Compose |
| `DrinkSomeWaterWatch/Sources/Complications/WaterComplication.swift` | `wear/complication/WaterComplicationService.kt` | ⏳ | Complication |
| `DrinkSomeWaterWatch/Sources/Complications/DrinkSomeWaterWidgetBundle.swift` | `wear/tile/WaterTileService.kt` | ⏳ | Tile |

### 8.1 Watch 통신 매핑

| iOS (WatchConnectivity) | Android (Data Layer) |
|-------------------------|----------------------|
| `WCSession.default` | `Wearable.getDataClient()` |
| `sendMessage(_:)` | `messageClient.sendMessage()` |
| `transferUserInfo(_:)` | `dataClient.putDataItem()` |
| `WCSessionDelegate` | `WearableListenerService` |
| `didReceiveMessage(_:)` | `onMessageReceived()` |
| `didReceiveUserInfo(_:)` | `onDataChanged()` |

---

## 9. 유틸리티 매핑

| iOS 파일 | Android 파일 | 상태 | 비고 |
|----------|-------------|------|------|
| `Extensions-Utillities/Date+Ext.swift` | `util/DateExtensions.kt` | ⏳ | - |
| `Extensions-Utillities/Float+Ext.swift` | ❌ | ❌ | Kotlin stdlib 사용 |
| `Extensions-Utillities/String+Ext.swift` | ❌ | ❌ | Kotlin stdlib 사용 |
| `Extensions-Utillities/UIView+Ext.swift` | ❌ | ❌ | Compose Modifier 사용 |
| `Types/UserDefaultsKey.swift` | `data/datastore/PreferencesKeys.kt` | ⏳ | - |
| `StaticComponent/NotificationMessages.swift` | `service/notification/NotificationMessages.kt` | ⏳ | - |
| `StaticComponent/WaterImage.swift` | ❌ | ❌ | Drawable 사용 |
| `DesignSystem/DesignTokens.swift` | `ui/theme/DesignTokens.kt` | ⏳ | - |

### 9.1 DesignTokens 매핑

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

## 10. Analytics 매핑

| iOS 파일 | Android 파일 | 상태 | 비고 |
|----------|-------------|------|------|
| `Analytics/Sources/Analytics.swift` | `analytics/AnalyticsTracker.kt` | ⏳ | - |
| `Analytics/Sources/AnalyticsEvent.swift` | `analytics/AnalyticsEvent.kt` | ⏳ | sealed class |
| `Analytics/Sources/AnalyticsUserProperty.swift` | `analytics/UserProperty.kt` | ⏳ | - |

### 10.1 Analytics Event 매핑

| iOS Event | Android Event |
|-----------|---------------|
| `.waterIntake(amountMl:, method:, hour:)` | `WaterIntake(amountMl, method, hour)` |
| `.goalAchieved(goalMl:, actualMl:, streakDays:)` | `GoalAchieved(goalMl, actualMl, streakDays)` |
| `.waterSubtracted(amountMl:)` | `WaterSubtracted(amountMl)` |
| `.waterReset(previousAmountMl:)` | `WaterReset(previousAmountMl)` |
| `.goalChanged(oldGoal:, newGoal:, source:)` | `GoalChanged(oldGoal, newGoal, source)` |
| `.calendarDateSelected(date:, hadRecords:, wasAchieved:)` | `CalendarDateSelected(date, hadRecords, wasAchieved)` |

---

## 부록: 빠른 참조

### A. 파일 검색 경로

| 기능 | iOS 경로 | Android 경로 |
|------|---------|-------------|
| 모델 | `DrinkSomeWater/Sources/Models/` | `app/.../domain/model/` |
| 서비스 | `DrinkSomeWater/Sources/Services/` | `app/.../data/repository/` |
| Store/VM | `DrinkSomeWater/Sources/Stores/` | `app/.../ui/[feature]/` |
| 뷰 | `DrinkSomeWater/Sources/Views/` | `app/.../ui/[feature]/` |
| 컴포넌트 | `DrinkSomeWater/Sources/ViewComponent/` | `app/.../ui/components/` |
| 디자인 | `DrinkSomeWater/Sources/DesignSystem/` | `app/.../ui/theme/` |
| 유틸 | `DrinkSomeWater/Sources/Extensions-Utillities/` | `app/.../util/` |
| 위젯 | `DrinkSomeWaterWidget/` | `widget/` |
| 워치 | `DrinkSomeWaterWatch/` | `wear/` |
| 분석 | `Analytics/` | `analytics/` |

### B. 관련 문서

- [프로젝트 계획서](./ANDROID_PROJECT_PLAN.md)
- [TDD 가이드](./ANDROID_TDD_GUIDE.md)
- [iOS 프로젝트 문서](../../ios/docs/IOS_PROJECT_DOCUMENTATION.md)
- [iOS 기술 명세](../../ios/docs/TECH_SPEC.md)
