# DrinkSomeWater Technical Specification

> SwiftUI + UIKit + @Observable + async/await Architecture

## 1. Overview

### 1.1 Project Summary
- **App Name**: Gulp (벌컥벌컥) - Water intake tracking iOS app
- **Architecture**: SwiftUI + UIKit + @Observable Store + async/await
- **Min iOS**: iOS 26+
- **Swift**: Swift 6
- **UI Framework**: SwiftUI (Home, History), UIKit (Settings, Onboarding)

### 1.2 Core Features
| Feature | Description |
|---------|-------------|
| Water intake recording | Quickly log water intake with quick buttons |
| Water subtraction/reset | Correct mislogged amounts and reset the day's record |
| Goal setting | Custom daily goal (1,000–4,000ml) |
| Record lookup | 3 view modes: calendar, list, and timeline |
| Quick button customization | Configure frequently used amounts (add/delete/reorder) |
| HealthKit integration | Sync water intake and body weight with the Apple Health app |
| Personalized recommendation | Calculate daily recommended intake based on body weight |
| Random notification messages | 10 localized motivational messages |
| Home screen widget | Small/Medium/Large size widgets |
| Lock screen widget | Circular/Rectangular/Inline widgets |
| Interactive widget | Add water directly from widget via AppIntent |
| Onboarding flow | 5-step app introduction and setup guide |
| Watch app | Record water intake and view complications from the wrist |
| Native Ad | Native ads displayed in the record list |

---

## 2. Architecture

### 2.1 App Flow

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   Intro (Splash)                                            │
│         │                                                   │
│         ▼                                                   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │           🆕 Onboarding (first launch only)         │   │
│   │  [App Intro] → [Goal] → [HealthKit] → [Notif] → [Widget] │
│   │                    (skippable)                       │   │
│   └─────────────────────────────────────────────────────┘   │
│         │                                                   │
│         ▼                                                   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                                                     │   │
│   │              [ Main Content ]                       │   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   ┌─────────────┬─────────────┬─────────────┐               │
│   │     💧      │     📅      │     ⚙️      │               │
│   │    Today    │   History   │  Settings   │               │
│   └─────────────┴─────────────┴─────────────┘               │
│                                                             │
│   🆕 Widget (Home screen / Lock screen)                     │
│   ┌─────────┐ ┌─────────────────┐ ┌───┐                     │
│   │ Small   │ │    Medium       │ │🔒 │                     │
│   │ 60%/💧  │ │ +150ml  +300ml  │ │60%│                     │
│   └─────────┘ └─────────────────┘ └───┘                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 @Observable Store Pattern

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  ViewController │────▶│      Store      │────▶│    Service      │
│                 │◀────│   @Observable   │◀────│                 │
│  - render()     │     │  - send(Action) │     │  - async/await  │
│  - observation  │     │  - @MainActor   │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                      │
         └──────────────────────┘
         withObservationTracking
```

### 2.3 Store Example

```swift
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
    }

    let provider: ServiceProviderProtocol

    var total: Float = 0
    var ml: Float = 0
    var progress: Float { total == 0 ? 0 : ml / total }
    var remainingMl: Int { max(0, Int(total - ml)) }
    var remainingCups: Int { remainingMl / 250 }
    var quickButtons: [Int] = [100, 200, 300, 500]
    var showNotificationBanner: Bool = false

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

        case .addWater(let amount):
            _ = await provider.waterService.updateWater(by: Float(amount))
            await send(.refresh)
            Analytics.shared.logWaterIntake(amountMl: amount, method: .quickButton)

        case .subtractWater(let amount):
            let newValue = max(0, Int(ml) - amount)
            let diff = Int(ml) - newValue
            if diff > 0 {
                _ = await provider.waterService.updateWater(by: Float(-diff))
                await send(.refresh)
            }

        case .resetTodayWater:
            _ = await provider.waterService.resetTodayWater()
            await send(.refresh)

        // ... other actions
        }
    }
}
```

### 2.4 SwiftUI View Binding

```swift
struct HomeView: View {
    @Bindable var store: HomeStore
    @State private var showGoalSetting = false

