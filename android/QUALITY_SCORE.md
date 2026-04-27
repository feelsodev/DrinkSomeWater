# QUALITY_SCORE.md – 벌컥벌컥 (Gulp) Android

> Code quality scoring criteria for Android/Wear OS

---

## Overview

This document defines the scoring criteria for evaluating code quality in the 벌컥벌컥 (Gulp) Android project consistently. Each item is scored on a 1–5 scale and converted to a 100-point total using weighted values.

---

## Scoring Categories

### 1. Code Structure (Weight: 20%)

Evaluates MVI pattern compliance, multi-module dependency direction, and clean architecture layer separation.

| Score | Criteria |
|-------|----------|
| 5 | MVI pattern perfectly applied. Unidirectional `:app` → `:core` dependency maintained. domain/data/ui layers clearly separated. `:widget`, `:wear`, `:analytics` all reference only `:core` |
| 4 | MVI structure mostly followed. Minor dependency direction exceptions exist but have no practical impact |
| 3 | MVI partially applied. State management mixed in some views. Module dependencies unclear |
| 2 | MVI form adopted only, no actual unidirectional flow. Multiple module boundary violations |
| 1 | No pattern. Layers mixed. Spaghetti dependencies |

**Project standards:**
- `core/domain/` — Business logic, no external dependencies
- `core/data/` — Repository implementations, DataStore, Health Connect
- `app/ui/` — Composable screens, ViewModel
- `settings.gradle.kts` — Module registration and version catalog

---

### 2. Kotlin Idioms (Weight: 15%)

Evaluates Kotlin 2.0 feature usage, null safety, and type system expressiveness.

| Score | Criteria |
|-------|----------|
| 5 | Kotlin 2.0 features actively used. `sealed interface` + `when` fully handled. `data class` copy pattern consistent. `?.let`, `?: run` etc. used idiomatically for null handling. `object` / `companion object` used appropriately |
| 4 | Mostly idiomatic Kotlin. Occasional Java-style patterns mixed in |
| 3 | `sealed class` used but `else` branches overused. Nullable handling lacks consistency |
| 2 | `!!` operator used frequently. Unsafe type casting. `if-else` chains replacing `when` |
| 1 | No null handling. Java-style throughout. Type safety ignored |

---

### 3. Jetpack Compose (Weight: 15%)

Evaluates Composable design principles, state hoisting, and recomposition optimization.

| Score | Criteria |
|-------|----------|
| 5 | State hoisting applied consistently. `remember` / `derivedStateOf` used in the right places. No unnecessary recomposition. Design centered on stateless Composables. `key()` used for list optimization |
| 4 | Hoisting mostly applied. Some micro-optimization opportunities exist but don't affect performance |
| 3 | Multiple cases where state is managed directly inside Composables. `derivedStateOf` not used |
| 2 | ViewModel directly injected excessively. Recomposition scope too broad. `LaunchedEffect` misused |
| 1 | No state management principles. Side effects scattered throughout Composables |

---

### 4. Hilt DI (Weight: 10%)

Evaluates module structure clarity, scope appropriateness, and testability.

| Score | Criteria |
|-------|----------|
| 5 | `@Singleton` / `@ViewModelScoped` / `@ActivityScoped` applied correctly per role. Module separation clear (NetworkModule, DataModule, DomainModule, etc.). Replaceable with `@TestInstallIn` during testing |
| 4 | Scopes mostly appropriate. A few modules are combined but manageable |
| 3 | `@Singleton` overused. Module boundaries unclear |
| 2 | DI structure exists but manual instantiation mixed in. Test isolation not possible |
| 1 | Hilt form only, no actual dependency injection principles applied |

---

### 5. Async Handling (Weight: 15%)

Evaluates Coroutines + Flow usage, error handling consistency, and lifecycle safety.

| Score | Criteria |
|-------|----------|
| 5 | `StateFlow` / `SharedFlow` differentiated by purpose. Coroutines safely managed within `viewModelScope`. Errors propagated via `Result<T>` or sealed class. `catch` / `onEach` chains consistent. `Dispatchers` explicitly specified |
| 4 | Flow usage appropriate. Some error handling missing but low crash risk |
| 3 | `StateFlow` used but error state not defined. `GlobalScope` used occasionally |
| 2 | Callbacks and Flow mixed. Lifecycle leak possible. Exception propagation unclear |
| 1 | `runBlocking` overused. Errors ignored. Main thread blocking |

---

### 6. Glance Widget (Weight: 10%)

Evaluates `GlanceAppWidget` structure, data refresh strategy, and `ActionCallback` security.

| Score | Criteria |
|-------|----------|
| 5 | `GlanceAppWidget` + `GlanceAppWidgetReceiver` clearly separated. `updateAll` / `WorkManager`-based refresh strategy. No sensitive data exposed in `ActionCallback`. Glance component reusability considered |
| 4 | Widget structure appropriate. Refresh interval reasonable. Minor optimization opportunities |
| 3 | Data refresh is inefficient (excessive polling, etc.). ActionCallback validation lacking |
| 2 | Widget accesses DB directly. No empty state handling on error |
| 1 | Glance API misused. No widget refresh strategy |

