# Gulp (벌컥벌컥) - iOS Project Detailed Documentation

> 💧 Complete guide to the water intake tracking iOS & watchOS app
> 
> **This document is for iOS/watchOS platform only.** See the `android/` folder for Android documentation.

**Last Updated**: January 20, 2026  
**Version**: 26.2.0  
**Author**: Auto-generated Documentation

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Domain Model](#3-domain-model)
4. [Feature Specifications](#4-feature-specifications)
5. [User Flow](#5-user-flow)
6. [Business Policies](#6-business-policies)
7. [Data Analytics](#7-data-analytics)
8. [Infrastructure & Build](#8-infrastructure--build)

---

## 1. Project Overview

### 1.1 App Overview

**Gulp (벌컥벌컥)** is an iOS app that lets users easily record and track their daily water intake. It supports Apple Watch, home screen widgets, and Apple Health sync.

### 1.2 Core Values

| Value | Description |
|-------|-------------|
| **Simplicity** | Record water with a single tap via quick buttons |
| **Visualization** | Wave animation shows progress at a glance |
| **Continuity** | Real-time sync across iPhone, Apple Watch, and widgets |
| **Motivation** | 10 randomized notification messages to build consistent habits |

### 1.3 Target Platforms

| Platform | Minimum Version | Type |
|----------|----------------|------|
| iOS | 26.0+ | Main app |
| watchOS | 11.0+ | Companion app |
| WidgetKit | iOS 26.0+ | Home/Lock screen widgets |

> **Note**: iOS 26.0 is an internal development version number. It will be adjusted to match the latest iOS version at the time of actual release.

### 1.4 App Structure Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                         iOS App                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │  Intro (Splash) → Onboarding (first launch only)        │   │
│   └────────────────────────┬────────────────────────────────┘   │
│                            ▼                                     │
│   ┌─────────────┬─────────────┬─────────────┐                   │
│   │     💧      │     📅      │     ⚙️      │                   │
│   │    Today    │   History   │  Settings   │   ← MainTabView   │
│   │  HomeView   │ HistoryView │  Settings   │                   │
│   └─────────────┴─────────────┴─────────────┘                   │
│                            │                                     │
│              ┌─────────────┼─────────────┐                      │
│              ▼             ▼             ▼                      │
│         Widget        HealthKit   WatchConnectivity             │
└──────────────┬─────────────┬─────────────┬──────────────────────┘
               │             │             │
               ▼             ▼             ▼
         Home Widget    Apple Health   Apple Watch
```

---

## 2. Tech Stack

### 2.1 Core Technologies

| Category | Technology | Version |
|----------|-----------|---------|
| **Language** | Swift | 6.0 |
| **UI Framework** | SwiftUI + UIKit | - |
| **Architecture** | @Observable Store Pattern | - |
| **Concurrency** | async/await, Swift Concurrency | - |
| **Build System** | Tuist | 4.x |

### 2.2 External Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **Firebase iOS SDK** | 11.0.0+ | Analytics, Crashlytics, RemoteConfig |
| **Google Mobile Ads** | 11.2.0+ | Native ads, rewarded ads |
| **SnapKit** | 5.7.0+ | Auto-layout DSL (UIKit) |
| **FSCalendar** | 2.8.4+ | Calendar UI component |

### 2.3 System Frameworks

| Framework | Purpose |
|-----------|---------|
| **HealthKit** | Read body weight, sync water intake |
| **WidgetKit** | Home/Lock screen widgets |
| **WatchConnectivity** | Real-time iPhone ↔ Watch sync |
| **UserNotifications** | Local push notifications |
| **AppIntents** | Interactive widget buttons |

### 2.4 Architecture Pattern: @Observable Store

Unidirectional data flow architecture inspired by ReactorKit:

```swift
@MainActor
@Observable
final class HomeStore {
    enum Action {
        case refresh
        case addWater(Int)
        case subtractWater(Int)
        case resetTodayWater
    }
    
    var total: Float = 0       // Goal amount
    var ml: Float = 0          // Current intake
    var progress: Float { ... } // Calculated progress
    
    func send(_ action: Action) async {
        switch action {
        case .addWater(let amount):
            // Water add logic
        }
    }
}
```

**Usage:**
```swift
struct HomeView: View {
    @Bindable var store: HomeStore
    
    var body: some View {
        Text("\(Int(store.ml))ml")
            .task { await store.send(.refresh) }
    }
}
```

---

## 3. Domain Model

### 3.1 Core Entities

#### WaterRecord

```swift
struct WaterRecord: ModelType, Identifiable {
    var id: String { date.dateToString }
    var date: Date          // Record date
    var value: Int          // Intake amount (ml)
    var isSuccess: Bool     // Goal achieved
    var goal: Int           // Daily goal for this date (ml)
}
```

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `date` | Date | Record date/time | 2026-01-20 14:30:00 |
| `value` | Int | Water intake amount (ml) | 1500 |
| `isSuccess` | Bool | Goal achieved | true |
| `goal` | Int | Daily goal (ml) | 2000 |

#### UserProfile

```swift
struct UserProfile: Codable, Equatable {
    var weight: Double              // Body weight (kg)
    var useHealthKitWeight: Bool    // Use HealthKit weight
    
    var recommendedIntake: Int {    // Recommended intake calculation
        Int(weight * 33)            // weight(kg) × 33ml
    }
    
    static var `default`: UserProfile {
        UserProfile(weight: 65, useHealthKitWeight: false)
    }
}
```

#### NotificationSettings

```swift
struct NotificationSettings {
    var isEnabled: Bool                    // Notifications enabled
    var startTime: NotificationTime        // Start time (default 08:00)
    var endTime: NotificationTime          // End time (default 22:00)
    var interval: NotificationInterval     // Notification interval
    var enabledWeekdays: Set<Weekday>      // Active weekdays
    var customTimes: [NotificationTime]    // Custom notification times
}

enum NotificationInterval: Int {
    case thirtyMinutes = 30    // 30 minutes
    case oneHour = 60          // 1 hour
    case twoHours = 120        // 2 hours
    case threeHours = 180      // 3 hours
}
```

### 3.2 State Management (Stores)

#### Core Stores

| Store | File | Role | Key State |
|-------|------|------|-----------|
| **HomeStore** | `HomeStore.swift` | Today tab state | `ml`, `total`, `progress`, `quickButtons` |
| **HistoryStore** | `HistoryStore.swift` | History tab state | `waterRecordList`, `successDates`, `selectedRecord` |
| **ProfileStore** | `ProfileStore.swift` | Profile management | `profile`, `dailyGoal` |
| **NotificationStore** | `NotificationStore.swift` | Notification state | `isAuthorized`, `settings` |
| **OnboardingStore** | `OnboardingStore.swift` | Onboarding state | `currentPage`, `goal` |
| **CalendarStore** | `CalendarStore.swift` | Calendar state | `selectedDate`, `events` |
| **InformationStore** | `InformationStore.swift` | App info | `appVersion` |

#### Settings-Related Stores (Watch for Similar Names)

> ⚠️ **Note**: `SettingStore` and `SettingsStore` are **separate Stores** and both are currently in use.

| Store | File | Purpose | Creation |
|-------|------|---------|----------|
| **SettingStore** (singular) | `SettingStore.swift` | Goal setting modal only | `MainStore.createSettingStore()` |
| **SettingsStore** (plural) | `SettingsStore.swift` | Full settings tab management | Created directly |

**SettingStore** (singular):
```swift
// Used in goal setting modal, shouldDismiss pattern
var value: Int = 0
var shouldDismiss: Bool = false
enum Action { case loadGoal, changeGoalWater(Int), setGoal, cancel }
```

**SettingsStore** (plural):
```swift
// Used in settings tab, manages goal + quick buttons
var goalValue: Int = 2000
var quickButtons: [Int] = [100, 200, 300, 500]
enum Action { case loadGoal, updateGoal(Int), loadQuickButtons, updateQuickButtons([Int]) }
```

#### Utility Stores

| Store | File | Role | Creation |
|-------|------|------|----------|
| **MainStore** | `MainStore.swift` | Global state + factory | Created directly |
| **DrinkStore** | `DrinkStore.swift` | Water add actions | `MainStore.createDrinkStore()` |

### 3.3 Service Layer

| Service | Protocol | Role |
|---------|----------|------|
| **WaterService** | `WaterServiceProtocol` | Water intake CRUD |
| **UserDefaultsService** | `UserDefaultsServiceProtocol` | Local data storage |
| **HealthKitService** | `HealthKitServiceProtocol` | Apple Health integration |
| **NotificationService** | `NotificationServiceProtocol` | Push notification management |
| **WatchConnectivityService** | `WatchConnectivityServiceProtocol` | Watch sync |
| **AlertService** | `AlertServiceProtocol` | Alert display |
| **AdMobService** | - | Ad management |
| **RemoteConfigService** | - | Firebase remote config |

### 3.4 Data Storage Keys (UserDefaults)

| Key | Type | Description |
|-----|------|-------------|
| `current` | `[[String: Any]]` | Water intake records array |
| `goal` | `Int` | Daily goal (ml) |
| `quickButtons` | `[Int]` | Quick button settings |
| `customQuickButtons` | `[Int]` | Custom quick button settings |
| `notificationEnabled` | `Bool` | Notifications enabled |
| `notificationStartHour` | `Int` | Notification start hour |
| `notificationStartMinute` | `Int` | Notification start minute |
| `notificationEndHour` | `Int` | Notification end hour |
| `notificationEndMinute` | `Int` | Notification end minute |
| `notificationIntervalMinutes` | `Int` | Notification interval (minutes) |
| `notificationWeekdays` | `[Int]` | Notification weekdays |
| `notificationCustomTimes` | `[[String: Int]]` | Custom notification times array |
| `userWeight` | `Double` | User body weight (kg) |
| `useHealthKitWeight` | `Bool` | Use HealthKit weight |
| `notificationBannerDismissed` | `Bool` | Notification banner dismissed |
| `onboardingCompleted` | `Bool` | Onboarding completed |

> **Source of Truth**: `DrinkSomeWater/Sources/Services/UserDefaultsService.swift`

---

## 4. Feature Specifications

### 4.1 Today Tab (HomeView)

**Purpose**: Record today's water intake and visualize progress

#### Feature List

| Feature | Description | Implementation |
|---------|-------------|----------------|
| **Water intake recording** | Add a set amount via quick buttons | `HomeStore.addWater(Int)` |
| **Water intake correction** | Subtract incorrectly recorded amount | `HomeStore.subtractWater(Int)` |
| **Today reset** | Reset the day's record | `HomeStore.resetTodayWater` |
| **Goal editing** | Change daily goal | `GoalSettingView` sheet |
| **Quick button customization** | Add/delete/reorder buttons | `QuickButtonSettingView` sheet |
| **Progress visualization** | Wave animation display | `WaveAnimationView` |
| **Remaining amount display** | ml and cup count remaining to goal | `store.remainingMl`, `store.remainingCups` |

#### Quick Button Defaults

```swift
static let defaultQuickButtons = [100, 200, 300, 500]  // ml units
```

#### UI Components

```
┌─────────────────────────────────────┐
│  [Notification banner - shown when  │
│   permission not granted]           │
├─────────────────────────────────────┤
│           1500ml                    │  ← Current intake (display font)
│      Goal: 2000ml ✏️               │  ← Goal + edit button
│   💧 About 2 more cups to go!      │  ← Motivational message
├─────────────────────────────────────┤
│       ┌─────────────────┐           │
│       │    ≈≈≈≈≈≈≈     │           │  ← Wave animation bottle
│       │   ≈≈≈≈≈≈≈≈≈    │           │     (progress visualization)
│       │  ≈≈≈≈≈≈≈≈≈≈≈   │           │
│       └─────────────────┘           │
├─────────────────────────────────────┤
│  Quick Add ▼     [+/-🔄] [Edit]    │
│  ┌────────┐ ┌────────┐              │
│  │+100ml  │ │+200ml  │              │  ← Quick buttons (2 rows)
│  └────────┘ └────────┘              │
│  ┌────────┐ ┌────────┐              │
│  │+300ml  │ │+500ml  │              │
│  └────────┘ └────────┘              │
└─────────────────────────────────────┘
```

### 4.2 History Tab (HistoryView)

**Purpose**: Review past water intake records in multiple view modes

#### View Modes

| Mode | Icon | Description |
|------|------|-------------|
| **Calendar** | 📅 | Monthly achievement overview via FSCalendar |
| **List** | 📋 | Records sorted newest first |
| **Timeline** | 🕐 | Timeline grouped by month |

#### Calendar Mode Features

- Highlight achieved dates (primary color)
- Show detail card on date selection
- Achievement stats badge for current month

#### List Mode Features

- Sorted newest first
- Progress bar per record
- Native ad inserted every 5 records

#### Timeline Mode Features

- Section grouping by month
- Vertical timeline UI
- Monthly achievement stats

### 4.3 Settings Tab (SettingsViewController)

**Purpose**: App settings and user profile management

#### Settings Items

| Section | Item | Description |
|---------|------|-------------|
| **Profile** | Daily goal | 1,000ml ~ 4,500ml (100ml increments) |
| | Quick button settings | Custom button add/delete/reorder |
| | Apple Health | Weight sync, water intake recording |
| **Notifications** | Notification settings | Time, interval, weekday settings |
| **Info** | Widget guide | Widget installation instructions |
| | Rate app | App Store review link |
| | Contact us | Email link |
| | Version | Current app version |

### 4.4 Onboarding

**Purpose**: Guide users through app setup on first launch

#### Onboarding Pages (5 Steps)

| Order | Page | Content |
|-------|------|---------|
| 1 | **Intro** | App introduction and welcome message |
| 2 | **Goal Setting** | Set daily goal with a slider |
| 3 | **HealthKit** | Apple Health integration permission request |
| 4 | **Notifications** | Push notification permission request |
| 5 | **Widget** | Home screen widget installation guide |

#### Onboarding Flow

```
[Intro] → [Goal Setting] → [HealthKit] → [Notifications] → [Widget] → [Main App]
    ↓ (skippable)                                                         ↓
    └───────────────── Save onboarding completed flag ──────────────────┘
```

### 4.5 Home Screen Widgets

**Purpose**: Check and record water intake without opening the app

#### Widget Types

| Size | Features | Interactive |
|------|----------|-------------|
| **Small** | Circular progress + percentage + intake | ❌ |
| **Medium** | Progress + 2 quick add buttons | ✅ (150ml, 300ml) |
| **Large** | Progress + motivational message + 3 buttons | ✅ (150ml, 300ml, 500ml) |
| **Lock Screen Circular** | Circular gauge | ❌ |
| **Lock Screen Rectangular** | Intake/goal display | ❌ |
| **Lock Screen Inline** | Text format | ❌ |

#### Data Sync

```swift
// Data sharing via App Group
WidgetDataManager.shared.syncFromMainApp(todayWater: value, goal: goal)
WidgetCenter.shared.reloadAllTimelines()
```

### 4.6 Apple Watch App

**Purpose**: Record water intake directly from the wrist

#### Watch Screens

| Screen | Features |
|--------|----------|
| **Home** | Today's intake, goal, and progress display |
| **Quick Add** | 150ml, 250ml, 300ml, 500ml buttons |
| **Custom Amount** | Adjust in 50ml increments |

#### Watch Complications

| Type | Display |
|------|---------|
| **Circular** | Progress gauge |
| **Rectangular** | Intake/goal detail |
| **Corner** | Icon + percentage |
| **Inline** | Text format |

#### iPhone ↔ Watch Sync

```swift
// iPhone → Watch
watchConnectivityService.syncToWatch(todayWater: value, goal: goal)

// Watch → iPhone (bidirectional)
session.sendMessage(["action": "addWater", "amount": 150], ...)
```

### 4.7 Notification System

**Purpose**: Regular water drinking reminders

#### Notification Messages (10 random)

```swift
static let messages = [
    "Time to drink water! 💧",
    "Focus UP! How about a glass of water? 🧠",
    "A glass of water for a healthy day! 🌿",
    "Hydration time~ 💦",
    "Drink up and feel refreshed! ✨",
    "Keep going toward your daily goal! 💪",
    "Take a moment with a glass of water 🍃",
    "A small habit for your health: drink water 💙",
    "How about a glass of water right now? 🥤",
    "Hydrate! Drink some water 💧"
]
```

#### Notification Scheduling Policy

- **Max notifications**: 64 (iOS limit)
- **Scheduling method**: Combination of weekday × time slot
- **Interval options**: 30 minutes, 1 hour, 2 hours, 3 hours
- **Time window**: Sent only within start–end time range

---

## 5. User Flow

### 5.1 First Launch Flow

```
Install app → Launch app → Intro (Splash)
                                ↓
                          Onboarding starts
                                ↓
                ┌─────────────────────────┐
                │   1. App intro page     │
                │   2. Goal setting       │
                │   3. HealthKit permission│
                │   4. Notification perm  │
                │   5. Widget guide       │
                └───────────┬─────────────┘
                            ↓
                 Save onboarding completed flag
                            ↓
                      Enter main app
                    (HomeView - Today tab)
```

### 5.2 Daily Use Flow

```
Launch app → Today tab (HomeView)
                  │
                  ├── [Quick button tap] → Add water → Widget/Watch sync
                  │                                   → Analytics event
                  │                                   → HealthKit save
                  │
                  ├── [+/- toggle] → Subtract mode → Remove water
                  │
                  ├── [Edit goal] → Show sheet → Save goal
                  │
                  └── [Edit quick buttons] → Add/delete/reorder
```

### 5.3 History Review Flow

```
History tab (HistoryView)
      │
      ├── [Calendar mode] → Tap date → Show record card for that day
      │                              → Analytics: calendar_date_selected
      │
      ├── [List mode] → Scroll → Check records
      │                        → Ad shown every 5 records
      │
      └── [Timeline mode] → Check monthly groups
```

### 5.4 Watch Use Flow

```
Launch Watch app → Home screen (progress display)
                        │
                        ├── [Quick Add] → Tap button → Add water
                        │                              → Sync to iPhone
                        │
                        └── [Custom Amount] → Adjust amount → Confirm → Add water
```

### 5.5 Widget Use Flow

```
Home screen → Check widget (progress)
                  │
                  └── [Medium/Large widget] → Tap button
                                                  ↓
                                         Execute AddWaterIntent
                                                  ↓
                                         Add water + reload widget
```

---

## 6. Business Policies

### 6.1 Water Intake Policies

| Policy | Rule |
|--------|------|
| **Default goal** | 2,000ml (changeable during onboarding) |
| **Goal range** | 1,000ml ~ 4,500ml (100ml increments) |
| **Recommended intake** | weight(kg) × 33 = recommended intake(ml) |
| **Default quick buttons** | 100ml, 200ml, 300ml, 500ml |
| **Record unit** | 1ml increments (quick buttons use user settings) |
| **Daily reset** | New WaterRecord created at midnight |

### 6.2 Goal Achievement Determination

```swift
// Goal achievement condition
isSuccess = (todayValue >= dailyGoal)

// Streak calculation
func calculateStreak() -> Int {
    // Count consecutive achievement days going backward from today
    // Streak resets if any day is missed
}
```

### 6.3 Notification Policies

| Policy | Value | Source |
|--------|-------|--------|
| **Default start time** | 08:00 | `NotificationSettings.default` |
| **Default end time** | 22:00 | `NotificationSettings.default` |
| **Default interval** | 1 hour (`.oneHour`) | `NotificationSettings.default` |
| **Service fallback interval** | 2 hours (120 minutes) | `NotificationService.loadSettings()` |
| **Default weekdays** | Mon–Sun (all days) | `Weekday.allCases` |
| **Max notifications** | 64 (iOS limit) | `maxPendingNotifications` |
| **Notification messages** | Random selection from 10 | `NotificationMessages.random` |

> **Note**: `NotificationSettings.default` uses `.oneHour` (1 hour), but the fallback value in `NotificationService.loadSettings()` is 120 minutes (2 hours). Actual behavior is determined in order: saved value → service fallback.

### 6.4 Data Sync Policies

| Sync Target | Timing | Direction |
|-------------|--------|-----------|
| **Widget** | Immediately on water add/change | App → Widget |
| **Watch** | Immediately on water add/change | Bidirectional |
| **HealthKit** | On water add | App → Health |
| **Offline Watch** | When Watch not connected | Pending, then sync on reconnect |

#### Widget Interactive Sync Flow

Since the app may not be running when water is added from a widget, a **pending mechanism** is used:

```
[Widget button tap]
      │
      ▼
[Execute AddWaterIntent]
      │
      ▼
[WidgetDataManager.addWater(amount)]
      │
      ├─ todayWater += amount (immediate)
      ├─ needsSync = true (pending flag)
      └─ pendingWater = amount (pending amount)
      │
      ▼
[On next app launch]
      │
      ▼
[WidgetDataManager.checkPendingWaterFromWidget()]
      │
      ├─ Return pendingWater
      └─ needsSync = false, pendingWater = 0 (reset)
      │
      ▼
[WaterService.updateWater(pendingWater)]
```

**Source**: `Shared/WidgetDataManager.swift:69-100`

### 6.5 Advertising Policies

| Ad Type | Location | Frequency |
|---------|----------|-----------|
| **Native ad** | History list | 1 ad per 5 records |
| **Rewarded ad** | Settings (optional) | On user request |

### 6.6 Data Retention Policies

- **Local storage**: UserDefaults + App Group
- **Record retention**: Unlimited (no delete feature)
- **Backup**: Included in iCloud backup
- **Sync conflict**: Latest timestamp wins

---

## 7. Data Analytics

### 7.1 Analytics Module Structure

```
Analytics/
├── Sources/
│   ├── Analytics.swift              # Singleton service
│   ├── AnalyticsEvent.swift         # Event definitions (50+ events)
│   └── AnalyticsUserProperty.swift  # User property definitions
```

### 7.2 Event Tiers (Priority)

#### Tier 1: Core Events

| Event | Parameters | Trigger |
|-------|-----------|---------|
| `water_intake` | `amount_ml`, `method`, `hour` | Water added |
| `goal_achieved` | `goal_ml`, `actual_ml`, `streak_days` | Goal achieved |
| `goal_failed` | `goal_ml`, `actual_ml`, `percentage` | Not achieved at midnight |
| `app_open` | `hour`, `day_of_week`, `days_since_install` | App launched |
| `screen_view` | `screen_name`, `previous_screen` | Screen transition |

#### Tier 2: Onboarding Funnel

| Event | Parameters | Trigger |
|-------|-----------|---------|
| `onboarding_started` | `source` | Onboarding starts |
| `onboarding_step_viewed` | `step` | Each step entered |
| `onboarding_step_completed` | `step`, `time_spent_sec` | Each step completed |
| `onboarding_skipped` | `step` | Skip button tapped |
| `onboarding_completed` | `total_time_sec` | Onboarding completed |
| `first_water_intake` | `amount_ml`, `minutes_since_install` | First water record |
| `permission_requested` | `type` (notification/healthkit) | Permission requested |
| `permission_granted` | `type` | Permission granted |
| `permission_denied` | `type` | Permission denied |

#### Tier 3: Feature Usage

| Event | Parameters | Trigger |
|-------|-----------|---------|
| `water_subtracted` | `amount_ml` | Water subtracted |
| `water_reset` | `previous_amount_ml` | Today reset |
| `quick_button_tap` | `amount_ml`, `button_index`, `is_custom` | Quick button tapped |
| `goal_changed` | `old_goal`, `new_goal`, `source` | Goal changed |
| `goal_quick_set_used` | `new_goal` | Quick goal set used |
| `quick_button_customized` | `button_index`, `amount_ml` | Button customized |
| `calendar_viewed` | `month`, `year` | Calendar view |
| `calendar_date_selected` | `date`, `had_records`, `was_achieved` | Date selected |
| `notification_setting_changed` | `enabled`, `start_time`, `end_time`, `interval_hours` | Notification setting changed |
| `widget_added` | `widget_type` | Widget added |
| `widget_interaction` | `widget_type`, `action`, `amount_ml` | Widget interaction |

#### Tier 4: HealthKit

| Event | Parameters | Trigger |
|-------|-----------|---------|
| `healthkit_connected` | - | Connection success |
| `healthkit_disconnected` | `reason` | Connection removed |
| `healthkit_sync_success` | `record_count`, `sync_type` | Sync success |
| `healthkit_sync_failed` | `error_code`, `error_message` | Sync failed |
| `weight_updated` | `weight_kg`, `source` | Weight updated |
| `recommended_goal_accepted` | `recommended_ml`, `weight_kg` | Recommended goal accepted |
| `recommended_goal_rejected` | `recommended_ml`, `custom_ml` | Recommended goal rejected |

#### Tier 5: Retention

| Event | Parameters | Trigger |
|-------|-----------|---------|
| `streak_achieved` | `streak_days` | Streak achieved |
| `streak_broken` | `previous_streak_days` | Streak broken |
| `notification_received` | `notification_id`, `message_type` | Notification received |
| `notification_tapped` | `notification_id`, `time_to_tap_sec` | Notification tapped |
| `notification_dismissed` | `notification_id` | Notification dismissed |
| `inactive_return` | `days_inactive` | Return after inactivity |

#### Tier 6: Monetization

**Ad Events (currently implemented)**:

| Event | Parameters | Trigger |
|-------|-----------|---------|
| `ad_impression` | `ad_type`, `ad_unit_id`, `screen` | Ad shown |
| `ad_clicked` | `ad_type`, `ad_unit_id` | Ad clicked |
| `ad_closed` | `ad_type`, `view_duration_sec` | Ad closed |
| `rewarded_ad_started` | `reward_type` | Rewarded ad started |
| `rewarded_ad_completed` | `reward_type`, `reward_amount` | Rewarded ad completed |

**In-App Purchase Events (defined in Analytics module, StoreKit not yet implemented)**:

| Event | Parameters | Status |
|-------|-----------|--------|
| `premium_prompt_shown` | `trigger_point`, `variant` | 🔮 Future implementation |
| `purchase_started` | `product_id`, `price` | 🔮 Future implementation |
| `purchase_completed` | `product_id`, `price`, `currency` | 🔮 Future implementation |
| `purchase_failed` | `product_id`, `error_code` | 🔮 Future implementation |

> **Note**: In-app purchase events are defined in `AnalyticsEvent.swift` but the app currently has no StoreKit implementation. These are pre-defined for future premium feature introduction.

### 7.3 User Properties

| Property | Type | Description |
|----------|------|-------------|
| `daily_goal_ml` | Int | Daily goal |
| `weight_kg` | Double | Body weight |
| `notification_enabled` | Bool | Notifications enabled |
| `healthkit_enabled` | Bool | HealthKit connected |
| `onboarding_completed` | Bool | Onboarding completed |
| `days_since_install` | Int | Days since install |
| `total_intake_count` | Int | Total record count |
| `current_streak` | Int | Current streak days |
| `user_segment` | String | User segment (light/medium/heavy) |
| `premium_status` | String | Premium status (free/premium) |
| `app_version` | String | App version |
| `ios_version` | String | iOS version |

### 7.4 Event Flow

```
[User Action]
      │
      ▼
[Store.send(action)]
      │
      ▼
[Business logic executed]
      │
      ▼
[Analytics.shared.log(event)]
      │
      ├─ #if canImport(FirebaseAnalytics) ──→ Send to Firebase Analytics (always)
      │
      └─ #if DEBUG ──→ Console output (additionally)
```

> **Important**: Firebase Analytics sending is determined by the `canImport(FirebaseAnalytics)` condition, independent of build configuration (Debug/Release). The `ENABLE_ANALYTICS` xcconfig flag is not actually checked in the current code. In Debug builds, output goes to both Firebase and the console.
>
> **Source**: `Analytics/Sources/Analytics.swift:29-36`

### 7.5 Key Analytics Metrics

| Metric | Definition | Use |
|--------|-----------|-----|
| **DAU** | Daily active users | Daily engagement |
| **Water intake frequency** | Average daily record count | Engagement indicator |
| **Goal achievement rate** | Days achieved / active days | Core KPI |
| **Streak distribution** | Consecutive achievement day distribution | Retention indicator |
| **Onboarding completion rate** | Completed / started | Funnel analysis |
| **Notification CTR** | Tapped / received | Notification effectiveness |
| **Widget usage rate** | Widget water adds / total water adds | Feature adoption rate |

---

## 8. Infrastructure & Build

### 8.1 Build System

| Item | Value |
|------|-------|
| **Build tool** | Tuist 4 |
| **Version management** | mise (`.mise.toml`) |
| **Swift version** | 6.0 |
| **iOS target** | 26.0+ |
| **watchOS target** | 11.0+ |

### 8.2 Project Targets

| Target | Type | Bundle ID |
|--------|------|-----------|
| **DrinkSomeWater** | iOS App | `com.onceagain.DrinkSomeWater` |
| **DrinkSomeWaterWidget** | App Extension | `com.onceagain.DrinkSomeWater.Widget` |
| **DrinkSomeWaterWatch** | watchOS App | `com.onceagain.DrinkSomeWater.watchkitapp` |
| **Analytics** | Framework | `com.onceagain.DrinkSomeWater.Analytics` |
| **DrinkSomeWaterTests** | Unit Tests | `com.feelso.DrinkSomeWaterTests` |

### 8.3 Build Settings

#### Debug Settings

```xcconfig
APP_BUNDLE_ID = com.onceagain.DrinkSomeWater.debug
APP_NAME = DrinkSomeWater-Dev
ADMOB_APP_ID = ca-app-pub-3940256099942544~1458002511  // Test ID
ENABLE_ANALYTICS = NO
ENABLE_DEBUG_MENU = YES
LOG_LEVEL = verbose
```

#### Release Settings

```xcconfig
APP_BUNDLE_ID = com.onceagain.DrinkSomeWater
APP_NAME = DrinkSomeWater
ADMOB_APP_ID = ca-app-pub-8353974542825246~9138292219  // Production ID
ENABLE_ANALYTICS = YES
ENABLE_DEBUG_MENU = NO
LOG_LEVEL = error
```

### 8.4 CI/CD

#### Xcode Cloud

```bash
# ci_scripts/ci_post_clone.sh
mise install           # Install Tuist
tuist install          # Install SPM dependencies
tuist generate --no-open  # Generate project
```

```bash
# ci_scripts/ci_post_xcodebuild.sh
# Upload dSYM to Firebase Crashlytics
```

#### GitHub Actions

| Workflow | Trigger | Function |
|---------|---------|---------|
| **auto-tag.yml** | Manual | Create version tag + GitHub Release |
| **update-version.yml** | Manual | Create version update PR |

### 8.5 Version Management

```
Version format: YY.WW.N
- YY: Year (25 = 2025)
- WW: Week number (1~52)
- N: Patch number

Example: 26.2.0 = Year 2026, Week 2, first release
```

### 8.6 Build Commands

```bash
# Set up development environment
mise install tuist

# Generate project
tuist install
tuist generate

# Build
tuist build

# Test
tuist test

# Open in Xcode
open DrinkSomeWater.xcworkspace
```

### 8.7 Entitlements

| Target | Permissions |
|--------|------------|
| **Main App** | HealthKit, App Groups |
| **Widget** | App Groups |
| **Watch** | App Groups |

**App Group ID**: `group.com.onceagain.DrinkSomeWater`

### 8.8 Tests

| Module | Test File | Cases |
|--------|-----------|-------|
| HomeStore | HomeStoreTests.swift | 12 |
| WaterService | WaterServiceTests.swift | 13 |
| HistoryStore | HistoryStoreTests.swift | 8 |
| ProfileStore | ProfileStoreTests.swift | 12 |
| Notification | NotificationTests.swift | 10 |
| Models | DrinkSomeWaterTests.swift | 11 |

**Total tests**: 53+ cases

---

## Appendix

### A. Design System (DesignTokens)

```swift
typealias DS = DesignTokens

// Spacing
DS.Spacing.xs     // 8pt
DS.Spacing.sm     // 12pt
DS.Spacing.md     // 16pt
DS.Spacing.lg     // 20pt
DS.Spacing.xl     // 24pt

// Corner Radius
DS.Size.cornerRadiusSmall   // 8pt
DS.Size.cornerRadiusMedium  // 12pt
DS.Size.cornerRadiusLarge   // 16pt
DS.Size.cornerRadiusPill    // 32pt

// Colors
DS.Color.primary        // #59BFF2 (main blue)
DS.Color.success        // #59C79E (success green)
DS.Color.textPrimary    // #333340 (primary text)
DS.Color.textSecondary  // #808088 (secondary text)
DS.Color.backgroundPrimary  // #F5F5F8 (background)
```

### B. Localization Keys

| Key | Korean | English |
|-----|--------|---------|
| `home.goal` | 목표: %@ml | Goal: %@ml |
| `home.goal.achieved` | 오늘 목표 달성! | Goal achieved! |
| `home.goal.remaining` | 약 %@컵 더 마시면 달성! | %@ more cups to go! |
| `history.title` | 기록 | History |
| `settings.title` | 설정 | Settings |

### C. File Structure

```
DrinkSomeWater/
├── DrinkSomeWater/           # iOS main app
│   ├── Sources/
│   │   ├── Views/            # SwiftUI views
│   │   ├── Stores/           # @Observable Store
│   │   ├── Services/         # Business logic
│   │   ├── Models/           # Data models
│   │   ├── ViewComponent/    # Reusable components
│   │   ├── ViewController/   # UIKit controllers
│   │   ├── DesignSystem/     # Design tokens
│   │   └── Extensions-Utilities/
│   └── Resources/
├── DrinkSomeWaterWatch/      # watchOS app
├── DrinkSomeWaterWidget/     # Widget
├── Analytics/                # Analytics module
├── DrinkSomeWaterTests/      # Tests
├── Shared/                   # Shared code
├── Tuist/                    # Build settings
└── docs/                     # Documentation
```

---

**End of document**