    var body: some View {
        VStack {
            Text("\(Int(store.ml))ml")
                .font(.system(size: 48, weight: .bold))

            Text(String(format: "Goal: %@ml", "\(Int(store.total))"))

            // Quick buttons
            ForEach(store.quickButtons, id: \.self) { amount in
                Button("+\(amount)ml") {
                    Task { await store.send(.addWater(amount)) }
                }
            }
        }
        .task {
            await store.send(.refreshGoal)
            await store.send(.refresh)
        }
        .sheet(isPresented: $showGoalSetting) {
            GoalSettingView(...)
        }
    }
}
```

### 2.5 UIKit ViewController (Settings)

```swift
final class SettingsViewController: BaseViewController {
    private let store: SettingsStore

    override func viewDidLoad() {
        super.viewDidLoad()
        observation = startObservation { [weak self] in self?.render() }

        Task {
            await store.send(.loadGoal)
        }
    }

    override func render() {
        // UIKit-based settings screen rendering
    }
}
```

---

## 3. File Structure

```
DrinkSomeWater/Sources/
├── AppDelegate.swift
├── SceneDelegate.swift
├── IntroViewController.swift
├── Environment.swift                    # Environment configuration
│
├── DesignSystem/
│   └── DesignTokens.swift              # DS design tokens (Color, Font, Size)
│
├── Extensions-Utillities/
│   ├── Date+Ext.swift
│   ├── Float+Ext.swift
│   ├── String+Ext.swift
│   └── UIView+Ext.swift
│
├── Models/
│   ├── Info.swift
│   ├── ModelType.swift
│   ├── NotificationSettings.swift
│   ├── UserProfile.swift               # User profile (weight, recommended intake)
│   ├── WaterRecord.swift
│   ├── AppVersion.swift                # App version model
│   └── AppUpdateConfig.swift           # Update configuration
│
├── Services/
│   ├── AlertService.swift
│   ├── BaseService.swift
│   ├── HealthKitService.swift          # HealthKit integration
│   ├── NotificationService.swift
│   ├── ServiceProvider.swift
│   ├── UserDefaultsService.swift
│   ├── WaterService.swift
│   ├── AdMobService.swift              # 🆕 AdMob ad service
│   ├── WatchConnectivityService.swift  # 🆕 Watch connectivity service
│   ├── RemoteConfigService.swift       # 🆕 Remote config service
│   └── AppUpdateChecker.swift          # 🆕 App update checker
│
├── StaticComponent/
│   ├── NotificationMessages.swift      # Notification messages (localized)
│   └── WaterImage.swift
│
├── Stores/
│   ├── ObservationToken.swift
│   ├── HomeStore.swift
│   ├── HistoryStore.swift
│   ├── NotificationStore.swift
│   ├── ProfileStore.swift              # Profile/HealthKit integration
│   ├── SettingsStore.swift
│   ├── OnboardingStore.swift           # Onboarding state management
│   ├── DrinkStore.swift (legacy)
│   ├── CalendarStore.swift (legacy)
│   ├── MainStore.swift (legacy)
│   ├── SettingStore.swift (legacy)
│   └── InformationStore.swift (legacy) # Info screen Store
│
├── Types/
│   └── UserDefaultsKey.swift
│
├── Vendor/
│   └── WaveAnimationView.swift
│
├── Views/                              # 🆕 SwiftUI Views
│   ├── MainTabView.swift               # SwiftUI TabView (main)
│   ├── HomeView.swift                  # Home screen (SwiftUI)
│   ├── HistoryView.swift               # History screen (SwiftUI)
│   └── AppGuideView.swift              # App guide view
│
├── ViewComponent/
│   ├── Beaker.swift
│   ├── CalendarDescriptView.swift
│   ├── IntrinsicTableView.swift
│   ├── WaterRecordResultView.swift
│   ├── FSCalendarRepresentable.swift   # 🆕 FSCalendar SwiftUI wrapper
│   ├── WaveAnimationViewRepresentable.swift  # 🆕 Wave animation wrapper
│   ├── NativeAdView.swift              # 🆕 Native ad view
│   └── NativeAdTableViewCell.swift     # 🆕 Ad table cell
│
└── ViewController/
    ├── BaseComponent/
    │   ├── BaseTableViewCell.swift
    │   └── BaseViewController.swift
    │
    ├── Onboarding/
    │   ├── OnboardingViewController.swift
    │   └── OnboardingPageViewController.swift
    │
    └── Settings/
        ├── SettingsViewController.swift
        ├── SettingsCell.swift
        ├── NotificationSettingViewController.swift
        ├── ProfileSettingViewController.swift
        └── WidgetGuideViewController.swift  # 🆕 Widget guide

