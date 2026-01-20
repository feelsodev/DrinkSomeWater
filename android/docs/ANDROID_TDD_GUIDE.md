# Android TDD 구현 가이드

> 💧 벌컥벌컥 Android 프로젝트 - Test-Driven Development 가이드

---

## 메타 정보

| 항목 | 값 |
|------|-----|
| **버전** | 1.0.0 |
| **최종 업데이트** | 2026-01-20 |
| **테스트 프레임워크** | JUnit5, Turbine, MockK |

---

## 목차

1. [TDD 원칙](#1-tdd-원칙)
2. [테스트 도구](#2-테스트-도구)
3. [레이어별 테스트 전략](#3-레이어별-테스트-전략)
4. [Phase별 테스트 명세](#4-phase별-테스트-명세)
5. [테스트 유틸리티](#5-테스트-유틸리티)
6. [테스트 실행 가이드](#6-테스트-실행-가이드)

---

## 1. TDD 원칙

### 1.1 Red-Green-Refactor 사이클

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│     ┌─────────┐     ┌─────────┐     ┌─────────────┐        │
│     │   RED   │ ──▶ │  GREEN  │ ──▶ │  REFACTOR   │        │
│     │ (실패)  │     │ (통과)   │     │ (개선)      │        │
│     └─────────┘     └─────────┘     └─────────────┘        │
│          │                                   │              │
│          └───────────────────────────────────┘              │
│                       반복                                   │
└─────────────────────────────────────────────────────────────┘
```

1. **Red (빨강)**: 실패하는 테스트를 먼저 작성
2. **Green (초록)**: 테스트를 통과하는 최소한의 코드 작성
3. **Refactor (리팩토링)**: 코드 개선 (테스트는 계속 통과해야 함)

### 1.2 TDD 규칙

| 규칙 | 설명 |
|------|------|
| **테스트 먼저** | 프로덕션 코드 작성 전에 실패하는 테스트 작성 |
| **최소 코드** | 테스트 통과에 필요한 최소한의 코드만 작성 |
| **한 번에 하나** | 한 번에 하나의 테스트만 추가 |
| **리팩토링** | 테스트 통과 후 코드 정리 |
| **테스트 유지** | 리팩토링 중 테스트는 항상 통과해야 함 |

### 1.3 테스트 네이밍 컨벤션

```kotlin
// 한글 백틱 스타일 (권장)
@Test
fun `물 추가 시 현재 섭취량이 증가한다`() { }

@Test
fun `목표 달성 시 isSuccess가 true가 된다`() { }

@Test
fun `음수 양은 추가되지 않는다`() { }

// Given-When-Then 스타일 (대안)
@Test
fun givenEmptyRecord_whenAddWater100ml_thenCurrentMlIs100() { }
```

---

## 2. 테스트 도구

### 2.1 테스트 환경 분류

> ⚠️ **중요**: Android에서는 테스트 환경이 JVM과 Android 런타임으로 분리됩니다. 각 환경의 제약을 이해하고 적절한 테스트를 작성해야 합니다.

| 테스트 유형 | 위치 | 러너 | 실행 환경 | 속도 | 용도 |
|------------|------|------|----------|------|------|
| **Unit Test (JVM)** | `src/test/` | JUnit5 | JVM | 빠름 ⚡ | Domain, ViewModel, Repository |
| **Instrumented Test** | `src/androidTest/` | AndroidJUnitRunner (JUnit4) | Android Device/Emulator | 느림 🐢 | Context 필요, DataStore, Room |
| **Compose UI Test** | `src/androidTest/` | AndroidJUnitRunner | Android Device/Emulator | 느림 🐢 | UI 상호작용, 스크린샷 |

#### 테스트 환경 선택 가이드

```
테스트 대상이 Android Context 필요?
  │
  ├─ NO → JVM Unit Test (src/test/)
  │        ✅ Domain Model, ViewModel, Repository (with mocks)
  │        ✅ UseCase, Mapper, Util
  │        ✅ Flow/StateFlow 테스트 (Turbine)
  │
  └─ YES → Instrumented Test (src/androidTest/)
           ├─ UI 테스트? → Compose UI Test
           │   ✅ 화면 렌더링, 클릭, 스크롤
           │   ✅ 접근성 검증
           │   ✅ 스크린샷 테스트
           │
           └─ 비-UI 테스트?
               ✅ DataStore 실제 동작
               ✅ WorkManager
               ✅ Health Connect 권한
```

### 2.2 의존성

> **Kotlin 2.0 + Compose**: Kotlin 2.0부터 Compose 컴파일러는 `org.jetbrains.kotlin.plugin.compose` 플러그인으로 통합되었습니다. 별도의 `compose-compiler` artifact 버전을 지정하지 않습니다. 자세한 내용은 [프로젝트 계획서](./ANDROID_PROJECT_PLAN.md)의 Version Catalog 섹션을 참고하세요.

```kotlin
// build.gradle.kts (app module)
plugins {
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.compose.compiler)  // Kotlin 2.0 Compose 플러그인
}

dependencies {
    // ═══════════════════════════════════════════════════
    // JVM Unit Tests (src/test/)
    // ═══════════════════════════════════════════════════
    
    // JUnit 5 - JVM 테스트 프레임워크
    testImplementation(libs.junit5)
    
    // Turbine - Flow 테스트 (StateFlow, SharedFlow)
    testImplementation(libs.turbine)
    
    // MockK - Kotlin 모킹 라이브러리
    testImplementation(libs.mockk)
    
    // Coroutines Test - runTest, TestDispatcher
    testImplementation(libs.kotlinx.coroutines.test)
    
    // ═══════════════════════════════════════════════════
    // Instrumented Tests (src/androidTest/)
    // ═══════════════════════════════════════════════════
    
    // AndroidJUnitRunner (JUnit4 기반)
    androidTestImplementation(libs.androidx.test.runner)
    androidTestImplementation(libs.androidx.test.rules)
    
    // Compose UI Test
    androidTestImplementation(libs.androidx.compose.ui.test)
    debugImplementation(libs.androidx.compose.ui.test.manifest)
    
    // MockK Android (Instrumented에서 모킹 필요 시)
    androidTestImplementation(libs.mockk.android)
    
    // Hilt Testing (DI 테스트)
    androidTestImplementation(libs.hilt.android.testing)
    kspAndroidTest(libs.hilt.compiler)
}
```

### 2.3 JUnit5 vs JUnit4 (중요!)

| 항목 | JUnit5 (JVM) | JUnit4 (Instrumented) |
|------|-------------|----------------------|
| **사용 위치** | `src/test/` | `src/androidTest/` |
| **어노테이션** | `@Test` (jupiter) | `@Test` (junit4) |
| **Setup** | `@BeforeEach` | `@Before` |
| **Teardown** | `@AfterEach` | `@After` |
| **Nested 클래스** | `@Nested` ✅ | ❌ 미지원 |
| **DisplayName** | `@DisplayName` ✅ | ❌ 미지원 |
| **한글 메서드명** | `` `한글 테스트명`() `` ✅ | `` `한글 테스트명`() `` ✅ |

#### JUnit5 Gradle 설정 (필수!)

> ⚠️ **중요**: JUnit5를 사용하려면 `build.gradle.kts`에 `useJUnitPlatform()` 설정이 **반드시** 필요합니다.

```kotlin
// app/build.gradle.kts
android {
    // ...
}

dependencies {
    // ✅ JUnit5 통합 artifact (api + engine + params 포함)
    testImplementation(libs.junit5)
}

tasks.withType<Test> {
    useJUnitPlatform()  // ← 이 설정 없으면 JUnit5 테스트가 실행되지 않음!
}
```

#### libs.versions.toml에 필요한 항목

```toml
[versions]
junit5 = "5.10.0"

[libraries]
# ✅ 메인 경로 (권장): 통합 artifact 사용
# junit-jupiter는 api + engine + params를 모두 포함
junit5 = { group = "org.junit.jupiter", name = "junit-jupiter", version.ref = "junit5" }
```

> **참고**: `junit-jupiter` 통합 artifact를 사용하면 api/engine을 따로 지정할 필요가 없습니다. 프로젝트 계획서의 Version Catalog도 이 방식을 사용합니다.

```kotlin
// ✅ JVM Test (src/test/) - JUnit5
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested

class WaterRecordTest {
    @BeforeEach
    fun setup() { }
    
    @Nested
    inner class ProgressTest {
        @Test
        fun `progress는 value를 goal로 나눈 값이다`() { }
    }
}

// ✅ Instrumented Test (src/androidTest/) - JUnit4
import org.junit.Test
import org.junit.Before
import org.junit.Rule

class DataStoreTest {
    @get:Rule
    val composeTestRule = createComposeRule()
    
    @Before
    fun setup() { }
    
    @Test
    fun `DataStore에 값이 저장된다`() { }
}
```

### 2.4 도구별 사용법

#### JUnit 5

```kotlin
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.DisplayName

class WaterRecordTest {
    
    private lateinit var record: WaterRecord
    
    @BeforeEach
    fun setup() {
        record = WaterRecord(
            date = LocalDate.now(),
            value = 0,
            isSuccess = false,
            goal = 2000
        )
    }
    
    @Nested
    @DisplayName("progress 계산")
    inner class ProgressTest {
        
        @Test
        fun `goal이 0일 때 progress는 0이다`() {
            val record = WaterRecord(date = LocalDate.now(), value = 100, isSuccess = false, goal = 0)
            assertEquals(0f, record.progress)
        }
        
        @Test
        fun `value가 goal의 절반일 때 progress는 0점5이다`() {
            val record = WaterRecord(date = LocalDate.now(), value = 1000, isSuccess = false, goal = 2000)
            assertEquals(0.5f, record.progress, 0.01f)
        }
    }
}
```

#### Turbine (Flow 테스트)

```kotlin
import app.cash.turbine.test
import kotlinx.coroutines.test.runTest

class HomeViewModelTest {
    
    @Test
    fun `AddWater 이벤트 시 currentMl이 증가한다`() = runTest {
        val viewModel = HomeViewModel(fakeRepository)
        
        viewModel.uiState.test {
            // 초기 상태
            assertEquals(0, awaitItem().currentMl)
            
            // 이벤트 발생
            viewModel.onEvent(HomeEvent.AddWater(100))
            
            // 상태 변경 확인
            assertEquals(100, awaitItem().currentMl)
            
            cancelAndIgnoreRemainingEvents()
        }
    }
}
```

#### MockK (모킹)

```kotlin
import io.mockk.*

class WaterRepositoryTest {
    
    private val dataStore: WaterDataStore = mockk()
    private lateinit var repository: WaterRepository
    
    @BeforeEach
    fun setup() {
        repository = WaterRepositoryImpl(dataStore)
    }
    
    @Test
    fun `addWater 호출 시 DataStore에 저장된다`() = runTest {
        // Given
        coEvery { dataStore.getTodayRecord() } returns WaterRecord(
            date = LocalDate.now(),
            value = 100,
            isSuccess = false,
            goal = 2000
        )
        coEvery { dataStore.saveRecord(any()) } just Runs
        
        // When
        repository.addWater(200)
        
        // Then
        coVerify { 
            dataStore.saveRecord(match { it.value == 300 })
        }
    }
}
```

---

## 3. 레이어별 테스트 전략

### 3.1 테스트 피라미드

```
                    ┌───────────┐
                    │    E2E    │  ← 적은 수, 느림
                    │  (UI Test)│
                   ─┴───────────┴─
                  ╱               ╲
                 ╱   Integration   ╲  ← 중간
                ╱───────────────────╲
               ╱                     ╲
              ╱     Unit Tests        ╲  ← 많은 수, 빠름
             ╱─────────────────────────╲
```

### 3.2 Domain Layer 테스트

**테스트 대상:** Model, Use Case

**특징:**
- 순수 Kotlin 코드
- 외부 의존성 없음
- 빠른 실행

```kotlin
// domain/model/WaterRecordTest.kt
class WaterRecordTest {
    
    @Test
    fun `id는 날짜 문자열로 생성된다`() {
        val date = LocalDate.of(2026, 1, 20)
        val record = WaterRecord(date, 1000, true, 2000)
        
        assertEquals("2026-01-20", record.id)
    }
    
    @Test
    fun `isSuccess는 value가 goal 이상일 때 true`() {
        val record = WaterRecord(LocalDate.now(), 2000, true, 2000)
        assertTrue(record.isSuccess)
    }
    
    @Test
    fun `progress는 value를 goal로 나눈 값`() {
        val record = WaterRecord(LocalDate.now(), 1500, false, 2000)
        assertEquals(0.75f, record.progress, 0.001f)
    }
    
    @Test
    fun `remainingMl은 goal에서 value를 뺀 값`() {
        val record = WaterRecord(LocalDate.now(), 1500, false, 2000)
        assertEquals(500, record.remainingMl)
    }
    
    @Test
    fun `remainingMl은 음수가 되지 않는다`() {
        val record = WaterRecord(LocalDate.now(), 2500, true, 2000)
        assertEquals(0, record.remainingMl)
    }
}
```

### 3.3 Data Layer 테스트

**테스트 대상:** Repository, DataStore

**특징:**
- DataStore 모킹 필요
- Coroutines 테스트

```kotlin
// data/repository/WaterRepositoryImplTest.kt
class WaterRepositoryImplTest {
    
    private val dataStore: WaterDataStore = mockk()
    private lateinit var repository: WaterRepository
    
    @BeforeEach
    fun setup() {
        repository = WaterRepositoryImpl(dataStore)
    }
    
    @Test
    fun `getTodayRecord - 오늘 기록이 있으면 반환한다`() = runTest {
        // Given
        val todayRecord = WaterRecord(LocalDate.now(), 500, false, 2000)
        coEvery { dataStore.getTodayRecord() } returns todayRecord
        
        // When
        val result = repository.getTodayRecord()
        
        // Then
        assertEquals(todayRecord, result)
    }
    
    @Test
    fun `getTodayRecord - 오늘 기록이 없으면 새로 생성한다`() = runTest {
        // Given
        coEvery { dataStore.getTodayRecord() } returns null
        coEvery { dataStore.getGoal() } returns 2000
        coEvery { dataStore.saveRecord(any()) } just Runs
        
        // When
        val result = repository.getTodayRecord()
        
        // Then
        assertNotNull(result)
        assertEquals(0, result?.value)
        assertEquals(2000, result?.goal)
        coVerify { dataStore.saveRecord(any()) }
    }
    
    @Test
    fun `addWater - 현재 값에 양이 추가된다`() = runTest {
        // Given
        val currentRecord = WaterRecord(LocalDate.now(), 500, false, 2000)
        coEvery { dataStore.getTodayRecord() } returns currentRecord
        coEvery { dataStore.saveRecord(any()) } just Runs
        
        // When
        repository.addWater(300)
        
        // Then
        coVerify {
            dataStore.saveRecord(match { 
                it.value == 800 && it.date == LocalDate.now()
            })
        }
    }
    
    @Test
    fun `addWater - 목표 달성 시 isSuccess가 true가 된다`() = runTest {
        // Given
        val currentRecord = WaterRecord(LocalDate.now(), 1800, false, 2000)
        coEvery { dataStore.getTodayRecord() } returns currentRecord
        coEvery { dataStore.saveRecord(any()) } just Runs
        
        // When
        repository.addWater(300)
        
        // Then
        coVerify {
            dataStore.saveRecord(match { it.isSuccess })
        }
    }
    
    @Test
    fun `subtractWater - 음수가 되지 않는다`() = runTest {
        // Given
        val currentRecord = WaterRecord(LocalDate.now(), 100, false, 2000)
        coEvery { dataStore.getTodayRecord() } returns currentRecord
        coEvery { dataStore.saveRecord(any()) } just Runs
        
        // When
        repository.subtractWater(200)
        
        // Then
        coVerify {
            dataStore.saveRecord(match { it.value == 0 })
        }
    }
    
    @Test
    fun `resetToday - 오늘 기록이 0으로 초기화된다`() = runTest {
        // Given
        val currentRecord = WaterRecord(LocalDate.now(), 1500, true, 2000)
        coEvery { dataStore.getTodayRecord() } returns currentRecord
        coEvery { dataStore.saveRecord(any()) } just Runs
        
        // When
        repository.resetToday()
        
        // Then
        coVerify {
            dataStore.saveRecord(match { 
                it.value == 0 && !it.isSuccess 
            })
        }
    }
}
```

### 3.4 UI Layer (ViewModel) 테스트

**테스트 대상:** ViewModel

**특징:**
- StateFlow 테스트 (Turbine 사용)
- Repository 모킹

```kotlin
// ui/home/HomeViewModelTest.kt
class HomeViewModelTest {
    
    private val waterRepository: WaterRepository = mockk()
    private val settingsRepository: SettingsRepository = mockk()
    private val analyticsTracker: AnalyticsTracker = mockk(relaxed = true)
    private lateinit var viewModel: HomeViewModel
    
    @BeforeEach
    fun setup() {
        // 기본 모킹 설정
        coEvery { waterRepository.getTodayRecord() } returns WaterRecord(
            date = LocalDate.now(),
            value = 0,
            isSuccess = false,
            goal = 2000
        )
        coEvery { settingsRepository.getQuickButtons() } returns listOf(100, 200, 300, 500)
        
        viewModel = HomeViewModel(waterRepository, settingsRepository, analyticsTracker)
    }
    
    @Test
    fun `초기 상태는 로딩 후 데이터가 로드된다`() = runTest {
        viewModel.uiState.test {
            val state = awaitItem()
            assertEquals(0, state.currentMl)
            assertEquals(2000, state.goalMl)
            assertEquals(listOf(100, 200, 300, 500), state.quickButtons)
            cancelAndIgnoreRemainingEvents()
        }
    }
    
    @Test
    fun `AddWater 이벤트 시 currentMl이 증가한다`() = runTest {
        coEvery { waterRepository.addWater(any()) } just Runs
        coEvery { waterRepository.getTodayRecord() } returnsMany listOf(
            WaterRecord(LocalDate.now(), 0, false, 2000),
            WaterRecord(LocalDate.now(), 100, false, 2000)
        )
        
        viewModel.uiState.test {
            skipItems(1) // 초기 상태
            
            viewModel.onEvent(HomeEvent.AddWater(100))
            
            assertEquals(100, awaitItem().currentMl)
            cancelAndIgnoreRemainingEvents()
        }
        
        coVerify { waterRepository.addWater(100) }
    }
    
    @Test
    fun `목표 달성 시 Analytics 이벤트가 전송된다`() = runTest {
        coEvery { waterRepository.addWater(any()) } just Runs
        coEvery { waterRepository.getTodayRecord() } returnsMany listOf(
            WaterRecord(LocalDate.now(), 1900, false, 2000),
            WaterRecord(LocalDate.now(), 2100, true, 2000)
        )
        
        viewModel = HomeViewModel(waterRepository, settingsRepository, analyticsTracker)
        
        viewModel.uiState.test {
            skipItems(1)
            
            viewModel.onEvent(HomeEvent.AddWater(200))
            
            awaitItem() // 상태 변경 대기
            cancelAndIgnoreRemainingEvents()
        }
        
        verify { analyticsTracker.logGoalAchieved(any(), any(), any()) }
    }
    
    @Test
    fun `SubtractWater 이벤트 시 currentMl이 감소한다`() = runTest {
        coEvery { waterRepository.subtractWater(any()) } just Runs
        coEvery { waterRepository.getTodayRecord() } returnsMany listOf(
            WaterRecord(LocalDate.now(), 500, false, 2000),
            WaterRecord(LocalDate.now(), 300, false, 2000)
        )
        
        viewModel = HomeViewModel(waterRepository, settingsRepository, analyticsTracker)
        
        viewModel.uiState.test {
            skipItems(1)
            
            viewModel.onEvent(HomeEvent.SubtractWater(200))
            
            assertEquals(300, awaitItem().currentMl)
            cancelAndIgnoreRemainingEvents()
        }
    }
    
    @Test
    fun `ToggleSubtractMode 시 모드가 전환된다`() = runTest {
        viewModel.uiState.test {
            val initial = awaitItem()
            assertFalse(initial.isSubtractMode)
            
            viewModel.onEvent(HomeEvent.ToggleSubtractMode)
            assertTrue(awaitItem().isSubtractMode)
            
            viewModel.onEvent(HomeEvent.ToggleSubtractMode)
            assertFalse(awaitItem().isSubtractMode)
            
            cancelAndIgnoreRemainingEvents()
        }
    }
    
    @Test
    fun `progress 계산이 정확하다`() = runTest {
        coEvery { waterRepository.getTodayRecord() } returns WaterRecord(
            date = LocalDate.now(),
            value = 1500,
            isSuccess = false,
            goal = 2000
        )
        
        viewModel = HomeViewModel(waterRepository, settingsRepository, analyticsTracker)
        
        viewModel.uiState.test {
            val state = awaitItem()
            assertEquals(0.75f, state.progress, 0.001f)
            cancelAndIgnoreRemainingEvents()
        }
    }
    
    @Test
    fun `remainingCups 계산이 정확하다`() = runTest {
        coEvery { waterRepository.getTodayRecord() } returns WaterRecord(
            date = LocalDate.now(),
            value = 1500,
            isSuccess = false,
            goal = 2000
        )
        
        viewModel = HomeViewModel(waterRepository, settingsRepository, analyticsTracker)
        
        viewModel.uiState.test {
            val state = awaitItem()
            assertEquals(2, state.remainingCups) // 500ml / 250ml = 2잔
            cancelAndIgnoreRemainingEvents()
        }
    }
}
```

### 3.5 UI Component 테스트 (Instrumented)

**테스트 대상:** Compose UI 컴포넌트

**위치:** `src/androidTest/`

**특징:**
- Compose Testing 사용 (JUnit4 기반)
- UI 상호작용 테스트
- 실제 디바이스/에뮬레이터에서 실행

> ⚠️ **주의**: Compose UI 테스트는 `androidTest`에서 JUnit4로 실행됩니다. JUnit5 어노테이션 사용 불가!

```kotlin
// src/androidTest/java/.../ui/components/WaveAnimationTest.kt
import org.junit.Test  // JUnit4!
import org.junit.Rule
import androidx.compose.ui.test.junit4.createComposeRule

class WaveAnimationTest {
    
    @get:Rule
    val composeTestRule = createComposeRule()
    
    @Test
    fun progress가_0일_때_물이_표시되지_않는다() {  // JUnit4에서는 한글 백틱 대신 언더스코어 권장
        composeTestRule.setContent {
            WaveAnimationView(
                progress = 0f,
                color = Color.Blue
            )
        }
        
        // Canvas 내부 확인은 스크린샷 테스트로 대체 가능
    }
    
    @Test
    fun progress가_1일_때_물이_가득_찬다() {
        composeTestRule.setContent {
            WaveAnimationView(
                progress = 1f,
                color = Color.Blue
            )
        }
    }
}

// src/androidTest/java/.../ui/home/HomeScreenTest.kt
import org.junit.Test
import org.junit.Rule

class HomeScreenTest {
    
    @get:Rule
    val composeTestRule = createComposeRule()
    
    @Test
    fun 퀵버튼_클릭_시_onAddWater가_호출된다() {
        var addedAmount = 0
        
        composeTestRule.setContent {
            QuickButton(
                amount = 100,
                isSubtractMode = false,
                onClick = { addedAmount = 100 }
            )
        }
        
        composeTestRule.onNodeWithText("+100ml").performClick()
        
        assertEquals(100, addedAmount)
    }
    
    @Test
    fun 빼기_모드에서는_버튼_텍스트가_마이너스로_표시된다() {
        composeTestRule.setContent {
            QuickButton(
                amount = 100,
                isSubtractMode = true,
                onClick = { }
            )
        }
        
        composeTestRule.onNodeWithText("-100ml").assertIsDisplayed()
    }
    
    @Test
    fun 목표_달성_시_축하_메시지가_표시된다() {
        composeTestRule.setContent {
            HomeScreen(
                uiState = HomeUiState(
                    currentMl = 2000,
                    goalMl = 2000
                ),
                onEvent = { }
            )
        }
        
        composeTestRule.onNodeWithText("🎉").assertIsDisplayed()
    }
}
```

### 3.6 테스트 파일 위치 요약

```
app/src/
├── test/                          # JVM Tests (JUnit5)
│   └── java/com/onceagain/drinksomewater/
│       ├── domain/
│       │   └── model/
│       │       ├── WaterRecordTest.kt        ✅ JUnit5
│       │       └── UserProfileTest.kt        ✅ JUnit5
│       ├── data/
│       │   └── repository/
│       │       └── WaterRepositoryImplTest.kt ✅ JUnit5 + MockK
│       └── ui/
│           ├── home/
│           │   └── HomeViewModelTest.kt      ✅ JUnit5 + Turbine
│           └── history/
│               └── HistoryViewModelTest.kt   ✅ JUnit5 + Turbine
│
└── androidTest/                   # Instrumented Tests (JUnit4)
    └── java/com/onceagain/drinksomewater/
        ├── data/
        │   └── datastore/
        │       └── WaterDataStoreTest.kt     ✅ JUnit4 (Context 필요)
        └── ui/
            ├── components/
            │   └── WaveAnimationTest.kt      ✅ JUnit4 + ComposeTestRule
            └── home/
                └── HomeScreenTest.kt         ✅ JUnit4 + ComposeTestRule
```
```

---

## 4. Phase별 테스트 명세

### Phase 2: 데이터 레이어 테스트

#### 2.1 WaterRecord 모델

```kotlin
class WaterRecordTest {
    // 생성 테스트
    @Test fun `id는 날짜 문자열로 생성된다`()
    @Test fun `기본 생성자로 객체가 생성된다`()
    
    // 계산 프로퍼티 테스트
    @Test fun `progress는 value를 goal로 나눈 값이다`()
    @Test fun `progress는 goal이 0일 때 0이다`()
    @Test fun `progress는 1을 초과하지 않는다`()
    @Test fun `remainingMl은 goal에서 value를 뺀 값이다`()
    @Test fun `remainingMl은 음수가 되지 않는다`()
    @Test fun `remainingCups는 remainingMl을 250으로 나눈 값이다`()
    
    // isSuccess 테스트
    @Test fun `value가 goal 이상이면 isSuccess는 true이다`()
    @Test fun `value가 goal 미만이면 isSuccess는 false이다`()
}
```

#### 2.2 UserProfile 모델

```kotlin
class UserProfileTest {
    @Test fun `recommendedIntake는 체중에 33을 곱한 값이다`()
    @Test fun `기본 체중은 65kg이다`()
    @Test fun `체중이 0이면 권장량은 0이다`()
}
```

#### 2.3 WaterRepository

```kotlin
class WaterRepositoryTest {
    // 조회
    @Test fun `getTodayRecord - 오늘 기록이 있으면 반환한다`()
    @Test fun `getTodayRecord - 오늘 기록이 없으면 새로 생성한다`()
    @Test fun `getAllRecords - 전체 기록을 날짜 역순으로 반환한다`()
    @Test fun `getGoal - 저장된 목표량을 반환한다`()
    @Test fun `getGoal - 목표량이 없으면 기본값 2000을 반환한다`()
    
    // 수정
    @Test fun `addWater - 현재 값에 양이 추가된다`()
    @Test fun `addWater - 목표 달성 시 isSuccess가 true가 된다`()
    @Test fun `addWater - 위젯 데이터가 동기화된다`()
    @Test fun `subtractWater - 현재 값에서 양이 빠진다`()
    @Test fun `subtractWater - 음수가 되지 않는다`()
    @Test fun `resetToday - 오늘 기록이 0으로 초기화된다`()
    @Test fun `updateGoal - 목표량이 변경된다`()
    @Test fun `updateGoal - 오늘 기록의 goal도 업데이트된다`()
}
```

### Phase 3: 홈 화면 테스트

#### 3.1 HomeViewModel

```kotlin
class HomeViewModelTest {
    // 초기화
    @Test fun `초기 상태는 로딩 후 데이터가 로드된다`()
    @Test fun `초기 퀵버튼은 설정에서 로드된다`()
    
    // Refresh
    @Test fun `Refresh 시 최신 데이터가 로드된다`()
    
    // AddWater
    @Test fun `AddWater 시 currentMl이 증가한다`()
    @Test fun `AddWater 후 목표 달성 시 goalAchieved가 true`()
    @Test fun `AddWater 시 Analytics 이벤트가 전송된다`()
    @Test fun `목표 달성 시 goalAchieved Analytics 이벤트가 전송된다`()
    
    // SubtractWater
    @Test fun `SubtractWater 시 currentMl이 감소한다`()
    @Test fun `SubtractWater 시 음수가 되지 않는다`()
    @Test fun `SubtractWater 시 Analytics 이벤트가 전송된다`()
    
    // ResetToday
    @Test fun `ResetToday 시 currentMl이 0이 된다`()
    @Test fun `ResetToday 시 Analytics 이벤트가 전송된다`()
    
    // Mode Toggle
    @Test fun `ToggleSubtractMode 시 모드가 전환된다`()
    
    // 계산 프로퍼티
    @Test fun `progress 계산이 정확하다`()
    @Test fun `remainingMl 계산이 정확하다`()
    @Test fun `remainingCups 계산이 정확하다`()
    @Test fun `isGoalAchieved 계산이 정확하다`()
    
    // Notification Banner
    @Test fun `알림 권한이 없으면 배너가 표시된다`()
    @Test fun `배너 닫기 시 다시 표시되지 않는다`()
}
```

#### 3.2 WaveAnimation

```kotlin
class WaveAnimationTest {
    @Test fun `progress가 0일 때 물이 없다`()
    @Test fun `progress가 1일 때 물이 가득 찬다`()
    @Test fun `progress가 범위를 벗어나면 클램핑된다`()
    @Test fun `애니메이션이 무한 반복된다`()
}
```

### Phase 4: 기록 화면 테스트

#### 4.1 HistoryViewModel

```kotlin
class HistoryViewModelTest {
    // 데이터 로드
    @Test fun `ViewDidLoad 시 전체 기록이 로드된다`()
    @Test fun `successDates가 올바르게 필터링된다`()
    
    // 날짜 선택
    @Test fun `SelectDate 시 해당 날짜 기록이 선택된다`()
    @Test fun `SelectDate 시 Analytics 이벤트가 전송된다`()
    @Test fun `존재하지 않는 날짜 선택 시 null이 된다`()
    
    // 월간 통계
    @Test fun `monthlySuccessCount 계산이 정확하다`()
    @Test fun `monthlyTotalDays 계산이 정확하다`()
}
```

#### 4.2 CustomCalendar

```kotlin
class CustomCalendarTest {
    @Test fun `달성일이 하이라이트 표시된다`()
    @Test fun `오늘 날짜가 구분 표시된다`()
    @Test fun `선택된 날짜가 강조 표시된다`()
    @Test fun `이전 월 버튼 클릭 시 월이 변경된다`()
    @Test fun `다음 월 버튼 클릭 시 월이 변경된다`()
    @Test fun `날짜 클릭 시 onDateSelected가 호출된다`()
}
```

### Phase 5: 설정 화면 테스트

#### 5.1 SettingsViewModel

```kotlin
class SettingsViewModelTest {
    @Test fun `초기 상태에서 설정값이 로드된다`()
    @Test fun `UpdateGoal 시 목표량이 변경된다`()
    @Test fun `UpdateGoal 시 Analytics 이벤트가 전송된다`()
    @Test fun `UpdateQuickButtons 시 퀵버튼이 변경된다`()
}
```

### Phase 6: 알림 시스템 테스트

#### 6.1 NotificationMessages

```kotlin
class NotificationMessagesTest {
    @Test fun `메시지가 10개 이상 존재한다`()
    @Test fun `random 호출 시 null이 아닌 값을 반환한다`()
    @Test fun `모든 메시지가 비어있지 않다`()
}
```

#### 6.2 NotificationHelper

```kotlin
class NotificationHelperTest {
    @Test fun `알림 권한 확인이 정확하다`()
    @Test fun `알림 채널이 올바르게 생성된다`()
    @Test fun `알림이 올바른 내용으로 생성된다`()
}
```

### Phase 7: 위젯 테스트

#### 7.1 AddWaterAction

```kotlin
class AddWaterActionTest {
    @Test fun `onAction 시 Repository addWater가 호출된다`()
    @Test fun `onAction 후 위젯이 갱신된다`()
}
```

### Phase 9: Health Connect 테스트

#### 9.1 HealthConnectHelper

```kotlin
class HealthConnectHelperTest {
    @Test fun `체중 읽기가 정상 동작한다`()
    @Test fun `권장량 계산이 정확하다`()
    @Test fun `물 섭취 기록이 저장된다`()
}
```

### Phase 11: Wear OS 테스트

#### 11.1 WatchViewModel

```kotlin
class WatchViewModelTest {
    @Test fun `Phone에서 데이터 수신 시 상태가 업데이트된다`()
    @Test fun `AddWater 시 Phone으로 메시지가 전송된다`()
}
```

#### 11.2 DataLayerSync

```kotlin
class DataLayerSyncTest {
    @Test fun `syncToWatch 호출 시 데이터가 전송된다`()
    @Test fun `onDataChanged 시 콜백이 호출된다`()
}
```

---

## 5. 테스트 유틸리티

### 5.1 테스트 픽스처

```kotlin
// test/util/TestFixtures.kt
object TestFixtures {
    
    fun waterRecord(
        date: LocalDate = LocalDate.now(),
        value: Int = 0,
        goal: Int = 2000
    ) = WaterRecord(
        date = date,
        value = value,
        isSuccess = value >= goal,
        goal = goal
    )
    
    fun waterRecordList(count: Int = 7): List<WaterRecord> {
        return (0 until count).map { daysAgo ->
            waterRecord(
                date = LocalDate.now().minusDays(daysAgo.toLong()),
                value = (500..2500).random(),
                goal = 2000
            )
        }
    }
    
    fun homeUiState(
        currentMl: Int = 0,
        goalMl: Int = 2000,
        quickButtons: List<Int> = listOf(100, 200, 300, 500),
        isSubtractMode: Boolean = false
    ) = HomeUiState(
        currentMl = currentMl,
        goalMl = goalMl,
        quickButtons = quickButtons,
        isSubtractMode = isSubtractMode
    )
}
```

### 5.2 Fake Repository

```kotlin
// test/fake/FakeWaterRepository.kt
class FakeWaterRepository : WaterRepository {
    
    private val records = mutableListOf<WaterRecord>()
    private var goal = 2000
    
    override suspend fun getTodayRecord(): WaterRecord? {
        return records.find { it.date == LocalDate.now() }
    }
    
    override suspend fun getAllRecords(): List<WaterRecord> {
        return records.sortedByDescending { it.date }
    }
    
    override suspend fun addWater(amount: Int) {
        val today = records.find { it.date == LocalDate.now() }
        if (today != null) {
            val updated = today.copy(
                value = today.value + amount,
                isSuccess = (today.value + amount) >= today.goal
            )
            records.remove(today)
            records.add(updated)
        } else {
            records.add(WaterRecord(LocalDate.now(), amount, amount >= goal, goal))
        }
    }
    
    override suspend fun subtractWater(amount: Int) {
        val today = records.find { it.date == LocalDate.now() } ?: return
        val newValue = maxOf(0, today.value - amount)
        val updated = today.copy(
            value = newValue,
            isSuccess = newValue >= today.goal
        )
        records.remove(today)
        records.add(updated)
    }
    
    override suspend fun resetToday() {
        val today = records.find { it.date == LocalDate.now() } ?: return
        val updated = today.copy(value = 0, isSuccess = false)
        records.remove(today)
        records.add(updated)
    }
    
    override suspend fun updateGoal(newGoal: Int) {
        goal = newGoal
    }
    
    // 테스트 헬퍼
    fun setRecords(newRecords: List<WaterRecord>) {
        records.clear()
        records.addAll(newRecords)
    }
}
```

### 5.3 Coroutines Test Rule

```kotlin
// test/util/MainDispatcherRule.kt
@OptIn(ExperimentalCoroutinesApi::class)
class MainDispatcherRule(
    private val dispatcher: TestDispatcher = UnconfinedTestDispatcher()
) : TestWatcher() {
    
    override fun starting(description: Description) {
        Dispatchers.setMain(dispatcher)
    }
    
    override fun finished(description: Description) {
        Dispatchers.resetMain()
    }
}

// 사용 예시
class HomeViewModelTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()
    
    @Test
    fun `테스트`() = runTest {
        // ...
    }
}
```

---

## 6. 테스트 실행 가이드

### 6.1 명령어

```bash
# 전체 테스트 실행
./gradlew test

# 특정 모듈 테스트
./gradlew :app:test
./gradlew :widget:test
./gradlew :wear:test
./gradlew :analytics:test

# 특정 테스트 클래스 실행
./gradlew :app:test --tests "*.HomeViewModelTest"

# 특정 테스트 메서드 실행
./gradlew :app:test --tests "*.HomeViewModelTest.AddWater*"

# 실패한 테스트만 재실행
./gradlew test --rerun-tasks

# 테스트 리포트 생성
./gradlew test jacocoTestReport

# 커버리지 리포트 (Kover)
./gradlew koverHtmlReport
```

### 6.2 커버리지 목표

| 레이어 | 목표 커버리지 |
|--------|-------------|
| Domain (Model, UseCase) | 90%+ |
| Data (Repository) | 80%+ |
| UI (ViewModel) | 80%+ |
| UI (Composable) | 60%+ |
| Service | 70%+ |

### 6.3 CI 테스트 설정 (GitHub Actions)

```yaml
# .github/workflows/android-test.yml
name: Android Test

on:
  push:
    paths:
      - 'android/**'
  pull_request:
    paths:
      - 'android/**'

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: android
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Grant execute permission for gradlew
        run: chmod +x gradlew
      
      - name: Run tests
        run: ./gradlew test
      
      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: android/app/build/reports/tests/
```

---

## 부록

### A. 참고 자료

- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Turbine - Flow Testing](https://github.com/cashapp/turbine)
- [MockK - Kotlin Mocking](https://mockk.io/)
- [Compose Testing](https://developer.android.com/jetpack/compose/testing)

### B. 관련 문서

- [프로젝트 계획서](./ANDROID_PROJECT_PLAN.md)
- [iOS-Android 매핑](./IOS_ANDROID_MAPPING.md)