---

### 7. Wear OS (Weight: 10%)

Evaluates Tile/Complication implementation quality, DataLayer sync, and Wear Compose usage.

| Score | Criteria |
|-------|----------|
| 5 | `TileService` + `SuspendingTileService` used appropriately. Phone ↔ watch sync via `DataClient` / `MessageClient` clearly defined. Wear Compose components (ScalingLazyColumn, etc.) used correctly. Battery efficiency considered |
| 4 | DataLayer sync works correctly. Wear Compose mostly correct. Some inefficiencies exist |
| 3 | DataLayer used but sync timing unclear. Phone UI components reused directly in wear |
| 2 | DataLayer ignored, independent data management. No Wear optimization at all |
| 1 | Wear OS characteristics ignored. Essentially a direct port of the phone app |

---

### 8. Testing (Weight: 15%)

Evaluates test coverage, TDD principle compliance, and test structure quality.

| Score | Criteria |
|-------|----------|
| 5 | JUnit5 + MockK + Turbine combination used consistently. Coverage 80%+ per module. UseCase / Repository unit tests complete. TDD cycle evidence (failing tests first). Integration tests isolated with Fake implementations |
| 4 | Core logic tests complete. Coverage 60–79%. Some Fake replaced by excessive Mock usage |
| 3 | Tests exist but only happy path verified. Error/edge cases missing |
| 2 | Test code exists but many tests have no real verification |
| 1 | No tests or tests don't compile |

---

## Weights and Total Score Calculation

| Category | Weight | Max Score |
|----------|--------|-----------|
| Code Structure | 20% | 20 pts |
| Kotlin Idioms | 15% | 15 pts |
| Jetpack Compose | 15% | 15 pts |
| Hilt DI | 10% | 10 pts |
| Async Handling | 15% | 15 pts |
| Glance Widget | 10% | 10 pts |
| Wear OS | 10% | 10 pts |
| Testing | 15% | 15 pts |
| **Total** | **100%** | **100 pts** |

**Conversion formula:** `Total = Σ (item score / 5) × weight × 100`

### Grade Criteria

| Grade | Score | Meaning |
|-------|-------|---------|
| S | 90–100 | Release ready. Benchmark level |
| A | 80–89 | Production quality. Minor improvements possible |
| B | 65–79 | Works but refactoring needed |
| C | 50–64 | Technical debt accumulating. Gradual improvement needed |
| D | Below 50 | Structural rework required |

---

## Self-Check Checklist

### Code Structure

- [ ] `:core` module does not depend on `:app`
- [ ] No Android framework imports in `core/domain/`
- [ ] ViewModel accesses Repository through UseCase, not directly
- [ ] All modules registered in `settings.gradle.kts`
- [ ] No business logic in `app/ui/`

### Kotlin Idioms

- [ ] No `!!` operator usage (or minimized with comments)
- [ ] No `else` branch in `sealed interface` + `when`
- [ ] Immutable state updated using `data class` `copy()`
- [ ] Complex lambda types named with `typealias`
- [ ] `inline` / `reified` used appropriately

### Jetpack Compose

- [ ] Composable functions don't own state directly (stateless principle)
- [ ] `remember { derivedStateOf { ... } }` used for computed properties
- [ ] Stable `key` provided for list items
- [ ] `@Stable` / `@Immutable` annotations applied where needed
- [ ] Preview exists for each Composable

### Hilt DI

- [ ] Only ViewModels with `@HiltViewModel` are injected via Hilt
- [ ] `@Singleton` used only for truly app-wide single instances
- [ ] Test modules (`@TestInstallIn`) are prepared
- [ ] Module classes are separated by role

### Async Handling

- [ ] No `GlobalScope` usage
- [ ] `StateFlow` initial value is appropriate
- [ ] Exception handling inside `viewModelScope.launch` (`try-catch` or `CoroutineExceptionHandler`)
- [ ] Flow errors handled with the `catch` operator
- [ ] `Dispatchers.Main.immediate` considered instead of `Dispatchers.Main`

### Glance Widget

- [ ] Widget UI refresh triggered by WorkManager or `updateAll()`
- [ ] Widget does not query DB directly
- [ ] `ActionCallback` does not expose user identification data

### Wear OS

- [ ] DataLayer message/data paths defined as constants
- [ ] Phone app Composables not reused in wear
- [ ] Refresh strategy minimizes battery impact

### Testing

- [ ] Unit tests exist for all UseCases
- [ ] Repository tests are isolated with Fake DataSource
- [ ] Flow emission order verified with `Turbine`
- [ ] Failure cases (errors, empty state) are tested
- [ ] Test names follow `given_when_then` or descriptive format

---

*This document is used as a code review and PR checklist. Checklist compliance takes priority over the numeric score.*