Shared/
└── WidgetDataManager.swift             # Shared data for main app + widget

DrinkSomeWaterWidget/
├── DrinkSomeWaterWidget.swift          # Widget Entry Point
├── WaterEntry.swift                    # Timeline Entry
├── WaterProvider.swift                 # Timeline Provider
├── Views/
│   ├── SmallWidgetView.swift           # 2x2 widget
│   ├── MediumWidgetView.swift          # 4x2 widget + buttons
│   ├── LargeWidgetView.swift           # 4x4 widget + motivational message
│   └── LockScreenWidgetView.swift      # Lock screen widget
└── Intents/
    └── AddWaterIntent.swift            # AppIntent

DrinkSomeWaterWatch/
└── Sources/
    ├── DrinkSomeWaterWatchApp.swift
    ├── Stores/
    │   └── WatchStore.swift
    ├── Views/
    │   ├── ContentView.swift
    │   ├── HomeView.swift
    │   ├── QuickAddView.swift
    │   └── CustomAmountView.swift
    └── Complications/
        ├── DrinkSomeWaterWidgetBundle.swift  # Widget bundle
        └── WaterComplication.swift           # Complication view
```

---

## 4. Screen Specifications

### 4.1 Home (Today) - SwiftUI

```
┌────────────────────────────────────────┐
│   [Notification banner - shown when    │
│    permission missing]                 │
│   🔔 Turn on notifications to get...  │
│                                        │
│            1,200ml                     │ ← Current intake
│        ┌──────────────┐                │
│        │ Goal: 2000ml ✏️│              │ ← Tap to set goal
│        └──────────────┘                │
│                                        │
│   ┌────────────────────────────────┐   │
│   │  💧 2 more cups to reach goal! │   │ ← Remaining cups
│   └────────────────────────────────┘   │
│                                        │
│         ┌──────────────┐               │
│         │    Bottle    │               │
│         │  Wave Anim   │               │
│         └──────────────┘               │
│                                        │
│   Quick Add ──────── [+/-] [Edit]     │ ← Toggle add/subtract mode
│                                        │
│   ┌────────┐ ┌────────┐                │
│   │  +100  │ │  +200  │                │ ← Quick buttons (customizable)
│   └────────┘ └────────┘                │
│   ┌────────┐ ┌────────┐                │
│   │  +300  │ │  +500  │                │
│   └────────┘ └────────┘                │
│                                        │
└────────────────────────────────────────┘
```

**View**: `HomeView.swift` (SwiftUI)
**Store**: `HomeStore`
**Actions**: `refresh`, `refreshGoal`, `refreshQuickButtons`, `addWater(Int)`, `subtractWater(Int)`, `resetTodayWater`, `checkNotificationPermission`, `dismissNotificationBanner`

### 4.2 History (Record) - SwiftUI

```
┌────────────────────────────────────────┐
│   📅 History          📊 12 achieved  │
│                                        │
│   ┌─────────┬─────────┬─────────┐      │
│   │Calendar │  List   │Timeline │      │ ← 3 view modes
│   └─────────┴─────────┴─────────┘      │
│                                        │
│   [Calendar Mode]                      │
│   ┌────────────────────────────────┐   │
│   │        FSCalendar              │   │
│   │    (achieved dates highlighted)│   │
│   └────────────────────────────────┘   │
│   ● Today  ● Selected  ● Achieved     │ ← Legend
│                                        │
│   [List Mode]                          │
│   ┌────────────────────────────────┐   │
│   │ 15 │ Friday    ████████░░ 80%  │   │
│   │ Jan│ 1600/2000ml       ✓      │   │
│   └────────────────────────────────┘   │
│   ┌── Native Ad ────────────────────┐  │ ← Every 5 records
│   └────────────────────────────────┘   │
│                                        │
│   [Timeline Mode]                      │
│   January 2025           7/15 achieved │
│   ● 15th (Fri) - 1600ml    ✓ achieved  │
│   │                                    │
│   ● 14th (Thu) - 2100ml    ✓ achieved  │
│                                        │
└────────────────────────────────────────┘
```

**View**: `HistoryView.swift` (SwiftUI)
**Store**: `HistoryStore`
**Actions**: `viewDidLoad`, `selectDate(Date)`
**State**: `waterRecordList`, `successDates`, `selectedRecord`, `monthlySuccessCount`

### 4.3 Settings - UIKit

```
┌────────────────────────────────────────┐
│   ⚙️ Settings                          │
│                                        │
│   ─────────── Goal ───────────         │
│   │ 🎯 Daily goal          2,000ml >│   │
│                                        │
│   ─────────── Quick Buttons ─────────  │
│   │ ⚡ Quick button setup  100,200... >│  │
│                                        │
│   ─────────── Notifications ─────────  │
│   │ 🔔 Water reminders              >│  │
│                                        │
│   ─────────── Health ─────────         │
│   │ 🍎 Profile (HealthKit)          >│  │
│                                        │
│   ─────────── Help ───────────         │
│   │ 📱 Widget setup guide           >│  │
│                                        │
│   ─────────── Support ────────         │
│   │ ⭐ Rate the app                  │  │
│   │ 💬 Contact us                   │  │
│   │ 🎁 Support developer (Rewarded) │  │
│   │ 📄 Open source licenses        >│  │
│                                        │
│   ─────────── Info ───────────         │
│   │ Version                 25.1.1  │  │
│                                        │
└────────────────────────────────────────┘
```

**View**: `SettingsViewController.swift` (UIKit)
**Store**: `SettingsStore`
**Actions**: `loadGoal`, `updateGoal(Int)`, `loadQuickButtons`, `updateQuickButtons([Int])`

### 4.4 Bottom Sheets / Modals

| Sheet | Purpose | Trigger | Type |
|-------|---------|---------|------|
| GoalSettingView | Goal setting (1,000–4,000ml) | Home goal tap | SwiftUI Sheet |
| QuickButtonSettingView | Quick button customization (add/delete/reorder) | Home edit button | SwiftUI Sheet |
| WaterAdjustmentView | Water subtraction/reset | Home | SwiftUI Sheet |

---

## 5. Dependencies

### 5.1 Tuist SPM

```swift
// Tuist/Package.swift
let package = Package(
    name: "DrinkSomeWater",
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.7.0"),
        .package(url: "https://github.com/WenchaoD/FSCalendar", from: "2.8.4"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", from: "11.2.0"),
    ]
)
```

### 5.2 Internal Modules

- `Analytics` - Firebase Analytics wrapper module

### 5.3 Local Vendor

- `WaveAnimationView.swift` - Wave animation (included locally, not available via SPM)

---

## 6. Data Flow

### 6.1 Water Recording

```
User taps Quick Button
        │
        ▼
