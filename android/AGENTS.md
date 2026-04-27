# AGENTS.md – 벌컥벌컥 (Gulp) Android

> Android/Wear OS platform agent entry point (ToC/map).

---

## Quick Reference

| Item | Details |
|------|---------|
| App Name | 벌컥벌컥 (Gulp) |
| Language | Kotlin 2.0 |
| UI | Jetpack Compose |
| Architecture | MVI (ViewModel + StateFlow) |
| DI | Hilt |
| Async | Coroutines + Flow |
| Storage | DataStore Preferences |
| Build | Gradle KTS + Version Catalog |
| Min Support | Android 10+ (API 29), Wear OS 3+ |
| Key Permissions | Health Connect, Notifications |

---

## Directory Map

```
android/
├── app/                    # Main phone app
│   └── src/main/java/.../
│       ├── ui/             # Home, History, Settings, Onboarding
│       ├── service/        # Notifications, Ads, Health
│       └── di/             # Hilt modules
├── core/                   # Shared domain/data
│   └── src/main/java/.../
│       ├── domain/         # Models, Repository interfaces
│       └── data/           # DataStore, Repository implementations
├── widget/                 # Glance widget
│   └── src/main/java/.../
│       ├── ui/             # Widget rendering
│       ├── data/           # Widget data
│       └── action/         # Widget actions
├── wear/                   # Wear OS app
│   └── src/main/java/.../
│       ├── ui/             # Wear UI
│       ├── tile/           # Tile service
│       ├── complication/   # Complications
│       ├── sync/           # Data sync
│       └── di/             # Hilt modules
├── analytics/              # Analytics module
├── docs/                   # Android-specific docs
├── gradle/libs.versions.toml # Version catalog
└── settings.gradle.kts     # Module settings
```

---

## Key Documents

| Document | Path | Description |
|----------|------|-------------|
| Android Architecture Detail | `android/ARCHITECTURE.md` | Android architecture detail |
| Android Quality Rubric | `android/QUALITY_SCORE.md` | Android quality rubric |
| Android Security Rules | `android/SECURITY.md` | Android security rules |
| Android Overview & Build | `android/README.md` | Android overview and build |
| Project Plan | `android/docs/ANDROID_PROJECT_PLAN.md` | Project plan |
| TDD Guide | `android/docs/ANDROID_TDD_GUIDE.md` | TDD guide |
| iOS-Android Mapping | `android/docs/IOS_ANDROID_MAPPING.md` | iOS-Android mapping |
| Store Listing | `android/docs/PLAY_STORE_LISTING.md` | Store listing |
| Release Guide | `android/docs/RELEASE_GUIDE.md` | Release guide |

---

## Convention Summary

- **Build**: `./gradlew build`
- **Test**: `./gradlew test`
- **Install App**: `./gradlew :app:installDebug`
- **Module Dependencies**: `app`, `widget`, `wear` → `:core`

---

*For detailed design, see the docs/ subdirectory documents.*
