# Android TDD Implementation Guide

> 💧 Gulp Android Project - Test-Driven Development Guide

---

## Meta Information

| Field | Value |
|-------|-------|
| **Version** | 1.0.0 |
| **Last Updated** | 2026-01-20 |
| **Test Framework** | JUnit5, Turbine, MockK |

---

## Table of Contents

1. [TDD Principles](#1-tdd-principles)
2. [Test Tools](#2-test-tools)
3. [Testing Strategy by Layer](#3-testing-strategy-by-layer)
4. [Test Specs by Phase](#4-test-specs-by-phase)
5. [Test Utilities](#5-test-utilities)
6. [Test Execution Guide](#6-test-execution-guide)

---

## 1. TDD Principles

### 1.1 Red-Green-Refactor Cycle

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│     ┌─────────┐     ┌─────────┐     ┌─────────────┐        │
│     │   RED   │ ──▶ │  GREEN  │ ──▶ │  REFACTOR   │        │
│     │ (Fail)  │     │ (Pass)  │     │ (Improve)   │        │
│     └─────────┘     └─────────┘     └─────────────┘        │
│          │                                   │              │
│          └───────────────────────────────────┘              │
│                        Repeat                               │
└─────────────────────────────────────────────────────────────┘
```

1. **Red**: Write a failing test first
2. **Green**: Write the minimum code to pass the test
3. **Refactor**: Improve the code (tests must keep passing)

### 1.2 TDD Rules

| Rule | Description |
|------|-------------|
| **Test first** | Write a failing test before writing production code |
| **Minimum code** | Write only the minimum code needed to pass the test |
| **One at a time** | Add only one test at a time |
| **Refactor** | Clean up code after tests pass |
| **Keep tests green** | Tests must always pass during refactoring |

### 1.3 Test Naming Convention

```kotlin
// Korean backtick style (recommended)
@Test
fun `adding water increases current intake`() { }

@Test
fun `isSuccess becomes true when goal is reached`() { }

@Test
fun `negative amounts are not added`() { }

// Given-When-Then style (alternative)
@Test
fun givenEmptyRecord_whenAddWater100ml_thenCurrentMlIs100() { }
```

---

## 2. Test Tools

### 2.1 Test Environment Types

> ⚠️ **Important**: On Android, tests run in two separate environments: JVM and Android runtime. Understand the constraints of each and write tests accordingly.

| Test Type | Location | Runner | Environment | Speed | Purpose |
|-----------|----------|--------|-------------|-------|---------|
| **Unit Test (JVM)** | `src/test/` | JUnit5 | JVM | Fast ⚡ | Domain, ViewModel, Repository |
| **Instrumented Test** | `src/androidTest/` | AndroidJUnitRunner (JUnit4) | Android Device/Emulator | Slow 🐢 | Needs Context, DataStore, Room |
| **Compose UI Test** | `src/androidTest/` | AndroidJUnitRunner | Android Device/Emulator | Slow 🐢 | UI interactions, screenshots |

#### Test Environment Selection Guide

```
Does the test target need Android Context?
  │
  ├─ NO → JVM Unit Test (src/test/)
  │        ✅ Domain Model, ViewModel, Repository (with mocks)
  │        ✅ UseCase, Mapper, Util
  │        ✅ Flow/StateFlow tests (Turbine)
  │
  └─ YES → Instrumented Test (src/androidTest/)
           ├─ UI test? → Compose UI Test
           │   ✅ Screen rendering, clicks, scrolls
           │   ✅ Accessibility verification
           │   ✅ Screenshot tests
           │
           └─ Non-UI test?
               ✅ DataStore real behavior
               ✅ WorkManager
               ✅ Health Connect permissions
```

### 2.2 Dependencies

> **Kotlin 2.0 + Compose**: Starting with Kotlin 2.0, the Compose compiler is integrated via the `org.jetbrains.kotlin.plugin.compose` plugin. No separate `compose-compiler` artifact version is needed. See the Version Catalog section in the project plan for details.

```kotlin
// build.gradle.kts (app module)
plugins {
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.compose.compiler)  // Kotlin 2.0 Compose plugin
}

dependencies {
    // ═══════════════════════════════════════════════════
    // JVM Unit Tests (src/test/)
    // ═══════════════════════════════════════════════════
    
    // JUnit 5 - JVM test framework
    testImplementation(libs.junit5)
    
    // Turbine - Flow testing (StateFlow, SharedFlow)
    testImplementation(libs.turbine)
    
    // MockK - Kotlin mocking library
    testImplementation(libs.mockk)
    
    // Coroutines Test - runTest, TestDispatcher
    testImplementation(libs.kotlinx.coroutines.test)
    
    // ═══════════════════════════════════════════════════
    // Instrumented Tests (src/androidTest/)
    // ═══════════════════════════════════════════════════
    
    // AndroidJUnitRunner (JUnit4-based)
    androidTestImplementation(libs.androidx.test.runner)
    androidTestImplementation(libs.androidx.test.rules)
    
    // Compose UI Test
    androidTestImplementation(libs.androidx.compose.ui.test)
    debugImplementation(libs.androidx.compose.ui.test.manifest)
    
    // MockK Android (for mocking in instrumented tests)
    androidTestImplementation(libs.mockk.android)
    
    // Hilt Testing (DI testing)
    androidTestImplementation(libs.hilt.android.testing)
    kspAndroidTest(libs.hilt.compiler)
}
```

### 2.3 JUnit5 vs JUnit4 (Important!)

| Item | JUnit5 (JVM) | JUnit4 (Instrumented) |
|------|-------------|----------------------|
| **Used in** | `src/test/` | `src/androidTest/` |
| **Annotation** | `@Test` (jupiter) | `@Test` (junit4) |
| **Setup** | `@BeforeEach` | `@Before` |
| **Teardown** | `@AfterEach` | `@After` |
| **Nested classes** | `@Nested` ✅ | ❌ Not supported |
| **DisplayName** | `@DisplayName` ✅ | ❌ Not supported |
| **Korean method names** | `` `Korean test name`() `` ✅ | `` `Korean test name`() `` ✅ |

#### JUnit5 Gradle Setup (Required!)

> ⚠️ **Important**: To use JUnit5, `useJUnitPlatform()` **must** be set in `build.gradle.kts`.

```kotlin
// app/build.gradle.kts
android {
    // ...
}

dependencies {
    // ✅ JUnit5 unified artifact (includes api + engine + params)
    testImplementation(libs.junit5)
}

tasks.withType<Test> {
    useJUnitPlatform()  // ← Without this, JUnit5 tests won't run!
}
```

#### Required entries in libs.versions.toml

```toml
[versions]
junit5 = "5.10.0"

[libraries]
# ✅ Recommended: use the unified artifact
# junit-jupiter includes api + engine + params
junit5 = { group = "org.junit.jupiter", name = "junit-jupiter", version.ref = "junit5" }
```

> **Note**: Using the `junit-jupiter` unified artifact means you don't need to specify api/engine separately. The project plan's Version Catalog uses this approach.

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
        fun `progress is value divided by goal`() { }
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
    fun `value is saved to DataStore`() { }
}
```

### 2.4 Tool Usage

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
    @DisplayName("progress calculation")
    inner class ProgressTest {
        
        @Test
        fun `progress is 0 when goal is 0`() {
            val record = WaterRecord(date = LocalDate.now(), value = 100, isSuccess = false, goal = 0)
            assertEquals(0f, record.progress)
        }
        
        @Test
        fun `progress is 0 point 5 when value is half of goal`() {
            val record = WaterRecord(date = LocalDate.now(), value = 1000, isSuccess = false, goal = 2000)
            assertEquals(0.5f, record.progress, 0.01f)
        }
    }
}
```

#### Turbine (Flow Testing)

```kotlin
import app.cash.turbine.test
import kotlinx.coroutines.test.runTest

class HomeViewModelTest {
    
    @Test
    fun `currentMl increases on AddWater event`() = runTest {
        val viewModel = HomeViewModel(fakeRepository)
        
        viewModel.uiState.test {
            // Initial state
            assertEquals(0, awaitItem().currentMl)
            
            // Trigger event
            viewModel.onEvent(HomeEvent.AddWater(100))
            
            // Verify state change
            assertEquals(100, awaitItem().currentMl)
            
            cancelAndIgnoreRemainingEvents()
        }
    }
}
```

#### MockK (Mocking)

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
    fun `calling addWater saves to DataStore`() = runTest {
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

## 3. Testing Strategy by Layer

### 3.1 Test Pyramid

```
                    ┌───────────┐
                    │    E2E    │  ← Few, slow
                    │  (UI Test)│
                   ─┴───────────┴─
                  ╱               ╲
                 ╱   Integration   ╲  ← Medium
                ╱───────────────────╲
               ╱                     ╲
              ╱     Unit Tests        ╲  ← Many, fast
             ╱─────────────────────────╲
```

### 3.2 Domain Layer Tests

**Test targets:** Model, Use Case

**Characteristics:**
- Pure Kotlin code
- No external dependencies
- Fast execution

```kotlin
// domain/model/WaterRecordTest.kt
class WaterRecordTest {
    
    @Test
    fun `id is generated from date string`() {
        val date = LocalDate.of(2026, 1, 20)
        val record = WaterRecord(date, 1000, true, 2000)
        
        assertEquals("2026-01-20", record.id)
    }
    
    @Test
    fun `isSuccess is true when value is at least goal`() {
        val record = WaterRecord(LocalDate.now(), 2000, true, 2000)
        assertTrue(record.isSuccess)
    }
    
    @Test
    fun `progress is value divided by goal`() {
        val record = WaterRecord(LocalDate.now(), 1500, false, 2000)
        assertEquals(0.75f, record.progress, 0.001f)
    }
    
    @Test
    fun `remainingMl is goal minus value`() {
        val record = WaterRecord(LocalDate.now(), 1500, false, 2000)
        assertEquals(500, record.remainingMl)
    }
    
    @Test
    fun `remainingMl does not go negative`() {
        val record = WaterRecord(LocalDate.now(), 2500, true, 2000)
        assertEquals(0, record.remainingMl)
    }
}
```

### 3.3 Data Layer Tests

**Test targets:** Repository, DataStore

**Characteristics:**
- DataStore mocking required
- Coroutines testing

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
    fun `getTodayRecord - returns record when today's record exists`() = runTest {
        // Given
        val todayRecord = WaterRecord(LocalDate.now(), 500, false, 2000)
        coEvery { dataStore.getTodayRecord() } returns todayRecord
        
        // When
        val result = repository.getTodayRecord()
        
        // Then
        assertEquals(todayRecord, result)
    }
    
    @Test
    fun `getTodayRecord - creates new record when none exists today`() = runTest {
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
    fun `addWater - adds amount to current value`() = runTest {
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
    fun `addWater - isSuccess becomes true when goal is reached`() = runTest {
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
    fun `subtractWater - does not go negative`() = runTest {
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
    fun `resetToday - resets today's record to 0`() = runTest {
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

### 3.4 UI Layer (ViewModel) Tests

**Test targets:** ViewModel

**Characteristics:**
- StateFlow testing (using Turbine)
- Repository mocking

```kotlin
// ui/home/HomeViewModelTest.kt
class HomeViewModelTest {
    
    private val waterRepository: WaterRepository = mockk()
    private val settingsRepository: SettingsRepository = mockk()
    private val analyticsTracker: AnalyticsTracker = mockk(relaxed = true)
    private lateinit var viewModel: HomeViewModel
    
    @BeforeEach
    fun setup() {
        // Default mock setup
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
    fun `initial state loads data after loading`() = runTest {
        viewModel.uiState.test {
            val state = awaitItem()
            assertEquals(0, state.currentMl)
            assertEquals(2000, state.goalMl)
            assertEquals(listOf(100, 200, 300, 500), state.quickButtons)
            cancelAndIgnoreRemainingEvents()
        }
    }
    
    @Test
    fun `AddWater event increases currentMl`() = runTest {
        coEvery { waterRepository.addWater(any()) } just Runs
        coEvery { waterRepository.getTodayRecord() } returnsMany listOf(
            WaterRecord(LocalDate.now(), 0, false, 2000),
            WaterRecord(LocalDate.now(), 100, false, 2000)
        )
        
        viewModel.uiState.test {
            skipItems(1) // initial state
            
            viewModel.onEvent(HomeEvent.AddWater(100))
            
            assertEquals(100, awaitItem().currentMl)
            cancelAndIgnoreRemainingEvents()
        }
        
        coVerify { waterRepository.addWater(100) }
    }
    
    @Test
    fun `Analytics event is sent when goal is achieved`() = runTest {
        coEvery { waterRepository.addWater(any()) } just Runs
        coEvery { waterRepository.getTodayRecord() } returnsMany listOf(
            WaterRecord(LocalDate.now(), 1900, false, 2000),
            WaterRecord(LocalDate.now(), 2100, true, 2000)
        )
        
        viewModel = HomeViewModel(waterRepository, settingsRepository, analyticsTracker)
        
        viewModel.uiState.test {
            skipItems(1)
            
            viewModel.onEvent(HomeEvent.AddWater(200))
            
            awaitItem() // wait for state change
            cancelAndIgnoreRemainingEvents()
        }
        
        verify { analyticsTracker.logGoalAchieved(any(), any(), any()) }
    }
    
    @Test
    fun `SubtractWater event decreases currentMl`() = runTest {
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
    fun `ToggleSubtractMode toggles the mode`() = runTest {
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
    fun `progress calculation is accurate`() = runTest {
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
    fun `remainingCups calculation is accurate`() = runTest {
        coEvery { waterRepository.getTodayRecord() } returns WaterRecord(
            date = LocalDate.now(),
            value = 1500,
            isSuccess = false,
            goal = 2000
        )
        
        viewModel = HomeViewModel(waterRepository, settingsRepository, analyticsTracker)
        
        viewModel.uiState.test {
            val state = awaitItem()
            assertEquals(2, state.remainingCups) // 500ml / 250ml = 2 cups
            cancelAndIgnoreRemainingEvents()
        }
    }
}
```

### 3.5 UI Component Tests (Instrumented)

**Test targets:** Compose UI components

**Location:** `src/androidTest/`

**Characteristics:**
- Uses Compose Testing (JUnit4-based)
- UI interaction testing
- Runs on real device/emulator

> ⚠️ **Note**: Compose UI tests run with JUnit4 in `androidTest`. JUnit5 annotations cannot be used!

```kotlin
// src/androidTest/java/.../ui/components/WaveAnimationTest.kt
import org.junit.Test  // JUnit4!
import org.junit.Rule
import androidx.compose.ui.test.junit4.createComposeRule

class WaveAnimationTest {
    
    @get:Rule
    val composeTestRule = createComposeRule()
    
    @Test
    fun progress_0_shows_no_water() {  // Underscores recommended instead of Korean backticks in JUnit4
        composeTestRule.setContent {
            WaveAnimationView(
                progress = 0f,
                color = Color.Blue
            )
        }
        
        // Canvas internals can be verified with screenshot tests instead
    }
    
    @Test
    fun progress_1_shows_full_water() {
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
    fun quick_button_click_calls_onAddWater() {
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
    fun subtract_mode_shows_minus_in_button_text() {
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
    fun goal_achieved_shows_celebration_message() {
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

### 3.6 Test File Location Summary

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
        │       └── WaterDataStoreTest.kt     ✅ JUnit4 (needs Context)
        └── ui/
            ├── components/
            │   └── WaveAnimationTest.kt      ✅ JUnit4 + ComposeTestRule
            └── home/
                └── HomeScreenTest.kt         ✅ JUnit4 + ComposeTestRule
```

---

## 4. Test Specs by Phase

### Phase 2: Data Layer Tests

#### 2.1 WaterRecord Model

```kotlin
class WaterRecordTest {
    // Creation tests
    @Test fun `id is generated from date string`()
    @Test fun `object is created with default constructor`()
    
    // Computed property tests
    @Test fun `progress is value divided by goal`()
    @Test fun `progress is 0 when goal is 0`()
    @Test fun `progress does not exceed 1`()
    @Test fun `remainingMl is goal minus value`()
    @Test fun `remainingMl does not go negative`()
    @Test fun `remainingCups is remainingMl divided by 250`()
    
    // isSuccess tests
    @Test fun `isSuccess is true when value is at least goal`()
    @Test fun `isSuccess is false when value is less than goal`()
}
```

#### 2.2 UserProfile Model

```kotlin
class UserProfileTest {
    @Test fun `recommendedIntake is weight multiplied by 33`()
    @Test fun `default weight is 65kg`()
    @Test fun `recommended intake is 0 when weight is 0`()
}
```

#### 2.3 WaterRepository

```kotlin
class WaterRepositoryTest {
    // Retrieval
    @Test fun `getTodayRecord - returns record when today's record exists`()
    @Test fun `getTodayRecord - creates new record when none exists today`()
    @Test fun `getAllRecords - returns all records in descending date order`()
    @Test fun `getGoal - returns saved goal`()
    @Test fun `getGoal - returns default 2000 when no goal is saved`()
    
    // Modification
    @Test fun `addWater - adds amount to current value`()
    @Test fun `addWater - isSuccess becomes true when goal is reached`()
    @Test fun `addWater - widget data is synced`()
    @Test fun `subtractWater - subtracts amount from current value`()
    @Test fun `subtractWater - does not go negative`()
    @Test fun `resetToday - resets today's record to 0`()
    @Test fun `updateGoal - changes the goal`()
    @Test fun `updateGoal - also updates today's record goal`()
}
```

### Phase 3: Home Screen Tests

#### 3.1 HomeViewModel

```kotlin
class HomeViewModelTest {
    // Initialization
    @Test fun `initial state loads data after loading`()
    @Test fun `initial quick buttons are loaded from settings`()
    
    // Refresh
    @Test fun `Refresh loads the latest data`()
    
    // AddWater
    @Test fun `AddWater increases currentMl`()
    @Test fun `goalAchieved is true after AddWater reaches goal`()
    @Test fun `Analytics event is sent on AddWater`()
    @Test fun `goalAchieved Analytics event is sent when goal is reached`()
    
    // SubtractWater
    @Test fun `SubtractWater decreases currentMl`()
    @Test fun `SubtractWater does not go negative`()
    @Test fun `Analytics event is sent on SubtractWater`()
    
    // ResetToday
    @Test fun `ResetToday sets currentMl to 0`()
    @Test fun `Analytics event is sent on ResetToday`()
    
    // Mode Toggle
    @Test fun `ToggleSubtractMode toggles the mode`()
    
    // Computed properties
    @Test fun `progress calculation is accurate`()
    @Test fun `remainingMl calculation is accurate`()
    @Test fun `remainingCups calculation is accurate`()
    @Test fun `isGoalAchieved calculation is accurate`()
    
    // Notification Banner
    @Test fun `banner is shown when notification permission is missing`()
    @Test fun `banner does not show again after being dismissed`()
}
```

#### 3.2 WaveAnimation

```kotlin
class WaveAnimationTest {
    @Test fun `no water when progress is 0`()
    @Test fun `water is full when progress is 1`()
    @Test fun `progress is clamped when out of range`()
    @Test fun `animation repeats infinitely`()
}
```

### Phase 4: History Screen Tests

#### 4.1 HistoryViewModel

```kotlin
class HistoryViewModelTest {
    // Data loading
    @Test fun `all records are loaded on ViewDidLoad`()
    @Test fun `successDates are filtered correctly`()
    
    // Date selection
    @Test fun `SelectDate selects the record for that date`()
    @Test fun `Analytics event is sent on SelectDate`()
    @Test fun `selecting a non-existent date results in null`()
    
    // Monthly stats
    @Test fun `monthlySuccessCount calculation is accurate`()
    @Test fun `monthlyTotalDays calculation is accurate`()
}
```

#### 4.2 CustomCalendar

```kotlin
class CustomCalendarTest {
    @Test fun `achieved dates are highlighted`()
    @Test fun `today's date is distinctly shown`()
    @Test fun `selected date is emphasized`()
    @Test fun `clicking the previous month button changes the month`()
    @Test fun `clicking the next month button changes the month`()
    @Test fun `onDateSelected is called when a date is clicked`()
}
```

### Phase 5: Settings Screen Tests

#### 5.1 SettingsViewModel

```kotlin
class SettingsViewModelTest {
    @Test fun `settings values are loaded in initial state`()
    @Test fun `UpdateGoal changes the goal`()
    @Test fun `Analytics event is sent on UpdateGoal`()
    @Test fun `UpdateQuickButtons changes the quick buttons`()
}
```

### Phase 6: Notification System Tests

#### 6.1 NotificationMessages

```kotlin
class NotificationMessagesTest {
    @Test fun `at least 10 messages exist`()
    @Test fun `random call returns a non-null value`()
    @Test fun `all messages are non-empty`()
}
```

#### 6.2 NotificationHelper

```kotlin
class NotificationHelperTest {
    @Test fun `notification permission check is accurate`()
    @Test fun `notification channel is created correctly`()
    @Test fun `notification is created with correct content`()
}
```

### Phase 7: Widget Tests

#### 7.1 AddWaterAction

```kotlin
class AddWaterActionTest {
    @Test fun `Repository addWater is called on onAction`()
    @Test fun `widget is updated after onAction`()
}
```

### Phase 9: Health Connect Tests

#### 9.1 HealthConnectHelper

```kotlin
class HealthConnectHelperTest {
    @Test fun `weight reading works correctly`()
    @Test fun `recommended intake calculation is accurate`()
    @Test fun `water intake record is saved`()
}
```

### Phase 11: Wear OS Tests

#### 11.1 WatchViewModel

```kotlin
class WatchViewModelTest {
    @Test fun `state is updated when data is received from phone`()
    @Test fun `message is sent to phone on AddWater`()
}
```

#### 11.2 DataLayerSync

```kotlin
class DataLayerSyncTest {
    @Test fun `data is sent when syncToWatch is called`()
    @Test fun `callback is called on onDataChanged`()
}
```

---

## 5. Test Utilities

### 5.1 Test Fixtures

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
    
    // Test helper
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

// Usage example
class HomeViewModelTest {
    @get:Rule
    val mainDispatcherRule = MainDispatcherRule()
    
    @Test
    fun `test`() = runTest {
        // ...
    }
}
```

---

## 6. Test Execution Guide

### 6.1 Commands

```bash
# Run all tests
./gradlew test

# Run tests for specific module
./gradlew :app:test
./gradlew :widget:test
./gradlew :wear:test
./gradlew :analytics:test

# Run specific test class
./gradlew :app:test --tests "*.HomeViewModelTest"

# Run specific test method
./gradlew :app:test --tests "*.HomeViewModelTest.AddWater*"

# Re-run failed tests only
./gradlew test --rerun-tasks

# Generate test report
./gradlew test jacocoTestReport

# Coverage report (Kover)
./gradlew koverHtmlReport
```

### 6.2 Coverage Goals

| Layer | Target Coverage |
|-------|----------------|
| Domain (Model, UseCase) | 90%+ |
| Data (Repository) | 80%+ |
| UI (ViewModel) | 80%+ |
| UI (Composable) | 60%+ |
| Service | 70%+ |

### 6.3 CI Test Setup (GitHub Actions)

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

## Appendix

### A. References

- [JUnit 5 User Guide](https://junit.org/junit5/docs/current/user-guide/)
- [Turbine - Flow Testing](https://github.com/cashapp/turbine)
- [MockK - Kotlin Mocking](https://mockk.io/)
- [Compose Testing](https://developer.android.com/jetpack/compose/testing)

### B. Related Documents

- [Project Plan](./ANDROID_PROJECT_PLAN.md)
- [iOS-Android Mapping](./IOS_ANDROID_MAPPING.md)
