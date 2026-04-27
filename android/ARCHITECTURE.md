# ARCHITECTURE.md – 벌컥벌컥 (Gulp) Android

> Android/Wear OS architecture detail. For the full system, see the root ARCHITECTURE.md.

---

## Architecture Pattern — MVI

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

```kotlin
@HiltViewModel
class HomeViewModel @Inject constructor(
    private val waterRepository: WaterRepository
) : ViewModel() {
    sealed class Event {
        data class AddWater(val amount: Int) : Event()
        data object Refresh : Event()
    }
    data class UiState(val currentMl: Int = 0, val goalMl: Int = 2000)
    private val _uiState = MutableStateFlow(UiState())
    val uiState = _uiState.asStateFlow()
    fun onEvent(event: Event) { viewModelScope.launch { ... } }
}
```

---

## Multi-Module Structure

```
app ──┐
widget ├──▶ core
wear ──┘
```

- **core**: Domain models, Repository interfaces, DataStore implementations
- **app**: UI screens, services, DI
- **widget**: Glance widget
- **wear**: Wear OS app, tiles, complications
- **analytics**: Independent analytics abstraction layer

---

## App Entry Flow

```
DrinkSomeWaterApp (@HiltAndroidApp)
    → MainActivity
        → AppNavigation(showOnboarding)
            ├── OnboardingScreen (conditional)
            ├── HomeScreen
            ├── HistoryScreen
            └── SettingsScreen
```

---

## Data Flow

```
User Event → Screen → ViewModel.onEvent() → Repository → DataStore
                                    │
                                    ├── Health Connect
                                    └── Wear DataLayer
```

---

## Key Dependencies

| Group | Libraries |
|-------|-----------|
| Jetpack | Compose, Navigation, Lifecycle, DataStore, WorkManager, Hilt |
| Google | Health Connect, Play Services Wearable, AdMob |
| Firebase | Analytics |
| Wear | Compose, Tiles, Complications |
| Test | JUnit5, MockK, Turbine |

---

## Widget (Glance)

- Widget rendering based on the Glance API
- `GlanceAppWidget` + `GlanceAppWidgetReceiver` combination
- User interactions handled via `ActionCallback`

---

## Wear OS

- `WearMainActivity` → Navigation
- `WaterTileService`, `WaterComplicationService`
- `WearDataListenerService` (phone ↔ watch sync)

---

*For the detailed plan, see docs/ANDROID_PROJECT_PLAN.md.*