HomeViewController.addWater(amount)
        │
        ▼
HomeStore.send(.addWater(amount))
        │
        ▼
WaterService.updateWater(by: amount)
        │
        ▼
Save to UserDefaults
        │
        ▼
HomeStore.send(.refresh)
        │
        ▼
UI auto-updates (Observation)
```

### 6.2 Goal Setting

```
User opens Goal Sheet
        │
        ▼
GoalSettingViewController
        │
        ▼
Slider changed → currentGoal updated
        │
        ▼
Save tapped
        │
        ▼
WaterService.updateGoal(to: value)
        │
        ▼
dismiss → onSave callback
        │
        ▼
HomeStore.send(.refreshGoal)
```

---

## 7. Swift Concurrency

### 7.1 Isolation Model

```
┌─────────────────────────────────────────────────────┐
│                    MainActor                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │ HomeStore   │  │HistoryStore│  │SettingsStore│  │
│  │ @Observable │  │ @Observable │  │ @Observable │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │           ViewControllers                   │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
                        │
                        ▼ async/await
┌─────────────────────────────────────────────────────┐
│                    Services                         │
│  ┌─────────────────────────────────────────────┐    │
│  │  WaterService, UserDefaultsService          │    │
│  │  (UserDefaults synchronous access - no I/O) │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

### 7.2 Key Patterns

```swift
// Store: runs on UI thread via @MainActor
@MainActor
@Observable
final class HomeStore {
    func send(_ action: Action) async {
        // async work possible, UI updates are safe
    }
}

// ViewController: async calls via Task
override func viewDidLoad() {
    super.viewDidLoad()
    Task {
        await store.send(.refresh)
    }
}

// FSCalendar delegate: nonisolated + Task
nonisolated func calendar(_ calendar: FSCalendar, didSelect date: Date, ...) {
    Task { @MainActor in
        await store.send(.selectDate(date))
    }
}
```

