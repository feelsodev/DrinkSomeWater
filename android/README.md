# 벌컥벌컥 (Gulp) Android

> 💧 Water intake tracker for Android & Wear OS

<p align="center">
  <img alt="Kotlin" src="https://img.shields.io/badge/Kotlin-2.0-purple.svg">
  <img alt="Android" src="https://img.shields.io/badge/Android-10%2B-green">
  <img alt="Wear OS" src="https://img.shields.io/badge/Wear%20OS-3%2B-blue">
  <img alt="Architecture" src="https://img.shields.io/badge/Architecture-MVI-orange">
</p>

---

> ⚠️ **Current Status: Documentation Phase (Pre-Scaffolding)**
> 
> This folder currently contains **documentation only**. The actual Android project (Gradle, source code) has not been created yet.
> 
> - ✅ Done: Project plan, TDD guide, iOS-Android mapping documents
> - ⏳ Next step: Phase 1 - Project scaffolding (Gradle init, module creation)
> 
> Build commands (`./gradlew build`) will be available after Phase 1 is complete.

---

## 📱 Key Features

### 💧 Today Tab
- Log water intake easily with quick buttons
- Toggle between add/subtract mode
- Wave animation to visualize progress
- Quick-set daily goal

### 📅 History Tab
- **Calendar mode**: Monthly achievement overview
- **List mode**: Chronological log entries
- **Timeline mode**: Monthly grouped timeline

### ⚙️ Settings Tab
- Set daily goal (1,000ml – 4,500ml)
- Customize quick buttons
- Notification settings
- Health Connect integration

### 📱 Home Screen Widget
- Small widget: Circular progress
- Medium widget: Progress + 2 buttons
- Large widget: Progress + 3 buttons

### ⌚ Wear OS App
- Log water directly from your wrist
- Quick-add buttons (150/250/300/500ml)
- Tiles & complications

---

## 🛠 Tech Stack

| Category | Technology |
|----------|------------|
| Language | Kotlin 2.0 |
| UI | Jetpack Compose |
| Architecture | MVI (ViewModel + StateFlow) |
| DI | Hilt |
| Async | Coroutines + Flow |
| Storage | DataStore Preferences |
| Widget | Glance API |
| Watch | Wear Compose + Data Layer |
| Health | Health Connect |
| Analytics | Firebase Analytics |
| Ads | Google AdMob |
| Testing | JUnit5, Turbine, MockK |

---

## 📁 Project Structure

```
android/
├── core/             # 🆕 Shared module (domain/data/util)
├── app/              # Main app module (Phone UI)
├── widget/           # Glance widget module
├── wear/             # Wear OS module
├── analytics/        # Analytics module
├── docs/             # Documentation
├── gradle/           # Gradle configuration
└── build.gradle.kts  # Root build script
```

### Module Dependencies

- `app`, `widget`, `wear` → `:core` (shared models, Repository, DataStore)
- `analytics` → independent module (usable anywhere)

```
app ──┐
widget ├──▶ core
wear ──┘
```

> 📖 For detailed structure, see the [Project Plan](./docs/ANDROID_PROJECT_PLAN.md).

---

## 🚀 Build Instructions

### Requirements

- Android Studio Ladybug (2024.2.1) or later
- JDK 17
- Android SDK 29+ (minSdk)
- Android SDK 35 (targetSdk)

### Build

```bash
# Navigate to project root
cd DrinkSomeWater/android

# Build
./gradlew build

# Test
./gradlew test

# Install app (device required)
./gradlew :app:installDebug

# Install Wear OS app
./gradlew :wear:installDebug
```

### Widget Testing

```bash
# Build widget module
./gradlew :widget:build

# After installing the app, add the widget from the home screen
```

---

## 🧪 Testing

### TDD Development Approach

This project is developed using TDD (Test-Driven Development).

```
1. Red   - Write a failing test first
2. Green - Write minimal code to pass the test
3. Refactor - Improve the code (keep tests passing)
```

### Running Tests

```bash
# All tests
./gradlew test

# Per-module tests
./gradlew :app:test
./gradlew :widget:test
./gradlew :wear:test

# Specific test class
./gradlew :app:test --tests "*.HomeViewModelTest"

# Coverage report
./gradlew koverHtmlReport
```

### Test Tools

- **JUnit 5**: Unit testing
- **Turbine**: Flow testing
- **MockK**: Mocking
- **Compose Testing**: UI testing

For more details, see the [TDD Guide](./docs/ANDROID_TDD_GUIDE.md).

---

## 📖 Documentation

| Document | Description |
|----------|-------------|
| [Project Plan](./docs/ANDROID_PROJECT_PLAN.md) | Full development plan and checklist |
| [TDD Guide](./docs/ANDROID_TDD_GUIDE.md) | Test writing guide and specifications |
| [iOS-Android Mapping](./docs/IOS_ANDROID_MAPPING.md) | iOS code reference mapping table |

---

## 🏗 Architecture

### MVI Pattern

```
┌─────────────────┐
│  Compose Screen │
│  collectAsState │
└────────┬────────┘
         │ UiState
         ▼
┌─────────────────┐
│   ViewModel     │
│   StateFlow     │ ◀── Event
│   onEvent()     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Repository    │
│   Interface     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   DataStore     │
│   Health Connect│
└─────────────────┘
```

### Example Code

**ViewModel:**
```kotlin
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val waterRepository: WaterRepository
) : ViewModel() {

    sealed class Event {
        data class AddWater(val amount: Int) : Event()
        data object Refresh : Event()
    }

    data class UiState(
        val currentMl: Int = 0,
        val goalMl: Int = 2000
    )

    private val _uiState = MutableStateFlow(UiState())
    val uiState: StateFlow<UiState> = _uiState.asStateFlow()

    fun onEvent(event: Event) {
        viewModelScope.launch {
            when (event) {
                is Event.AddWater -> {
                    waterRepository.addWater(event.amount)
                    refresh()
                }
                Event.Refresh -> refresh()
            }
        }
    }
}
```

**Compose Screen:**
```kotlin
@Composable
fun HomeScreen(
    viewModel: HomeViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    HomeContent(
        uiState = uiState,
        onAddWater = { viewModel.onEvent(Event.AddWater(it)) }
    )
}
```

---

## 📱 Screenshots

> TODO: Add after development is complete

---

## 📄 License

MIT License - [LICENSE](../LICENSE)

---

## 🔗 Related Links

- [iOS Project Documentation](../ios/docs/IOS_PROJECT_DOCUMENTATION.md)
- [iOS Tech Spec](../ios/docs/TECH_SPEC.md)
- [App Store (iOS)](https://apps.apple.com/kr/app/%EB%B2%8C%EC%BB%A5%EB%B2%8C%EC%BB%A5/id1563673158)
