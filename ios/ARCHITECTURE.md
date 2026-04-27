# ARCHITECTURE.md – 벌컥벌컥 (Gulp) iOS

> iOS/watchOS architecture details. For the full system overview, see the root ARCHITECTURE.md.

---

## Architecture Pattern

Uses the @Observable Store Pattern (ReactorKit-inspired, unidirectional data flow).

Data flows in one direction only: **View → Store.send(action) → Service → Data**

Stores are declared as `@MainActor @Observable`, and accept input via an `Action` enum.

```swift
@MainActor @Observable
final class HomeStore {
    enum Action { case addWater(Int), refresh }
    var ml: Float = 0
    var total: Float = 0
    var progress: Float { total == 0 ? 0 : ml / total }
    func send(_ action: Action) async { /* ... */ }
}
```

---

## Layer Diagram

```
┌─────────────────────────────────────────────┐
│  Presentation                               │
│  SwiftUI Views + UIKit ViewControllers      │
├─────────────────────────────────────────────┤
│  Store (@Observable)                        │
│  Action → State mutation                    │
├─────────────────────────────────────────────┤
│  Service (ServiceProvider)                  │
│  Business logic, external integrations      │
├─────────────────────────────────────────────┤
│  Data                                       │
│  UserDefaults · HealthKit · iCloud · Widget │
└─────────────────────────────────────────────┘
```

---

## App Entry Flow

```
main.swift → AppDelegate → SceneDelegate
                               │
                     ┌─────────┴──────────┐
                     │ Onboarding incomplete│ Onboarding complete
                     ▼                    ▼
             OnboardingVC         IntroViewController
                                         │
                                         ▼
                                    MainTabView
                                  ┌────┼────┐
                                 Home History Settings
```

---

## Key Stores

| Store | Responsibility |
|-------|---------------|
| HomeStore | Today's intake, quick buttons, add/remove water |
| HistoryStore | Record lookup, calendar/list/timeline views |
| SettingsStore | Goal, notifications, profile |
| StatisticsStore | 7-day/30-day stats, streaks |
| InformationStore | App info |

---

## Key Services

| Service | Responsibility |
|---------|---------------|
| WaterStorageService | Water intake CRUD (UserDefaults) |
| HealthKitService | Apple Health integration |
| CloudSyncService | iCloud sync |
| NotificationService | Smart notifications |
| WatchConnectivityService | Apple Watch sync |
| StoreKitService | Subscriptions/IAP (StoreKit 2) |
| AdService | Google AdMob |
| InstagramSharingService | Social sharing |
| AppUpdateChecker | App update check |

---

## Widget Architecture

- Based on WidgetKit + AppIntent (Interactive)
- App and widget share data via `WidgetDataManager` in the `Shared/` module
- Timeline updates driven by `TimelineProvider`

---

## watchOS Architecture

- iPhone and Watch data sync via WatchConnectivity
- Independent UI (SwiftUI)

---

## Dependencies

| Category | Items |
|----------|-------|
| Apple | SwiftUI, UIKit, HealthKit, WidgetKit, WatchConnectivity, StoreKit 2, iCloud |
| Firebase | Analytics, Crashlytics, RemoteConfig |
| Google | AdMob |
| UI | SnapKit, FSCalendar |
| Test | SnapshotTesting |

---

*For detailed technical specs, see docs/TECH_SPEC.md.*