---

## 8. Build & Run

```bash
# Install Tuist
mise install tuist

# Install dependencies
tuist install

# Generate project
tuist generate

# Build
tuist build

# Test
tuist test

# Open Xcode
open DrinkSomeWater.xcworkspace
```

---

## 9. HealthKit Integration

### 9.1 Overview

```
┌─────────────────────────────────────────────────────┐
│                     iPhone                           │
│  ┌─────────────┐      ┌─────────────┐               │
│  │  Gulp app   │ ←──→ │  HealthKit  │               │
│  │             │      │ (Health app)│               │
│  │ • Water log │      │             │               │
│  │ • Goal set  │      │ • Weight    │               │
│  │ • Reminders │      │ • Water     │               │
│  └─────────────┘      └─────────────┘               │
│         │                    │                      │
│         └────────────────────┘                      │
│              UserDefaults                           │
│           (profile, settings storage)               │
└─────────────────────────────────────────────────────┘
```

### 9.2 HealthKit Data Types

| Type | Identifier | Usage |
|------|------------|-------|
| Body weight | `HKQuantityTypeIdentifier.bodyMass` | Read - recommended intake calculation |
| Water intake | `HKQuantityTypeIdentifier.dietaryWater` | Read/Write - sync |

### 9.3 Permission Flow

```
First launch or profile settings entry
         │
         ▼
Request HealthKit permission
(read weight, read/write water intake)
         │
         ├── Granted → Load weight from HealthKit → Calculate recommended intake
         │
         └── Denied → Manual entry via UserDefaults fallback
```

### 9.4 Recommended Intake Calculation

```swift
// Weight-based recommended intake
let recommendedIntake = weight (kg) × 33 (ml)

// Example: 70kg → 2,310ml
```

### 9.5 Required Configuration

**Entitlements** (`DrinkSomeWater.entitlements`)
```xml
<key>com.apple.developer.healthkit</key>
<true/>
```

**Info.plist**
```xml
<key>NSHealthShareUsageDescription</key>
<string>Reads weight to calculate your personalized recommended intake.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>Syncs water intake records with the Health app.</string>
```

---

## 10. Notification System

### 10.1 Random Message Pool (Localized)

```swift
enum NotificationMessages {
    // Localized notification messages (Korean/English)
    static let messages: [String] = [
        String(localized: "notification.message.1"),  // Time to drink water!
        String(localized: "notification.message.2"),  // Don't forget to hydrate~
        String(localized: "notification.message.3"),  // Start your healthy day with a glass of water!
        String(localized: "notification.message.4"),  // Drink before you feel thirsty
        String(localized: "notification.message.5"),  // Gulp away today too!
        String(localized: "notification.message.6"),  // A glass of water washes away fatigue
        String(localized: "notification.message.7"),  // The secret to glowing skin: water!
        String(localized: "notification.message.8"),  // Boost your focus with a glass of water!
        String(localized: "notification.message.9"),  // Hold on! Drink some water first
        String(localized: "notification.message.10")  // Your body is waiting for water
    ]

    static var random: String {
        messages.randomElement() ?? messages[0]
    }
}
```

### 10.2 Scheduling Strategy

**Constraint**: iOS repeating notifications (`repeats: true`) repeat the same message

**Solution**: Schedule multiple non-repeating notifications (each with a random message)

```
┌──────────────────────────────────────────────────┐
│  Old approach (❌)                               │
│  1 repeating notification → same message forever │
├──────────────────────────────────────────────────┤
│  New approach (✅)                               │
│  Schedule 64 non-repeating notifications (iOS limit) │
│  Assign random message to each notification      │
│  Refill notifications on app launch              │
└──────────────────────────────────────────────────┘
```

### 10.3 Notification Flow

```
App launch / settings change
         │
         ▼
Cancel existing scheduled notifications
         │
         ▼
Schedule up to 64 notifications based on settings
(assign random message to each)
         │
         ▼
Display assigned message when notification fires
```

---

## 11. Profile & Personalization

### 11.1 Profile Setting Screen

