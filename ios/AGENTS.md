# AGENTS.md – 벌컥벌컥 (Gulp) iOS

> iOS/watchOS platform agent entry point (ToC/map).

---

## Quick Reference

| Item | Details |
|------|---------|
| App Name | 벌컥벌컥 (Gulp) |
| Language | Swift 6 |
| UI | SwiftUI + UIKit |
| Architecture | @Observable Store Pattern (ReactorKit-inspired) |
| Build | Tuist (`tuist install && tuist generate`) |
| Minimum Support | iOS 18+, watchOS 11+ |
| Key Permissions | HealthKit, UserNotifications, iCloud |
| External Dependencies | Firebase Analytics, Google AdMob, SnapKit, FSCalendar |

---

## Directory Map

```
ios/
├── DrinkSomeWater/          # Main app target
│   ├── Sources/
│   │   ├── Models/          # Data models
│   │   ├── Services/        # Business services
│   │   ├── Stores/          # @Observable Store
│   │   ├── Views/           # SwiftUI views
│   │   ├── ViewController/  # UIKit view controllers
│   │   ├── ViewComponent/   # Reusable UI components
│   │   ├── DesignSystem/    # Design tokens
│   │   └── StaticComponent/ # Static data
│   ├── Resources/           # Assets, Localizable
│   └── Support/             # Info.plist, Entitlements
├── DrinkSomeWaterWidget/    # Widget extension
├── DrinkSomeWaterWatch/     # watchOS app
├── Analytics/               # Analytics framework
├── Shared/                  # WidgetDataManager
├── DrinkSomeWaterTests/     # Unit tests
├── DrinkSomeWaterSnapshotTests/ # Snapshot tests
├── docs/                    # iOS-specific docs
├── Project.swift            # Tuist project definition
└── .swiftlint.yml           # SwiftLint config
```

---

## Key Documents

| Document | Path | Description |
|----------|------|-------------|
| iOS Architecture | `ios/ARCHITECTURE.md` | iOS architecture details |
| Quality Rubric | `ios/QUALITY_SCORE.md` | iOS quality rubric |
| Security Rules | `ios/SECURITY.md` | iOS security rules |
| Project Details | `ios/docs/IOS_PROJECT_DOCUMENTATION.md` | Detailed project documentation |
| Tech Spec | `ios/docs/TECH_SPEC.md` | Technical specification |
| Migration Log | `ios/docs/MIGRATION_LOG.md` | Migration history |
| UI Catalog | `ios/UI_CATALOG.md` | UI catalog |

---

## Conventions

- **Naming**: Swift API Design Guidelines
- **Build**: `tuist install && tuist generate`
- **Test**: `tuist test`
- **Lint**: SwiftLint (`.swiftlint.yml`)

---

*For detailed design, see the docs/ subdirectory.*
