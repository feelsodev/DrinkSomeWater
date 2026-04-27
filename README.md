# 벌컥벌컥 (Gulp)

> 💧 A simple water intake tracker for iOS & watchOS

<p align="center">
  <img src="https://user-images.githubusercontent.com/59601439/115199996-bd370800-a12e-11eb-8f70-bc1ab0a0c97d.PNG" width="600">
</p>

<p align="center">
  <a href="https://apps.apple.com/kr/app/%EB%B2%8C%EC%BB%A5%EB%B2%8C%EC%BB%A5/id1563673158">
    <img src="https://user-images.githubusercontent.com/59601439/120217924-fefdb700-c273-11eb-9425-63860bf2c9a3.png" height="50">
  </a>
</p>

<p align="center">
  <img alt="Version" src="https://img.shields.io/badge/Version-26.2.0-purple.svg">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6-orange.svg">
  <img alt="iOS" src="https://img.shields.io/badge/iOS-18%2B-blue">
  <img alt="watchOS" src="https://img.shields.io/badge/watchOS-11%2B-red">
  <img alt="Architecture" src="https://img.shields.io/badge/Architecture-Observable%20Store-green">
</p>

---

## Features

| 💧 Today | 📅 History | ⚙️ Settings |
|--------|--------|--------|
| Log water with quick buttons | Calendar/List/Timeline view | Set daily goal |
| Wave animation progress | Highlight achievement days | Customize quick buttons |
| Quick goal adjustment | Monthly achievement stats | Notification settings |
| Log by drink type | 7-day/30-day analytics | Profile management |

### Additional Features

- **Apple Watch** - Log directly from your wrist, complication support
- **Home Screen Widget** - Small/Medium/Large/Lock Screen widgets
- **Apple Health** - Weight sync, water intake record synchronization
- **Smart Notifications** - 10 random motivational messages
- **iCloud Sync** - Automatic data sync across devices
- **Statistics** - 7-day/30-day intake stats and charts
- **Streak Tracking** - Track consecutive achievement days and personal records
- **Drink Types** - Calculate hydration efficiency for water, coffee, tea, juice, and more
- **Social Sharing** - Share to Instagram Stories/Feed and system share sheet

### Premium Features

- **Ad Removal** - Remove all banner, native, and rewarded ads
- **Subscription Options** - Monthly/annual subscription or lifetime access

---

## Tech Stack

| Category | Technology |
|----------|------------|
| UI | SwiftUI + UIKit |
| Architecture | @Observable Store Pattern |
| Concurrency | Swift 6, async/await |
| Widget | WidgetKit + AppIntent |
| Watch | WatchConnectivity |
| Health | HealthKit |
| Cloud | iCloud (NSUbiquitousKeyValueStore) |
| IAP | StoreKit 2 |
| Analytics | Firebase Analytics |
| Ads | Google AdMob |
| Build | Tuist |

---

## Getting Started

```bash
# Install Tuist
mise install tuist

# Setup & Run
tuist install && tuist generate

# Build & Test
tuist build
tuist test
```

---

## Architecture

**@Observable Store Pattern** - Unidirectional data flow inspired by ReactorKit

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

```
┌─────────────────────────────────────────┐
│              iOS App                    │
│   ┌─────────┬─────────┬─────────┐       │
│   │  Today  │ History │Settings │       │
│   └─────────┴─────────┴─────────┘       │
│              WatchConnectivity          │
├─────────────────────────────────────────┤
│            watchOS App                  │
│   ┌─────────────────────────────┐       │
│   │  Home + Quick Add + Complication │  │
│   └─────────────────────────────┘       │
└─────────────────────────────────────────┘
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [Analytics Events](./docs/ANALYTICS.md) | Firebase Analytics event definitions |

---

## License

MIT License - [LICENSE](./LICENSE)