```
┌────────────────────────────────────────┐
│   Profile Settings                     │
│                                        │
│   ─────────── Apple Health ──────────  │
│   │ 🍎 Health app connected   [ON] │   │
│                                        │
│   ─────────── Weight ─────────         │
│   │ ⚖️ Current weight          70kg│   │
│   │ (auto-synced from Health app)    │  │
│                                        │
│   ─────────── Recommendation ────────  │
│   │ 💡 Daily recommended     2,310ml│  │
│   │ (based on weight × 33ml)         │  │
│                                        │
│   ┌────────────────────────────────┐   │
│   │  Set this as my daily goal     │   │
│   └────────────────────────────────┘   │
│                                        │
└────────────────────────────────────────┘
```

### 11.2 Data Priority

```
Weight data priority:
1. HealthKit weight (auto-sync)
2. UserDefaults manual entry (fallback)

Goal:
- User-set directly (existing value kept)
- Quick-apply with recommended intake button
```

### 11.3 ProfileStore

```swift
@MainActor
@Observable
final class ProfileStore {
    enum Action {
        case load
        case requestHealthKitPermission
        case syncWeightFromHealthKit
        case updateWeight(Double)
        case toggleHealthKitWeight(Bool)
        case applyRecommendedGoal
    }

    var profile: UserProfile = .default
    var isHealthKitAvailable: Bool = false
    var isHealthKitAuthorized: Bool = false

    var recommendedIntake: Int {     // ml
        profile.recommendedIntake    // weight * 33
    }

    func send(_ action: Action) async { ... }
}
```

---

## 12. Advertising (AdMob)

### 12.1 Overview

```
┌─────────────────────────────────────────────────────┐
│                   Ad Strategy                        │
├─────────────────────────────────────────────────────┤
│  • Free app + ad revenue model                      │
│  • Non-intrusive ads that don't hurt user experience │
│  • Google AdMob SDK                                 │
└─────────────────────────────────────────────────────┘
```

### 12.2 Ad Types & Placement (currently implemented)

| Ad Type | Location | Frequency | UX Impact | Status |
|---------|----------|-----------|-----------|--------|
| **Native Ad** | History tab list | Every 5 records | Low | ✅ Implemented |
| **Rewarded** | Settings > Support developer | User choice | None | ✅ Implemented |
| Banner | - | - | - | Not implemented |
| Interstitial | - | - | - | Not implemented |

### 12.3 Native Ad Placement (History List)

```
┌────────────────────────────────────────┐
│   📅 History          📊 12 achieved  │
│                                        │
│   ┌────────────────────────────────┐   │
│   │ 15 │ Friday    ████████░░ 80%  │   │
│   └────────────────────────────────┘   │
│   ┌────────────────────────────────┐   │
│   │ 14 │ Thursday  ██████████ 100% │   │
│   └────────────────────────────────┘   │
│   ... (3 more)                         │
│                                        │
│   ┌────────────────────────────────┐   │
│   │    🔲 Native Ad Card            │   │ ← Inserted every 5 records
│   │    Ad title / description       │   │
│   └────────────────────────────────┘   │
│                                        │
│   ┌────────────────────────────────┐   │
│   │ 10 │ Sunday    ████████░░ 75%  │   │
│   └────────────────────────────────┘   │
│                                        │
└────────────────────────────────────────┘
```

### 12.4 AdMobService

```swift
@MainActor
final class AdMobService {
    static let shared = AdMobService()

    // Native Ad preload
    func preloadNativeAds(count: Int)
    func getNativeAd() -> GADNativeAd?

    // Rewarded Ad
    func loadRewardedAd()
    var isRewardedAdReady: Bool
    func showRewardedAd(from: UIViewController, completion: (Bool) -> Void)

    // Banner (planned)
    func createBannerView(rootViewController: UIViewController) -> GADBannerView
}
```

### 12.5 Required Configuration

**Tuist/Package.swift**
```swift
.package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", from: "11.2.0")
```

**Info.plist**
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
<key>SKAdNetworkItems</key>
<array>
    <!-- SKAdNetwork IDs for AdMob -->
</array>
<key>NSUserTrackingUsageDescription</key>
<string>Used to show personalized ads.</string>
```

### 12.6 App Tracking Transparency (ATT)

Required for iOS 14.5+:
```swift
import AppTrackingTransparency

