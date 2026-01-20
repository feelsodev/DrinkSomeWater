# 벌컥벌컥 Android

> 💧 물 섭취 기록 Android & Wear OS 앱

<p align="center">
  <img alt="Kotlin" src="https://img.shields.io/badge/Kotlin-2.0-purple.svg">
  <img alt="Android" src="https://img.shields.io/badge/Android-10%2B-green">
  <img alt="Wear OS" src="https://img.shields.io/badge/Wear%20OS-3%2B-blue">
  <img alt="Architecture" src="https://img.shields.io/badge/Architecture-MVI-orange">
</p>

---

> ⚠️ **현재 상태: 문서 단계 (Pre-Scaffolding)**
> 
> 이 폴더에는 현재 **문서만** 있습니다. 실제 Android 프로젝트(Gradle, 소스 코드)는 아직 생성되지 않았습니다.
> 
> - ✅ 완료: 프로젝트 계획서, TDD 가이드, iOS-Android 매핑 문서
> - ⏳ 다음 단계: Phase 1 - 프로젝트 스캐폴딩 (Gradle 초기화, 모듈 생성)
> 
> 빌드 명령어(`./gradlew build`)는 Phase 1 완료 후 사용 가능합니다.

---

## 📱 주요 기능

### 💧 오늘 탭
- 퀵버튼으로 간편하게 물 섭취량 기록
- 물 추가/빼기 모드 전환
- 물결 애니메이션으로 진행도 시각화
- 목표량 퀵설정

### 📅 기록 탭
- **캘린더 모드**: 월별 달성 현황
- **리스트 모드**: 최신순 기록 목록
- **타임라인 모드**: 월별 그룹화된 타임라인

### ⚙️ 설정 탭
- 일일 목표량 설정 (1,000ml ~ 4,500ml)
- 퀵버튼 커스터마이징
- 알림 설정
- Health Connect 연동

### 📱 홈 화면 위젯
- Small 위젯: 원형 진행도
- Medium 위젯: 진행도 + 버튼 2개
- Large 위젯: 진행도 + 버튼 3개

### ⌚ Wear OS 앱
- 손목에서 바로 물 기록
- 퀵 추가 버튼 (150/250/300/500ml)
- 타일 & 컴플리케이션

---

## 🛠 기술 스택

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

## 📁 프로젝트 구조

```
android/
├── core/             # 🆕 공유 모듈 (domain/data/util)
├── app/              # 메인 앱 모듈 (Phone UI)
├── widget/           # Glance 위젯 모듈
├── wear/             # Wear OS 모듈
├── analytics/        # Analytics 모듈
├── docs/             # 문서
├── gradle/           # Gradle 설정
└── build.gradle.kts  # Root build script
```

### 모듈 의존성

- `app`, `widget`, `wear` → `:core` (모델, Repository, DataStore 공유)
- `analytics` → 독립 모듈 (어디서든 사용 가능)

```
app ──┐
widget ├──▶ core
wear ──┘
```

> 📖 자세한 구조는 [프로젝트 계획서](./docs/ANDROID_PROJECT_PLAN.md)를 참고하세요.

---

## 🚀 빌드 방법

### 요구사항

- Android Studio Ladybug (2024.2.1) 이상
- JDK 17
- Android SDK 29+ (minSdk)
- Android SDK 35 (targetSdk)

### 빌드

```bash
# 프로젝트 루트로 이동
cd DrinkSomeWater/android

# 빌드
./gradlew build

# 테스트
./gradlew test

# 앱 설치 (디바이스 연결 필요)
./gradlew :app:installDebug

# Wear OS 앱 설치
./gradlew :wear:installDebug
```

### 위젯 테스트

```bash
# 위젯 모듈 빌드
./gradlew :widget:build

# 앱 설치 후 홈 화면에서 위젯 추가
```

---

## 🧪 테스트

### TDD 개발 방식

이 프로젝트는 TDD(Test-Driven Development) 방식으로 개발됩니다.

```
1. Red   - 실패하는 테스트 먼저 작성
2. Green - 테스트 통과하는 최소 코드 작성
3. Refactor - 코드 개선 (테스트 유지)
```

### 테스트 실행

```bash
# 전체 테스트
./gradlew test

# 모듈별 테스트
./gradlew :app:test
./gradlew :widget:test
./gradlew :wear:test

# 특정 테스트 클래스
./gradlew :app:test --tests "*.HomeViewModelTest"

# 커버리지 리포트
./gradlew koverHtmlReport
```

### 테스트 도구

- **JUnit 5**: 단위 테스트
- **Turbine**: Flow 테스트
- **MockK**: 모킹
- **Compose Testing**: UI 테스트

자세한 내용은 [TDD 가이드](./docs/ANDROID_TDD_GUIDE.md)를 참고하세요.

---

## 📖 문서

| 문서 | 설명 |
|------|------|
| [프로젝트 계획서](./docs/ANDROID_PROJECT_PLAN.md) | 전체 개발 계획 및 체크리스트 |
| [TDD 가이드](./docs/ANDROID_TDD_GUIDE.md) | 테스트 작성 가이드 및 명세 |
| [iOS-Android 매핑](./docs/IOS_ANDROID_MAPPING.md) | iOS 코드 참조 매핑 테이블 |

---

## 🏗 아키텍처

### MVI 패턴

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

### 예시 코드

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

## 📱 스크린샷

> TODO: 개발 완료 후 추가

---

## 📄 License

MIT License - [LICENSE](../LICENSE)

---

## 🔗 관련 링크

- [iOS 프로젝트 문서](../ios/docs/IOS_PROJECT_DOCUMENTATION.md)
- [iOS 기술 명세](../ios/docs/TECH_SPEC.md)
- [App Store (iOS)](https://apps.apple.com/kr/app/%EB%B2%8C%EC%BB%A5%EB%B2%8C%EC%BB%A5/id1563673158)
