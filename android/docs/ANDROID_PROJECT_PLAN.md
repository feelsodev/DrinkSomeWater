# Gulp Android Project Plan

> 💧 Water intake tracking Android & Wear OS app master document

---

## Meta Information

| Field | Value |
|-------|-------|
| **Version** | 1.0.0 |
| **Last Updated** | 2026-01-20 |
| **Status** | 📝 Documentation phase (pre-scaffolding) |
| **Development Approach** | TDD (Test-Driven Development) |
| **iOS Reference Version** | 26.2.0 |

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Project Structure](#3-project-structure)
4. [Task List by Phase](#4-task-list-by-phase)
5. [Dependency List](#5-dependency-list)
6. [Progress Log](#6-progress-log)

---

## 1. Project Overview

### 1.1 Goal
Build a complete Android version of the iOS Gulp app.

### 1.2 Scope
- ✅ Phone app (main)
- ✅ Home screen widget (Glance)
- ✅ Wear OS app

### 1.3 Core Features
| Feature | Description | iOS Reference |
|---------|-------------|---------------|
| Water intake logging | Quick logging via quick buttons | HomeView.swift |
| Subtract/reset water | Correct mistaken entries | HomeStore.swift |
| History view | Calendar/List/Timeline views | HistoryView.swift |
| Goal setting | Daily goal (1,000~4,500ml) | GoalSettingView |
| Quick button customization | Set frequently used amounts | QuickButtonSettingView |
| Notification system | 10 random motivational messages | NotificationService.swift |
| Health Connect | Body weight and water intake sync | HealthKitService.swift |
| Home widget | Small/Medium/Large widgets | DrinkSomeWaterWidget |
| Wear OS | Log water from watch | DrinkSomeWaterWatch |

### 1.4 Development Principles
1. **TDD required**: Write tests first, then implement, then refactor
2. **Same UX as iOS**: Maintain consistent user experience
3. **Clean Architecture**: Separate Domain/Data/UI layers
4. **Unidirectional data flow**: Apply MVI pattern

### 1.5 Current Status

> ⚠️ **Note**: This is currently in the **documentation phase**. The `android/` folder contains only documents. The actual Gradle project will be created in Phase 1.

```
Current state:
android/
├── docs/           ✅ Documentation (complete)
├── README.md       ✅ Guide (complete)
└── .gitignore      ✅ Config (complete)

After Phase 1:
android/
├── app/            ⏳ Main app module
├── widget/         ⏳ Widget module
├── wear/           ⏳ Wear OS module
├── analytics/      ⏳ Analytics module
├── gradle/         ⏳ Version Catalog
├── build.gradle.kts ⏳ Root build script
└── settings.gradle.kts ⏳ Module settings
```

### 1.6 Storage Strategy

| Data | Storage Method | Reason |
|------|----------------|--------|
| **Goal, quick buttons, settings** | DataStore Preferences | Simple key-value |
| **Water intake history** | DataStore Preferences + JSON serialization | Low record count (1 per day) |
| **Onboarding completion flag** | DataStore Preferences | Simple Boolean |

**History Storage Strategy:**
- 1 record per day → max 365 per year
- Serialize `List<WaterRecord>` to JSON for storage
- Migration: include version field, add conversion logic on schema changes
- Future scaling: consider migrating to Room DB if record count exceeds 1000

```kotlin
// Storage format example
@Serializable
data class WaterRecordsWrapper(
    val version: Int = 1,
    val records: List<WaterRecord>
)
```

### 1.7 Platform Constraints

#### Glance (Home Screen Widget)

| Constraint | Description | Workaround |
|------------|-------------|------------|
| **Limited Composables** | Only basic ones supported: Row, Column, Box, Text, Image, etc. | Compose Canvas not available → use PNG/Vector images |
| **Interaction limit** | Only clicks; no drag/swipe | Design quick buttons as simple clicks |
| **Style limit** | Cannot apply Material 3 theme directly | Use `glance-material3` adapter |
| **Update frequency** | Minimum 30-minute interval (system limit) | Immediate update on user action + periodic background update |
| **Size constraint** | Layout must branch based on widget size | Implement separate UI for Small/Medium/Large |

```kotlin
// Wave animation alternative strategy
// ❌ Compose Canvas (not supported in Glance)
// ✅ Static progress indicator (similar to CircularProgressIndicator)
// ✅ Or use pre-rendered image assets
```

#### Wear OS

| Constraint | Description | Workaround |
|------------|-------------|------------|
| **Data sync delay** | Phone ↔ Watch sync may take seconds to tens of seconds | Optimistic UI update + background sync |
| **Tile update limit** | System controls tile update timing | Call `TileService.getRequester().requestUpdate()` but immediate reflection not guaranteed |
| **Battery sensitivity** | Limited background work | Use Data Layer API, avoid unnecessary polling |
| **Screen size** | Small circular display | Show minimal info only, large touch targets |
| **Input limit** | Keyboard input is inconvenient | Replace direct input with 50ml stepper |
| **Standalone limit** | Phone app required (dependent app) | Show offline mode guidance when phone disconnected |

```kotlin
// Data sync strategy
// 1. Add water on Watch → immediately update local UI (optimistic)
// 2. Send to Phone via MessageClient
// 3. Phone processes and syncs confirmed data via DataClient
// 4. On conflict: Phone data takes priority (source of truth)
```

#### Health Connect

| Constraint | Description | Workaround |
|------------|-------------|------------|
| **Availability** | Built-in on Android 14+; earlier versions need separate app install | Check `HealthConnectClient.getSdkStatus()` or `sdkStatus`, guide to Play Store if not installed |
| **Permission flow** | Separate permission request per data type | Request weight read and water write permissions separately |
| **Regional restriction** | Unavailable on some countries/devices | Check availability via SDK status, graceful degradation if unavailable |
| **Background/periodic work** | Limited by OS policy/quota; foreground-focused design recommended | Fetch latest weight on app launch + local caching, handle background failure |
| **History access limit** | Past data access limited after permission grant (e.g., last 30 days) | Guide user when past data unavailable, fallback to manual input |
| **Data duplication** | Other apps may create duplicate records | Use `metadata.clientRecordId` to manage only our app's records |

```kotlin
// Health Connect initialization flow
// 1. Check HealthConnectClient.getSdkStatus(context)
//    - SDK_UNAVAILABLE: Health Connect not supported (disable feature)
//    - SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED: Guide to Play Store update
//    - SDK_AVAILABLE: Ready to use
// 2. Request permissions: HealthPermission.getReadPermission(WeightRecord::class)
//                         HealthPermission.getWritePermission(HydrationRecord::class)
// 3. On permission denied: disable feature, prompt manual weight entry
// 4. On history read failure/empty result: show "No recent records" message

// UX failure fallback flow
// - Health Connect sync ON but no data → "Please enter your weight manually"
// - Permission revoked → re-request on next launch or guide to settings
// - Write failure → save locally, retry later (best effort)
```

---

## 2. Tech Stack

### 2.1 iOS → Android Mapping

| Area | iOS | Android |
|------|-----|---------|
| **Language** | Swift 6 | Kotlin 2.0 |
| **UI Framework** | SwiftUI | Jetpack Compose |
| **Architecture** | @Observable Store | ViewModel + StateFlow (MVI) |
| **Async** | async/await | Coroutines + Flow |
| **DI** | Manual | Hilt |
| **Storage** | UserDefaults | DataStore Preferences |
| **Health** | HealthKit | Health Connect |
| **Widget** | WidgetKit | Glance API |
| **Watch** | WatchConnectivity | Wear OS Data Layer |
| **Calendar** | FSCalendar | Custom Compose |
| **Animation** | WaveAnimationView | Compose Canvas |
| **Analytics** | Firebase Analytics | Firebase Analytics |
| **Ads** | Google AdMob | Google AdMob |
| **Build** | Tuist | Gradle + Version Catalog |

### 2.2 Core Libraries

| Library | Version | Purpose |
|---------|---------|---------|
| Kotlin | 2.0.0 | Language |
| Compose BOM | 2024.09.00 | UI framework |
| Hilt | 2.51 | Dependency injection |
| DataStore | 1.1.1 | Local storage |
| Coroutines | 1.8.0 | Async processing |
| Glance | 1.1.0 | Widget |
| Health Connect | 1.1.0-alpha07 | Health data |
| Firebase BOM | 33.1.0 | Analytics/Ads |
| JUnit5 | 5.10.0 | Testing |
| Turbine | 1.1.0 | Flow testing |
| MockK | 1.13.10 | Mocking |

### 2.3 Build Environment

| Field | Value |
|-------|-------|
| minSdk | 29 (Android 10) |
| targetSdk | 35 (Android 15) |
| compileSdk | 35 |
| JDK | 17 |
| Gradle | 8.5 |
| AGP | 8.3.0 |

---

## 3. Project Structure

### 3.1 Module Structure

> ⚠️ **Important**: The `widget` and `wear` modules need to reuse domain/data code from `app`.
> A shared **`:core` module** separates models, Repository interfaces, and DataStore.

```
android/
├── core/                         # 🆕 Shared module (common to app, widget, wear)
│   ├── src/main/java/com/onceagain/drinksomewater/core/
│   │   ├── domain/               # Domain layer (shared)
│   │   │   ├── model/            # WaterRecord, UserProfile, etc.
│   │   │   └── repository/       # Repository interfaces
│   │   ├── data/                 # Data layer (shared)
│   │   │   ├── repository/       # Repository implementations
│   │   │   ├── datastore/        # DataStore
│   │   │   └── mapper/           # Data mappers
│   │   └── util/                 # Common utilities
│   ├── src/test/                 # core unit tests
│   └── build.gradle.kts
│
├── app/                          # Main app module (Phone)
│   ├── src/main/java/com/onceagain/drinksomewater/
│   │   ├── di/                   # Hilt modules
│   │   ├── ui/                   # UI layer
│   │   │   ├── home/             # Home screen
│   │   │   ├── history/          # History screen
│   │   │   ├── settings/         # Settings screen
│   │   │   ├── onboarding/       # Onboarding
│   │   │   ├── theme/            # Theme/design tokens
│   │   │   ├── components/       # Common components
│   │   │   └── navigation/       # Navigation
│   │   └── service/              # Services
│   │       ├── notification/     # Notifications
│   │       └── health/           # Health Connect
│   ├── src/test/                 # app unit tests (JUnit5)
│   ├── src/androidTest/          # UI tests (JUnit4)
│   └── build.gradle.kts          # implementation(project(":core"))
│
├── widget/                       # Glance widget module
│   ├── src/main/java/.../widget/
│   │   ├── WaterGlanceWidget.kt
│   │   ├── WaterWidgetReceiver.kt
│   │   ├── ui/
│   │   │   ├── SmallWidget.kt
│   │   │   ├── MediumWidget.kt
│   │   │   └── LargeWidget.kt
│   │   └── action/
│   │       └── AddWaterAction.kt
│   └── build.gradle.kts          # implementation(project(":core"))
│
├── wear/                         # Wear OS module
│   ├── src/main/java/.../wear/
│   │   ├── WearApplication.kt
│   │   ├── ui/
│   │   │   ├── HomeScreen.kt
│   │   │   ├── QuickAddScreen.kt
│   │   │   └── CustomAmountScreen.kt
│   │   ├── tile/
│   │   │   └── WaterTileService.kt
│   │   └── complication/
│   │       └── WaterComplicationService.kt
│   └── build.gradle.kts          # implementation(project(":core"))
│
├── analytics/                    # Analytics module
│   ├── src/main/java/.../analytics/
│   │   ├── Analytics.kt
│   │   ├── AnalyticsEvent.kt
│   │   └── AnalyticsTracker.kt
│   └── build.gradle.kts
│
├── docs/                         # Documentation
│   ├── ANDROID_PROJECT_PLAN.md   # This document
│   ├── ANDROID_TDD_GUIDE.md      # TDD guide
│   └── IOS_ANDROID_MAPPING.md    # File mapping
│
├── gradle/
│   └── libs.versions.toml        # Version Catalog
│
├── build.gradle.kts              # Root build script
├── settings.gradle.kts           # include(":core", ":app", ":widget", ":wear", ":analytics")
└── README.md                     # Build guide
```

#### Module Dependency Graph

```
              ┌─────────────┐
              │  analytics  │  (independent, usable anywhere)
              └─────────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
    ▼                ▼                ▼
┌───────┐       ┌─────────┐      ┌────────┐
│  app  │       │  widget │      │  wear  │
└───┬───┘       └────┬────┘      └───┬────┘
    │                │               │
    └────────────────┼───────────────┘
                     │
                     ▼
              ┌─────────────┐
              │    core     │  (shared domain + data)
              └─────────────┘
```

### 3.2 Package Structure

#### core module (shared)

```
com.onceagain.drinksomewater.core
├── domain
│   ├── model
│   │   ├── WaterRecord.kt
│   │   ├── UserProfile.kt
│   │   └── NotificationSettings.kt
│   └── repository
│       ├── WaterRepository.kt
│       ├── SettingsRepository.kt
│       └── ProfileRepository.kt
├── data
│   ├── repository
│   │   ├── WaterRepositoryImpl.kt
│   │   ├── SettingsRepositoryImpl.kt
│   │   └── ProfileRepositoryImpl.kt
│   ├── datastore
│   │   ├── WaterDataStore.kt
│   │   └── PreferencesKeys.kt
│   └── mapper
│       └── RecordMapper.kt
└── util
    ├── DateExtensions.kt
    └── FlowExtensions.kt
```

#### app module (Phone UI)

```
com.onceagain.drinksomewater
├── di
│   ├── AppModule.kt
│   ├── DataModule.kt
│   └── ServiceModule.kt
├── ui
│   ├── home
│   │   ├── HomeScreen.kt
│   │   ├── HomeViewModel.kt
│   │   ├── HomeUiState.kt
│   │   └── components/
│   ├── history
│   │   ├── HistoryScreen.kt
│   │   ├── HistoryViewModel.kt
│   │   └── components/
│   ├── settings
│   │   ├── SettingsScreen.kt
│   │   ├── SettingsViewModel.kt
│   │   └── screens/
│   ├── onboarding
│   │   ├── OnboardingScreen.kt
│   │   └── OnboardingViewModel.kt
│   ├── theme
│   │   ├── DesignTokens.kt
│   │   ├── Theme.kt
│   │   ├── Color.kt
│   │   └── Type.kt
│   ├── components
│   │   ├── WaveAnimation.kt
│   │   ├── BottleView.kt
│   │   ├── QuickButton.kt
│   │   ├── CustomCalendar.kt
│   │   └── RecordCard.kt
│   └── navigation
│       ├── AppNavigation.kt
│       └── Screen.kt
└── service
    ├── notification
    │   ├── NotificationHelper.kt
    │   ├── WaterReminderWorker.kt
    │   └── NotificationMessages.kt
    └── health
        └── HealthConnectHelper.kt
```

---

## 4. Task List by Phase

> ✅ Complete | 🚧 In Progress | ⏳ Pending | ❌ Blocked

### Phase 1: Initial Project Setup (est. 1 week) ✅

| # | Task | Test | Status | Notes |
|---|------|------|--------|-------|
| 1.1 | Create Android project | - | ✅ | Kotlin 2.0, Compose |
| 1.2 | Multi-module structure setup | - | ✅ | app, widget, wear, analytics |
| 1.3 | Version Catalog setup | - | ✅ | libs.versions.toml |
| 1.4 | Hilt DI setup | - | ✅ | Basic AppModule |
| 1.5 | Design system | DesignTokensTest | ✅ | DesignTokens.kt |
| 1.6 | Theme setup | - | ✅ | Material 3 theme |
| 1.7 | Navigation setup | - | ✅ | Navigation Compose |
| 1.8 | Test infrastructure | - | ✅ | JUnit5, Turbine, MockK |
| 1.9 | CI setup | - | ✅ | GitHub Actions (.github/workflows/android-ci.yml) |

### Phase 2: Data Layer (est. 1 week) ✅

| # | Task | Test | Status | iOS Reference |
|---|------|------|--------|---------------|
| 2.1 | WaterRecord model | WaterRecordTest | ✅ | WaterRecord.swift |
| 2.2 | UserProfile model | UserProfileTest | ✅ | UserProfile.swift |
| 2.3 | NotificationSettings model | NotificationSettingsTest | ✅ | NotificationSettings.swift |
| 2.4 | PreferencesKeys definition | - | ✅ | UserDefaultsKey.swift |
| 2.5 | WaterDataStore | WaterDataStoreTest | ✅ | UserDefaultsService.swift |
| 2.6 | WaterRepository interface | - | ✅ | WaterServiceProtocol |
| 2.7 | WaterRepositoryImpl | WaterRepositoryTest | ✅ | WaterService.swift |
| 2.8 | SettingsRepository | SettingsRepositoryTest | ✅ | - |

### Phase 3: Home Screen (est. 2 weeks) ✅

| # | Task | Test | Status | iOS Reference |
|---|------|------|--------|---------------|
| 3.1 | HomeUiState definition | - | ✅ | HomeStore state |
| 3.2 | HomeViewModel | HomeViewModelTest | ✅ | HomeStore.swift |
| 3.3 | WaveAnimation | WaveAnimationTest | ✅ | WaveAnimationView.swift |
| 3.4 | BottleView | - | ✅ | HomeView bottleSection |
| 3.5 | QuickButton component | - | ✅ | HomeView quickButtonsSection |
| 3.6 | HomeScreen layout | HomeScreenTest | ✅ | HomeView.swift |
| 3.7 | GoalSettingSheet | GoalSettingTest | ✅ | GoalSettingView |
| 3.8 | QuickButtonSettingSheet | - | ✅ | QuickButtonSettingView |
| 3.9 | NotificationBanner | - | ✅ | notificationBanner |
| 3.10 | Accessibility labels | - | ✅ | contentDescription, semantics applied |

### Phase 4: History Screen (est. 2 weeks) ✅

| # | Task | Test | Status | iOS Reference |
|---|------|------|--------|---------------|
| 4.1 | HistoryUiState definition | - | ✅ | HistoryStore state |
| 4.2 | HistoryViewModel | HistoryViewModelTest | ✅ | HistoryStore.swift |
| 4.3 | CustomCalendar | CustomCalendarTest | ✅ | FSCalendarRepresentable |
| 4.4 | CalendarTab | - | ✅ | HistoryCalendarTab |
| 4.5 | ListTab | - | ✅ | HistoryListTab |
| 4.6 | TimelineTab | - | ✅ | HistoryTimelineTab |
| 4.7 | RecordCard | - | ✅ | RecordCard |
| 4.8 | HistoryScreen (Pager) | HistoryScreenTest | ✅ | HistoryView.swift |
| 4.9 | MonthSummaryBadge | - | ✅ | monthSummaryBadge |

### Phase 5: Settings Screen (est. 1 week) ✅

| # | Task | Test | Status | iOS Reference |
|---|------|------|--------|---------------|
| 5.1 | SettingsViewModel | SettingsViewModelTest | ✅ | SettingsStore.swift |
| 5.2 | SettingsScreen | - | ✅ | SettingsViewController |
| 5.3 | NotificationSettingScreen | - | ✅ | NotificationSettingVC |
| 5.4 | ProfileSettingScreen | ProfileSettingTest | ✅ | ProfileSettingVC |
| 5.5 | WidgetGuideScreen | - | ✅ | WidgetGuideVC |
| 5.6 | AboutSection | - | ✅ | Version, review, contact |

### Phase 6: Notification System (est. 1 week) ✅

| # | Task | Test | Status | iOS Reference |
|---|------|------|--------|---------------|
| 6.1 | NotificationMessages | NotificationMessagesTest | ✅ | NotificationMessages.swift |
| 6.2 | NotificationHelper | NotificationHelperTest | ✅ | NotificationService.swift |
| 6.3 | WaterReminderWorker | WorkerTest | ✅ | - |
| 6.4 | NotificationChannel setup | - | ✅ | - |
| 6.5 | BootReceiver | - | ✅ | Reschedule notifications on boot |
| 6.6 | Permission request (Android 13+) | - | ✅ | PermissionHandler.kt |

### Phase 7: Home Screen Widget (est. 2 weeks) ✅

| # | Task | Test | Status | iOS Reference |
|---|------|------|--------|---------------|
| 7.1 | widget module setup | - | ✅ | DrinkSomeWaterWidget |
| 7.2 | WaterWidgetState | - | ✅ | WaterEntry.swift |
| 7.3 | WaterGlanceWidget | - | ✅ | DrinkSomeWaterWidget.swift |
| 7.4 | SmallWidget UI | SmallWidgetTest | ✅ | SmallWidgetView.swift |
| 7.5 | MediumWidget UI | MediumWidgetTest | ✅ | MediumWidgetView.swift |
| 7.6 | LargeWidget UI | LargeWidgetTest | ✅ | LargeWidgetView.swift |
| 7.7 | AddWaterAction | AddWaterActionTest | ✅ | AddWaterIntent.swift |
| 7.8 | Widget data sync | - | ✅ | WidgetDataManager.swift |

### Phase 8: Onboarding (est. 1 week) ✅

| # | Task | Test | Status | iOS Reference |
|---|------|------|--------|---------------|
| 8.1 | OnboardingViewModel | OnboardingViewModelTest | ✅ | OnboardingStore.swift |
| 8.2 | OnboardingScreen (Pager) | - | ✅ | OnboardingViewController |
| 8.3 | IntroPage | - | ✅ | App introduction |
| 8.4 | GoalSettingPage | - | ✅ | Goal setup |
| 8.5 | HealthConnectPage | - | ✅ | HealthKit integration |
| 8.6 | NotificationPage | - | ✅ | Notification setup |
| 8.7 | WidgetGuidePage | - | ✅ | Widget guide |
| 8.8 | Save completion flag | - | ✅ | onboardingCompleted |

### Phase 9: Health Connect (est. 1 week) ✅

| # | Task | Test | Status | iOS Reference |
|---|------|------|--------|---------------|
| 9.1 | Health Connect SDK setup | - | ✅ | HealthKitService.swift |
| 9.2 | HealthConnectHelper | HealthConnectHelperTest | ✅ | - |
| 9.3 | Read weight | - | ✅ | fetchWeight |
| 9.4 | Recommended intake calculation | RecommendedIntakeTest | ✅ | recommendedIntake |
| 9.5 | Save water intake record | - | ✅ | writeHydration |
| 9.6 | Permission request screen | - | ✅ | HealthConnectPermissionHandler |

### Phase 10: Analytics & AdMob (est. 1 week) ✅

| # | Task | Test | Status | iOS Reference |
|---|------|------|--------|---------------|
| 10.1 | analytics module setup | - | ✅ | Analytics/ |
| 10.2 | AnalyticsEvent definition | - | ✅ | AnalyticsEvent.swift |
| 10.3 | AnalyticsTracker | AnalyticsTrackerTest | ✅ | Analytics.swift |
| 10.4 | Firebase initialization | - | ✅ | google-services.json |
| 10.5 | AdMob initialization | - | ✅ | AdMobService.swift |
| 10.6 | NativeAdView | - | ✅ | NativeAdHelper.kt |
| 10.7 | RewardedAdHelper | - | ✅ | RewardedAdHelper.kt |

### Phase 11: Wear OS (est. 2 weeks) ✅

| # | Task | Test | Status | iOS Reference |
|---|------|------|--------|---------------|
| 11.1 | wear module setup | - | ✅ | DrinkSomeWaterWatch |
| 11.2 | WearApplication | - | ✅ | DrinkSomeWaterWatchApp |
| 11.3 | WatchViewModel | WatchViewModelTest | ✅ | WatchStore.swift |
| 11.4 | HomeScreen | - | ✅ | HomeView.swift (Watch) |
| 11.5 | QuickAddScreen | - | ✅ | QuickAddView.swift |
| 11.6 | CustomAmountScreen | - | ✅ | CustomAmountView.swift |
| 11.7 | DataLayerSync | DataLayerSyncTest | ✅ | WatchConnectivityService |
| 11.8 | WaterTileService | - | ✅ | WaterComplication.swift |
| 11.9 | Complication | - | ✅ | WaterComplicationService.kt |

### Phase 12: Testing & Finalization (est. 1 week) ✅

| # | Task | Status | Notes |
|---|------|--------|-------|
| 12.1 | Integration tests | ✅ | HomeScreenTest, NavigationTest |
| 12.2 | UI tests | ✅ | Compose UI tests |
| 12.3 | Accessibility verification | ✅ | contentDescription added, TalkBack support |
| 12.4 | Localization | ✅ | Korean/English (values-en) |
| 12.5 | ProGuard setup | ✅ | Full obfuscation rules (Hilt, Compose, Health Connect, etc.) |
| 12.6 | Release signing | ✅ | signing config + RELEASE_GUIDE.md |
| 12.7 | Play Store preparation | ✅ | PLAY_STORE_LISTING.md |

---

## 5. Dependency List

### 5.1 Version Catalog (libs.versions.toml)

> ⚠️ **Kotlin 2.0 + Compose setup**: Starting with Kotlin 2.0, the Compose compiler is integrated via the `org.jetbrains.kotlin.plugin.compose` plugin rather than a separate artifact. No separate `compose-compiler` version is specified.

```toml
[versions]
# Kotlin & Android
kotlin = "2.0.0"
agp = "8.3.0"
ksp = "2.0.0-1.0.21"

# Compose (no compose-compiler version needed with Kotlin 2.0)
compose-bom = "2024.09.00"
activity-compose = "1.9.0"
navigation-compose = "2.7.7"

# AndroidX
core-ktx = "1.13.1"
lifecycle = "2.8.0"
datastore = "1.1.1"
work = "2.9.0"

# Hilt
hilt = "2.51"
hilt-navigation-compose = "1.2.0"

# Widget
glance = "1.1.0"

# Wear OS
wear-compose = "1.3.1"
wear-tiles = "1.3.0"
play-services-wearable = "18.1.0"

# Health
health-connect = "1.1.0-alpha07"

# Firebase
firebase-bom = "33.1.0"

# AdMob
play-services-ads = "23.0.0"

# Testing
junit5 = "5.10.0"
turbine = "1.1.0"
mockk = "1.13.10"
coroutines-test = "1.8.0"
androidx-test-runner = "1.5.2"
androidx-test-rules = "1.5.0"

# Serialization
kotlinx-serialization = "1.6.3"
kotlinx-datetime = "0.6.0"

[libraries]
# Compose BOM
androidx-compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "compose-bom" }
androidx-compose-ui = { group = "androidx.compose.ui", name = "ui" }
androidx-compose-ui-graphics = { group = "androidx.compose.ui", name = "ui-graphics" }
androidx-compose-ui-tooling = { group = "androidx.compose.ui", name = "ui-tooling" }
androidx-compose-ui-tooling-preview = { group = "androidx.compose.ui", name = "ui-tooling-preview" }
androidx-compose-material3 = { group = "androidx.compose.material3", name = "material3" }
androidx-compose-material-icons = { group = "androidx.compose.material", name = "material-icons-extended" }

# Activity & Navigation
androidx-activity-compose = { group = "androidx.activity", name = "activity-compose", version.ref = "activity-compose" }
androidx-navigation-compose = { group = "androidx.navigation", name = "navigation-compose", version.ref = "navigation-compose" }

# Lifecycle
androidx-lifecycle-runtime = { group = "androidx.lifecycle", name = "lifecycle-runtime-ktx", version.ref = "lifecycle" }
androidx-lifecycle-viewmodel-compose = { group = "androidx.lifecycle", name = "lifecycle-viewmodel-compose", version.ref = "lifecycle" }

# DataStore
androidx-datastore-preferences = { group = "androidx.datastore", name = "datastore-preferences", version.ref = "datastore" }

# WorkManager
androidx-work-runtime = { group = "androidx.work", name = "work-runtime-ktx", version.ref = "work" }

# Hilt
hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }
hilt-compiler = { group = "com.google.dagger", name = "hilt-android-compiler", version.ref = "hilt" }
hilt-navigation-compose = { group = "androidx.hilt", name = "hilt-navigation-compose", version.ref = "hilt-navigation-compose" }

# Glance (Widget)
androidx-glance = { group = "androidx.glance", name = "glance", version.ref = "glance" }
androidx-glance-appwidget = { group = "androidx.glance", name = "glance-appwidget", version.ref = "glance" }
androidx-glance-material3 = { group = "androidx.glance", name = "glance-material3", version.ref = "glance" }

# Wear OS
androidx-wear-compose-foundation = { group = "androidx.wear.compose", name = "compose-foundation", version.ref = "wear-compose" }
androidx-wear-compose-material = { group = "androidx.wear.compose", name = "compose-material", version.ref = "wear-compose" }
androidx-wear-tiles = { group = "androidx.wear.tiles", name = "tiles", version.ref = "wear-tiles" }
play-services-wearable = { group = "com.google.android.gms", name = "play-services-wearable", version.ref = "play-services-wearable" }

# Health Connect
health-connect = { group = "androidx.health.connect", name = "connect-client", version.ref = "health-connect" }

# Firebase
firebase-bom = { group = "com.google.firebase", name = "firebase-bom", version.ref = "firebase-bom" }
firebase-analytics = { group = "com.google.firebase", name = "firebase-analytics-ktx" }
firebase-crashlytics = { group = "com.google.firebase", name = "firebase-crashlytics-ktx" }

# AdMob
play-services-ads = { group = "com.google.android.gms", name = "play-services-ads", version.ref = "play-services-ads" }

# Serialization
kotlinx-serialization-json = { group = "org.jetbrains.kotlinx", name = "kotlinx-serialization-json", version.ref = "kotlinx-serialization" }
kotlinx-datetime = { group = "org.jetbrains.kotlinx", name = "kotlinx-datetime", version.ref = "kotlinx-datetime" }

# Testing - JVM (src/test/)
junit5 = { group = "org.junit.jupiter", name = "junit-jupiter", version.ref = "junit5" }
turbine = { group = "app.cash.turbine", name = "turbine", version.ref = "turbine" }
mockk = { group = "io.mockk", name = "mockk", version.ref = "mockk" }
kotlinx-coroutines-test = { group = "org.jetbrains.kotlinx", name = "kotlinx-coroutines-test", version.ref = "coroutines-test" }

# Testing - Instrumented (src/androidTest/)
androidx-test-runner = { group = "androidx.test", name = "runner", version.ref = "androidx-test-runner" }
androidx-test-rules = { group = "androidx.test", name = "rules", version.ref = "androidx-test-rules" }
mockk-android = { group = "io.mockk", name = "mockk-android", version.ref = "mockk" }
hilt-android-testing = { group = "com.google.dagger", name = "hilt-android-testing", version.ref = "hilt" }
androidx-compose-ui-test = { group = "androidx.compose.ui", name = "ui-test-junit4" }
androidx-compose-ui-test-manifest = { group = "androidx.compose.ui", name = "ui-test-manifest" }

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
android-library = { id = "com.android.library", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
kotlin-serialization = { id = "org.jetbrains.kotlin.plugin.serialization", version.ref = "kotlin" }
ksp = { id = "com.google.devtools.ksp", version.ref = "ksp" }
hilt = { id = "com.google.dagger.hilt.android", version.ref = "hilt" }
# Kotlin 2.0: Compose compiler plugin (no separate version needed, uses kotlin version)
compose-compiler = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
google-services = { id = "com.google.gms.google-services", version = "4.4.1" }
firebase-crashlytics = { id = "com.google.firebase.crashlytics", version = "2.9.9" }

# Note: build.gradle.kts usage example
# plugins {
#     alias(libs.plugins.kotlin.android)
#     alias(libs.plugins.compose.compiler)  // Kotlin 2.0 Compose plugin
# }

[bundles]
compose = [
    "androidx-compose-ui",
    "androidx-compose-ui-graphics",
    "androidx-compose-ui-tooling-preview",
    "androidx-compose-material3",
    "androidx-compose-material-icons"
]
compose-debug = [
    "androidx-compose-ui-tooling",
    "androidx-compose-ui-test-manifest"
]
lifecycle = [
    "androidx-lifecycle-runtime",
    "androidx-lifecycle-viewmodel-compose"
]
# JVM tests (src/test/)
testing-jvm = [
    "junit5",
    "turbine",
    "mockk",
    "kotlinx-coroutines-test"
]

# Instrumented tests (src/androidTest/)
testing-android = [
    "androidx-test-runner",
    "androidx-test-rules",
    "mockk-android",
    "androidx-compose-ui-test"
]
```

---

## 6. Progress Log

### 2026-01-20

**Completed:**
- [x] Android project plan established
- [x] TDD guide document written
- [x] iOS-Android mapping table written
- [x] Document structure finalized

**Next steps:**
- Start Phase 1: Initial project setup

---

### 2026-01-21

**Completed (Phase 12 finalization):**
- [x] 12.1 UI Tests - HomeScreenTest.kt, NavigationTest.kt created
- [x] 12.2 UI Tests complete
- [x] 12.3 Accessibility - contentDescription, semantics added
- [x] 12.4 Localization - values-en/strings.xml (app, wear, widget)
- [x] 12.5 ProGuard - proguard-rules.pro complete for all modules
- [x] 12.6 Release signing - signingConfigs added, RELEASE_GUIDE.md created
- [x] 12.7 Play Store - PLAY_STORE_LISTING.md created

**Missing items filled in:**
- [x] 1.9 CI setup - .github/workflows/android-ci.yml created
- [x] 6.5 BootReceiver - BootReceiver.kt created and updated
- [x] 6.6 Permission request - PermissionHandler.kt created
- [x] 9.6 Health Connect permission - HealthConnectPermissionHandler added
- [x] 10.6 NativeAdHelper - NativeAdHelper.kt created
- [x] 10.7 RewardedAdHelper - RewardedAdHelper.kt created
- [x] 11.9 Complication - WaterComplicationService.kt, ic_water_drop.xml created

**Build results:**
- `./gradlew assembleDebug test` succeeded
- All unit tests passing

**Project status:**
- ✅ Phases 1-12 all complete
- ✅ Full build successful
- ✅ All tests passing

---

### Template (copy and use)

```markdown
### YYYY-MM-DD

**Completed:**
- [ ] 

**In Progress:**
- [ ] 

**Blockers:**
- 

**Next steps:**
- 
```

---

## Appendix

### A. Command Reference

```bash
# Build
./gradlew build

# Test (all)
./gradlew test

# Test (by module)
./gradlew :app:test
./gradlew :widget:test
./gradlew :wear:test

# Coverage report
./gradlew koverHtmlReport

# Install app
./gradlew :app:installDebug
./gradlew :wear:installDebug

# Lint
./gradlew lint

# Clean build
./gradlew clean build
```

### B. Related Document Links

- [TDD Guide](./ANDROID_TDD_GUIDE.md)
- [iOS-Android Mapping](./IOS_ANDROID_MAPPING.md)
- [Build Guide](../README.md)
- [iOS Project Documentation](../../ios/docs/IOS_PROJECT_DOCUMENTATION.md)
- [iOS Tech Spec](../../ios/docs/TECH_SPEC.md)