// Request permission on app start
ATTrackingManager.requestTrackingAuthorization { status in
    // Initialize ads
}
```

### 12.7 Implementation Plan

| # | Task | File |
|---|------|------|
| 1 | Add AdMob SDK dependency | `Tuist/Package.swift` |
| 2 | Create AdService | `Services/AdService.swift` (new) |
| 3 | Configure Info.plist | `Project.swift` or `Info.plist` |
| 4 | Request ATT permission | `AppDelegate.swift` or `SceneDelegate.swift` |
| 5 | Banner view component | `ViewComponent/AdBannerView.swift` (new) |
| 6 | Add Banner to HomeVC | `ViewController/Home/HomeViewController.swift` |
| 7 | Interstitial logic | `Services/AdService.swift` |
| 8 | Add record counter | `Services/UserDefaultsService.swift` |

### 12.8 Revenue Optimization Tips

- Use **test ad IDs** during development: `ca-app-pub-3940256099942544/...`
- Consider **Mediation**: AdMob + other networks (revenue optimization)
- **A/B test**: Optimize interstitial frequency
- Check **regional eCPM**: Korea vs global

### 12.9 Premium/Ad-Free Option (Future)

```
┌─────────────────────────────────────────┐
│  Future consideration: premium model    │
├─────────────────────────────────────────┤
│  • Free: with ads                       │
│  • Premium ($0.99): ads removed         │
│  • Implemented via In-App Purchase      │
└─────────────────────────────────────────┘
```

---

## 13. Widget Extension (v2.2)

### 13.1 Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Widget Architecture                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐     App Group      ┌─────────────────┐    │
│   │ Main App    │ ◄────────────────► │ Widget Extension│    │
│   │             │   UserDefaults     │                 │    │
│   │ • Water log │   (shared)         │ • Small Widget  │    │
│   │ • Settings  │                    │ • Medium Widget │    │
│   └─────────────┘                    │ • Lock Screen   │    │
│         │                            └─────────────────┘    │
│         │ WidgetCenter.reloadAllTimelines()                 │
│         └──────────────────────────────────────────────────►│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 13.2 App Group Configuration

```
App Group ID: group.com.onceagain.DrinkSomeWater
```

**Entitlements** (main app + widget extension)
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.onceagain.DrinkSomeWater</string>
</array>
```

### 13.3 Widget Types

| Widget | Family | Description |
|--------|--------|-------------|
| **Small** | `systemSmall` | Circular progress + percentage + intake |
| **Medium** | `systemMedium` | Progress + interactive buttons (+150ml, +300ml) |
| **Large** | `systemLarge` | Large progress + motivational message + buttons (150/300/500ml) |
| **Lock Circular** | `accessoryCircular` | Circular progress gauge |
| **Lock Rectangular** | `accessoryRectangular` | Water intake/goal text |
| **Lock Inline** | `accessoryInline` | Text format (intake/goal) |

### 13.4 Small Widget Design

```
┌─────────────────┐
│    💧 1,200     │
│    ─────────    │
│     2,000ml     │
│      60%        │
└─────────────────┘
```

### 13.5 Medium Widget Design (Interactive)

```
┌──────────────────────────────────┐
│  💧 Today's Water                 │
│  1,200 / 2,000ml     [+150] [+300]│
│  ████████████░░░░░░░░  60%       │
└──────────────────────────────────┘
```

- **[+150], [+300]**: Tap to add water via AppIntent

### 13.6 Large Widget Design (Interactive)

```
┌──────────────────────────────────────────┐
│  💧 Hydration Tracker                     │
│                                          │
│    ┌────────────┐    Current: 1,200ml    │
│    │   60%     │    ─────────────        │
│    │  ◯◯◯◯    │    Goal: 2,000ml        │
│    └────────────┘                        │
│                                          │
│       "Almost there, keep going!"        │ ← Motivational message
│                                          │
│  ┌────────┐ ┌────────┐ ┌────────┐        │
│  │  +150  │ │  +300  │ │  +500  │        │ ← Interactive buttons
│  └────────┘ └────────┘ └────────┘        │
└──────────────────────────────────────────┘
```

### 13.7 Lock Screen Widget Design

```
Circular:        Rectangular:
  ┌───┐          ┌─────────────┐
  │60%│          │💧 1,200ml   │
  │ 💧│          │   / 2,000   │
  └───┘          └─────────────┘
```

### 13.7 Widget Data Flow

