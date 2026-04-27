# ARCHITECTURE.md – DrinkSomeWater (벌컥벌컥)

> Top-level structure overview. See each platform's docs/ for detailed design.

---

## System Overview

DrinkSomeWater (벌컥벌컥) is a cross-platform app that tracks daily water intake, syncs with HealthKit, and encourages hydration through periodic reminders.

**Supported Platforms:** iOS, watchOS, Android, Wear OS

### Core Domains

| Domain | Description |
|--------|------|
| Water Tracking | Intake record CRUD, daily goals, hydration efficiency by drink type |
| HealthKit / Health Connect | Health data synchronization |
| Reminders | Smart notifications (10 motivational messages) |
| Widget | Home screen widgets (Small / Medium / Large / Lock Screen) |
| Watch | Apple Watch / Wear OS app, complications |
| Statistics | 7-day / 30-day stats, streak tracking |
| Cloud Sync | iCloud synchronization |
| Premium | Subscriptions / ad removal (StoreKit 2) |

---

## iOS Architecture

### Pattern: @Observable Store Pattern

Adopts a unidirectional data flow inspired by ReactorKit. Each screen has its own independent Store. Views observe the Store's state and only dispatch Actions.

```swift
@MainActor @Observable
final class HomeStore {
    enum Action { case addWater(Int), refresh }
    var ml: Float = 0
    func send(_ action: Action) async { /* ... */ }
}
```

### Layer Structure

```
┌─────────────────────────────────────────┐
│  Presentation                           │
│  SwiftUI Views + UIKit ViewControllers  │
├─────────────────────────────────────────┤
│  Store                                  │
│  @Observable Store (Action → state)     │
├─────────────────────────────────────────┤
│  Service                                │
│  Business logic (ServiceProvider)       │
├─────────────────────────────────────────┤
│  Data                                   │
│  UserDefaults / HealthKit / iCloud      │
│  WidgetKit                              │
└─────────────────────────────────────────┘
```

### Module Structure

| Module | Role |
|------|------|
| `DrinkSomeWater/` | Main app (Models, Services, Stores, Views, ViewControllers, ViewComponents, DesignSystem) |
| `DrinkSomeWaterWidget/` | Widget extension |
| `DrinkSomeWaterWatch/` | watchOS app |
| `Analytics/` | Analytics framework |
| `Shared/` | WidgetDataManager (shared helper for app / widget) |

---

## Android Architecture

### Pattern: MVI-style ViewModel + StateFlow

Each screen's ViewModel exposes a single UI state via StateFlow, and the screen passes events to the ViewModel.

### Multi-Module Structure

| Module | Role |
|------|------|
| `app` | UI (Home / History / Settings / Onboarding), services (notifications, ads, health), DI |
| `core` | Domain models, Repository interfaces, DataStore implementations |
| `widget` | Glance widget (UI / Data / Action) |
| `wear` | Wear OS (UI / Tile / Complication / Sync / Data / DI) |
| `analytics` | Analytics abstraction layer |

---

## Data Flow

### iOS

```
User Action → SwiftUI View → Store.send(action) → ServiceProvider → Persistence
                                    │
                                    ├── HealthKit sync
                                    ├── iCloud sync
                                    ├── WidgetCenter.reloadAllTimelines()
                                    └── WatchConnectivity sync
```

### Android

```
User Event → Screen → ViewModel.onEvent() → Repository → DataStore
                                    │
                                    ├── Health Connect
                                    └── Wear DataLayer
```

---

## Key Dependencies

### iOS

| Type | Details |
|------|------|
| UI | SwiftUI + UIKit |
| Health | HealthKit |
| Widget | WidgetKit |
| Watch | WatchConnectivity |
| In-App Purchase | StoreKit 2 |
| Cloud | iCloud (NSUbiquitousKeyValueStore) |
| Analytics | Firebase Analytics |
| Ads | Google AdMob |
| Build | Tuist |

### Android

| Type | Details |
|------|------|
| UI | Jetpack Compose |
| Health | Health Connect |
| Widget | Glance |
| Watch | Wear Compose |
| DI | Hilt |
| Async | Coroutines + Flow |
| Storage | DataStore |
| Background Work | WorkManager |
| Analytics | Firebase Analytics |
| Ads | Google AdMob |
| Build | Gradle KTS + Version Catalog |

---

## Build & Targets

| Platform | Target / Module | Minimum Version |
|--------|------------|----------|
| iOS | DrinkSomeWater | iOS 18+ |
| iOS | DrinkSomeWaterWidget | iOS 18+ |
| iOS | DrinkSomeWaterWatch | watchOS 11+ |
| iOS | Analytics | iOS 18+ |
| iOS | DrinkSomeWaterTests | iOS 18+ |
| iOS | DrinkSomeWaterSnapshotTests | iOS 18+ |
| Android | app | Android 8.0+ |
| Android | core | Android 8.0+ |
| Android | widget | Android 8.0+ |
| Android | wear | Wear OS 2+ |
| Android | analytics | Android 8.0+ |

---

## Cross-Platform Sharing

No shared code. iOS and Android are implemented independently.

- Feature parity table → `android/docs/IOS_ANDROID_MAPPING.md`
- Analytics event definitions → `docs/ANALYTICS.md`

---

*See ios/docs/ and android/docs/ for detailed design documents.*
