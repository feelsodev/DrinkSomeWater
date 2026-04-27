# AGENTS.md – DrinkSomeWater (벌컥벌컥)

> Entry point (ToC/map) for AI agents to quickly understand the project structure.

---

## Quick Reference

| Item | Details |
|------|------|
| App Name | 벌컥벌컥 (Gulp) / DrinkSomeWater |
| Language | Swift 6 (iOS), Kotlin (Android) |
| UI | SwiftUI + UIKit (iOS), Jetpack Compose (Android) |
| Architecture | @Observable Store Pattern (iOS), MVI ViewModel (Android) |
| Build | Tuist (iOS), Gradle KTS (Android) |
| Minimum Support | iOS 18+, watchOS 11+ |
| Key Permissions | HealthKit, UserNotifications, iCloud |

---

## Directory Map

```
DrinkSomeWater/
├── ios/                    # iOS/watchOS app
│   ├── DrinkSomeWater/     # Main app target
│   ├── DrinkSomeWaterWidget/ # Widget extension
│   ├── DrinkSomeWaterWatch/  # watchOS app
│   ├── Analytics/          # Analytics framework
│   ├── Shared/             # Shared helpers for widget/app
│   ├── DrinkSomeWaterTests/
│   ├── DrinkSomeWaterSnapshotTests/
│   └── docs/               # iOS-specific documentation
├── android/                # Android/Wear OS app
│   ├── app/                # Main phone app
│   ├── core/               # Shared domain/data layer
│   ├── widget/             # Home screen widget
│   ├── wear/               # Wear OS app
│   ├── analytics/          # Analytics module
│   └── docs/               # Android-specific documentation
├── docs/                   # Detailed knowledge repository
│   ├── references/         # External references
│   ├── design-docs/        # Design documents (planned)
│   ├── product-specs/      # Acceptance criteria (planned)
│   └── exec-plans/         # Execution plans (planned)
├── .github/workflows/      # CI/CD
├── AGENTS.md               # ← This file
├── ARCHITECTURE.md
├── QUALITY_SCORE.md
├── SECURITY.md
└── README.md
```

---

## Key Documents

| Document | Path | Description |
|------|------|------|
| Top-level Structure | `ARCHITECTURE.md` | Overall architecture overview |
| Quality Rubric | `QUALITY_SCORE.md` | Code quality standards |
| Security Rules | `SECURITY.md` | Security policies and rules |
| Analytics Events | `docs/ANALYTICS.md` | Firebase Analytics event definitions |
| App Store Setup | `docs/APP_STORE_CONNECT_SETUP.md` | App Store Connect setup guide |
| iOS Detailed Docs | `ios/docs/IOS_PROJECT_DOCUMENTATION.md` | Full iOS project documentation |
| iOS Tech Spec | `ios/docs/TECH_SPEC.md` | iOS technical specification |
| Migration Log | `ios/docs/MIGRATION_LOG.md` | iOS migration history |
| Android Overview | `android/README.md` | Android project overview |
| Android Project Plan | `android/docs/ANDROID_PROJECT_PLAN.md` | Android development plan |
| Android TDD Guide | `android/docs/ANDROID_TDD_GUIDE.md` | Android test-driven development guide |
| iOS-Android Mapping | `android/docs/IOS_ANDROID_MAPPING.md` | iOS/Android feature parity table |
| Play Store Listing | `android/docs/PLAY_STORE_LISTING.md` | Play Store listing information |
| Release Guide | `android/docs/RELEASE_GUIDE.md` | Android release procedures |

---

## Conventions Summary

- **Naming**: Follows Swift API Design Guidelines
- **Branches**: `feature/*`, `fix/*`, `docs/*`
- **Commits**: Conventional Commits format
- **iOS Build**: `tuist install && tuist generate`
- **Android Build**: `./gradlew build`

---

*This file is the agent entry point. See the linked documents for detailed design.*