```
Water added in main app
        │
        ▼
WaterService.updateWater()
        │
        ├── Save to UserDefaults (standard)
        │
        ├── Save to App Group UserDefaults
        │
        └── WidgetCenter.shared.reloadAllTimelines()
                │
                ▼
        Widget Timeline Provider called
                │
                ▼
        Widget UI updated
```

### 13.8 Interactive Widget (AppIntent)

```swift
struct AddWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Water"
    
    @Parameter(title: "Amount")
    var amount: Int
    
    init() {
        self.amount = 150
    }
    
    init(amount: Int) {
        self.amount = amount
    }
    
    func perform() async throws -> some IntentResult {
        // Add water to App Group UserDefaults
        let manager = WidgetDataManager.shared
        await manager.addWater(amount)
        
        // Reload widget timeline
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}
```

### 13.10 File Structure

```
DrinkSomeWaterWidget/
├── DrinkSomeWaterWidget.swift          # Widget Entry Point + Bundle
├── WaterEntry.swift                     # Timeline Entry
├── WaterProvider.swift                  # Timeline Provider
├── Views/
│   ├── SmallWidgetView.swift           # 2x2 widget (circular progress)
│   ├── MediumWidgetView.swift          # 4x2 widget + buttons (150/300ml)
│   ├── LargeWidgetView.swift           # 4x4 widget + motivational + buttons (150/300/500ml)
│   └── LockScreenWidgetView.swift      # Lock screen widget (Circular/Rectangular/Inline)
└── Intents/
    └── AddWaterIntent.swift            # AppIntent

Shared/
└── WidgetDataManager.swift             # Shared between main app + widget (App Group)
```

---

## 14. Onboarding (v2.2)

### 14.1 Overview

A 5-page swipe onboarding that guides users through the app on first launch.

```
[Page 1]        [Page 2]        [Page 3]        [Page 4]        [Page 5]
App Intro    →  Goal Setting →  HealthKit   →  Notifications →  Widget Guide
                                Integration
  
 💧 Gulp         🎯 Slider       🍎 Permission   🔔 Permission   📱 Setup Guide
  Intro          1500~4500ml      (optional)      (optional)
                                                            [Get Started] button
```

### 14.2 Page Details

| Page | Title | Content | Action |
|------|-------|---------|--------|
| 1 | App Intro | Importance of hydration, app feature overview | None (swipe) |
| 2 | Goal Setting | Set daily goal with slider (1,500–4,500ml) | Save goal |
| 3 | HealthKit | Apple Health integration guide | Permission request button |
| 4 | Notifications | Water reminder notification guide | Permission request button |
| 5 | Widget Guide | How to add home screen widget | [Get Started] button |

### 14.3 Flow Logic

```
App launch (SceneDelegate)
        │
        ▼
Check UserDefaults.onboardingCompleted
        │
        ├── false → Show OnboardingViewController
        │              │
        │              ▼
        │           Swipe pages or tap [Skip]
        │              │
        │              ▼
        │           Tap [Get Started] → onboardingCompleted = true
        │              │
        │              └──────────────────┐
        │                                 │
        └── true ─────────────────────────┤
                                          │
                                          ▼
                                    MainTabBarController
```

### 14.4 OnboardingStore

```swift
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
    
    var currentPage: Int = 0
    var goal: Int = 2000
    var isHealthKitAuthorized: Bool = false
    var isNotificationAuthorized: Bool = false
    
    func send(_ action: Action) async { ... }
}
```

### 14.5 Skip Behavior

- [Skip] button shown in the top-right on every page
- On skip, defaults are applied:
  - Goal: 2,000ml (default)
  - HealthKit: not connected
  - Notifications: default settings or off
- `onboardingCompleted = true` saved, then navigates to main screen

### 14.6 Widget Guide (Settings Access)

The widget guide is also accessible from the settings screen outside of onboarding:

```
Settings > Help > Widget Setup Guide
```

---

## 15. Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.3.x | 2025-01 | SwiftUI migration (Home/History), Large widget, Native Ad, water subtraction/reset, localization |
| 2.2.0 | 2025-01 | Home/Lock screen widgets, interactive widget, onboarding flow |
| 2.1.0 | 2025-01 | HealthKit integration, weight-based recommendations, random notification messages |
| 2.0.x | 2025-01 | 3-tab structure refactor, @Observable migration |
| 1.x | 2021 | Initial ReactorKit + RxSwift version |
