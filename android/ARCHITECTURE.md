# ARCHITECTURE.md – 벌컥벌컥 Android

> Android/Wear OS 아키텍처 상세. 전체 시스템은 루트 ARCHITECTURE.md 를 참조.

---

## 아키텍처 패턴 — MVI

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

## 멀티 모듈 구조

```
app ──┐
widget ├──▶ core
wear ──┘
```

- **core**: 도메인 모델, Repository 인터페이스, DataStore 구현체
- **app**: UI 스크린, 서비스, DI
- **widget**: Glance 위젯
- **wear**: Wear OS 앱, 타일, 컴플리케이션
- **analytics**: 독립적인 분석 추상화 레이어

---

## 앱 진입 흐름

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

## 데이터 흐름

```
User Event → Screen → ViewModel.onEvent() → Repository → DataStore
                                    │
                                    ├── Health Connect
                                    └── Wear DataLayer
```

---

## 주요 의존성

| 그룹 | 라이브러리 |
|------|-----------|
| Jetpack | Compose, Navigation, Lifecycle, DataStore, WorkManager, Hilt |
| Google | Health Connect, Play Services Wearable, AdMob |
| Firebase | Analytics |
| Wear | Compose, Tiles, Complications |
| Test | JUnit5, MockK, Turbine |

---

## 위젯 (Glance)

- Glance API 기반 위젯 렌더링
- `GlanceAppWidget` + `GlanceAppWidgetReceiver` 조합
- `ActionCallback`으로 사용자 인터랙션 처리

---

## Wear OS

- `WearMainActivity` → Navigation
- `WaterTileService`, `WaterComplicationService`
- `WearDataListenerService` (폰 ↔ 워치 동기화)

---

*상세 계획은 docs/ANDROID_PROJECT_PLAN.md 를 참조하세요.*
