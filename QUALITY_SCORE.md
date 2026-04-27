# QUALITY_SCORE.md – DrinkSomeWater
> Code quality scoring criteria (Quality Rubric)

This document defines the standards for evaluating code quality in the DrinkSomeWater iOS project. Both AI agents and developers can use these criteria for PR reviews, refactoring prioritization, and self-assessment when writing new code.

---

## Scoring Scale

| Score | Meaning |
|------|------|
| 5 | Fully follows best practices, no room for improvement |
| 4 | Good, minor improvements possible |
| 3 | Meets basic requirements, major improvements needed |
| 2 | Partially compliant, multiple issues present |
| 1 | Below standard, immediate fixes required |

---

## 1. Code Structure

**Target paths**: `DrinkSomeWater/App/`, `DrinkSomeWater/Features/`, `DrinkSomeWater/Core/`

### Scoring Criteria

| Score | Criteria |
|------|------|
| 5 | Presentation → Domain → Data layers are clearly separated. Each feature in Features/ is organized as an independent module. ViewModel does not depend directly on View. Core/ shared services are abstracted via interfaces |
| 4 | Layer separation is mostly respected. Boundaries are blurry in one or two places |
| 3 | Uses MVVM pattern but layer boundaries are mixed. Domain logic is partially exposed in Views |
| 2 | ViewModel and Model are mixed together. Feature code is scattered without layer distinction |
| 1 | No architecture pattern. All logic is mixed inside Views |

### Key Checkpoints

- Does `DrinkSomeWater/App/DrinkSomeWaterApp.swift` contain only minimal bootstrap code?
- Are each feature folder's contents inside `Features/` separated into View, ViewModel, and Model subfolders?
- Are `Core/` services designed for reuse across all of `Features/`?
- Does the ViewModel avoid directly importing SwiftUI (for pure Domain logic)?

---

## 2. Swift 6 Concurrency

**Target**: All Swift source files

### Scoring Criteria

| Score | Criteria |
|------|------|
| 5 | All types explicitly declare Sendable conformance. @MainActor is used only for UI updates. Structured concurrency via async/await. Zero data race compiler warnings |
| 4 | Mostly Sendable compliant. @MainActor usage appropriate. Minor missing nonisolated annotations |
| 3 | Basic async/await usage but @unchecked Sendable overused or MainActor.run used excessively |
| 2 | No structured concurrency. DispatchQueue mixed in. Many types without Sendable annotation |
| 1 | Data races occurring. Swift 6 strict concurrency disabled as a workaround |

### Key Checkpoints

- Is `@MainActor` correctly applied to ViewModel classes or UI update functions?
- Does shared mutable state using `actor` have the correct isolation domain?
- Does `Task { }` creation account for context inheritance, and is `Task.detached` only used where necessary?
- Is `async let` used for parallel work instead of creating multiple `Task { }` instances?
- Are blocking APIs like `DispatchSemaphore` and `DispatchGroup.wait()` absent from async contexts?

---

## 3. SwiftUI / SwiftData

**Target**: `Features/` View files, `App/` configuration files

### Scoring Criteria

| Score | Criteria |
|------|------|
| 5 | Data fetching handled via `@Query`. `ModelContainer` configured once at the app entry point. View binds to `@Observable` ViewModel with `@State`. SwiftData migration plan considered |
| 4 | Correct usage of @Query and @Observable. ModelContainer configured correctly. Minor duplicate state management |
| 3 | Uses SwiftData but mixes manual fetch with @Query. Legacy @StateObject/@ObservedObject mixed in |
| 2 | ModelContainer created multiple times or configured in the wrong location. @State overused, breaking unidirectional data flow |
| 1 | No SwiftData usage. Model data stored in UserDefaults. View directly accesses persistence |

### Key Checkpoints

- Is `.modelContainer(for:)` configured in only one place inside `DrinkSomeWaterApp.swift`?
- Are `@Model` classes located in the Domain layer (not mixed into View files)?
- Are `@Query` filters/sorting delegated to ViewModel or Use Case rather than handled directly in the View?
- Are `@Observable` and `@State` used with the Swift 5.9+ modern pattern?

---

## 4. WidgetKit Integration

**Target**: Widget Extension target, App Group data sharing code

### Scoring Criteria

| Score | Criteria |
|------|------|
| 5 | `TimelineProvider` returns appropriate refresh policies (`.atEnd`, `.after`) in getTimeline. Data shared with main app via App Group `group.com.feelso.DrinkSomeWater`. Widget previews configured with `PreviewProvider` |
| 4 | TimelineProvider correctly implemented. App Group connected. Refresh policy has slight room for optimization |
| 3 | Basic TimelineProvider implementation. App Group partially used. `.never` refresh policy in use |
| 2 | Widget cannot read main app data. App Group not configured or Bundle ID mismatch |
| 1 | TimelineProvider not implemented or returning hardcoded data |

### Key Checkpoints

- Is the Widget Extension's Bundle ID in the form `com.feelso.DrinkSomeWater.widget`, associated with the main app?
- Is App Group `group.com.feelso.DrinkSomeWater` added to the Capabilities of both the main app and widget extension?
- Is water intake data shared via `UserDefaults(suiteName:)` or a shared file container?
- Are timeline entries generated at meaningful time intervals (e.g., every hour)?

---

## 5. HealthKit Integration

**Target**: HealthKit-related service files (`Core/` or `Features/`)

### Scoring Criteria

| Score | Criteria |
|------|------|
| 5 | Calls `isHealthDataAvailable()` before requesting authorization. Correct use of `HKQuantityType.quantityType(forIdentifier: .dietaryWater)`. Errors and permission denials handled in separate branches. Single shared `HKHealthStore` instance |
| 4 | Authorization flow correct. HKQuantityType used correctly. Error handling mostly implemented |
| 3 | Basic read/write functionality. Permission denial handling insufficient. HKHealthStore created multiple times |
| 2 | Force unwrapping without error handling. Data access attempted without checking authorization |
| 1 | No HealthKit authorization request. Usage description missing from `Info.plist` |

### Key Checkpoints

- Are `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` present in `Info.plist`?
- Does `HKHealthStore.requestAuthorization` handle both errors and success?
- Does HealthKit writing use `HKQuantitySample` with the correct unit (`HKUnit.literUnit(with: .milli)`)?
- Are HealthKit operations handled asynchronously so they don't block the main thread?

---

## 6. Error Handling

**Target**: All source files

### Scoring Criteria

| Score | Criteria |
|------|------|
| 5 | Domain-specific errors defined as custom `Error` types. Retry or fallback logic for recoverable errors. Meaningful messages shown to users. No overuse of `try?` |
| 4 | do-catch pattern applied in most places. Error messages are user-friendly. Minor `try?` usage |
| 3 | Basic do-catch usage. Errors only printed to console with no user feedback |
| 2 | Multiple `try!` force attempts. Errors silently ignored (`try?` throughout) |
| 1 | No error handling. Crash cause untraceable when they occur |

### Key Checkpoints

- Is `try!` absent from the codebase (excluding test code)?
- Are network or disk I/O errors connected to user notifications or logging?
- Is SwiftData context `save()` protected with `try-catch`?
- Is there a recovery flow (e.g., directing users to Settings) when HealthKit authorization fails?

---

## 7. Testing

**Target**: `DrinkSomeWaterTests/`, `DrinkSomeWaterUITests/`, Widget previews

### Scoring Criteria

| Score | Criteria |
|------|------|
| 5 | Domain logic unit test coverage above 80%. UI tests cover core user flows (adding water, checking history). Widget `#Preview` macro provides previews for all sizes |
| 4 | Most unit tests exist. Some core UI tests implemented. Some widget previews |
| 3 | Basic unit tests exist but coverage is low. No UI tests |
| 2 | Test files exist but only dummy tests with no real validation |
| 1 | No tests |

### Key Checkpoints

- Are there unit tests for the ViewModel's core calculation logic (e.g., daily goal achievement rate)?
- Is a test environment using an in-memory SwiftData `ModelContainer` configured?
- Do UI tests reproduce real device/simulator scenarios?
- Does the Widget Entry provide `#Preview` macros for both small and medium sizes?

---

## 8. Naming & Documentation

**Target**: All source files

### Scoring Criteria

| Score | Criteria |
|------|------|
| 5 | Fully follows Swift API Design Guidelines. `///` doc comments on all public APIs. Function names form natural English sentences at call sites. Clear names without abbreviations |
| 4 | Mostly follows guidelines. Some doc comments missing |
| 3 | Names are generally clear but inconsistent. Comments describe what code does rather than why |
| 2 | Abbreviations overused (`tmp`, `mgr`). Single-character variables. Many unclear names |
| 1 | No naming standard. Hungarian notation or meaningless names |

### Key Checkpoints

- Do functions start with verbs (`fetch`, `calculate`, `update`)?
- Do Bool properties use `is`, `has`, `should` prefixes?
- Are `typealias` or nested types used to improve readability?
- Are code sections separated with `MARK: -` comments?

---

## Overall Score

| Item | Weight | Score (1-5) | Weighted Score |
|------|--------|-----------|---------|
| Code Structure | 20% | | |
| Swift 6 Concurrency | 20% | | |
| SwiftUI / SwiftData | 15% | | |
| WidgetKit Integration | 10% | | |
| HealthKit Integration | 10% | | |
| Error Handling | 10% | | |
| Testing | 10% | | |
| Naming & Documentation | 5% | | |
| **Total** | **100%** | | **/5.0** |

### Grade Criteria

| Total | Grade | Meaning |
|------|------|------|
| 4.5 or above | A | Release ready |
| 3.5 or above | B | Shippable, improvements recommended |
| 2.5 or above | C | Core features work but refactoring needed |
| 1.5 or above | D | Major defects exist, must fix before release |
| Below 1.5 | F | Structural rewrite required |

---

## Self-Verification Checklist

Verify all items below before submitting a PR or requesting a review. Mark each item as pass (O) or fail (X).

### Architecture

- [ ] `DrinkSomeWater/App/DrinkSomeWaterApp.swift` contains no business logic
- [ ] Each feature folder inside `Features/` separates View, ViewModel, and Model
- [ ] `Core/` services are abstracted via protocols or clear interfaces
- [ ] ViewModel does not directly import SwiftUI (Combine or pure Swift only)

### Swift 6 Concurrency

- [ ] `@MainActor` is applied to ViewModels or functions that handle UI updates
- [ ] Shared mutable state is protected with `actor`
- [ ] Context inheritance is considered when creating `Task { }`
- [ ] `DispatchSemaphore` and `DispatchGroup.wait()` are not used in async code
- [ ] Zero Swift 6 strict concurrency warnings

### SwiftUI / SwiftData

- [ ] `ModelContainer` is configured only inside `DrinkSomeWaterApp.swift`
- [ ] Bundle ID `com.feelso.DrinkSomeWater` matches the target configuration
- [ ] SwiftData data is fetched with `@Query` (avoid manual fetch)
- [ ] `@Observable` pattern is used and `@ObservableObject` is not used in new code

### WidgetKit

- [ ] App Group `group.com.feelso.DrinkSomeWater` is configured in both the main app and widget extension
- [ ] `TimelineProvider.getTimeline` returns `.after` or `.atEnd` policy
- [ ] Widget reads the latest water intake data through App Group
- [ ] At least one widget `#Preview` exists

### HealthKit

- [ ] `Info.plist` contains `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription`
- [ ] `HKHealthStore.isHealthDataAvailable()` is checked before requesting authorization
- [ ] Users are guided to Settings when HealthKit authorization is denied
- [ ] `HKHealthStore` instance is managed as a singleton or shared service

### Error Handling

- [ ] `try!` is absent from production code
- [ ] SwiftData `context.save()` is wrapped in `do-catch`
- [ ] Errors are shown to users with meaningful messages
- [ ] HealthKit errors are reflected in the UI, not just printed to console

### Testing & Documentation

- [ ] Unit tests exist for core Domain logic
- [ ] `///` doc comments exist on public APIs
- [ ] Function names read naturally at call sites
- [ ] Bool properties start with `is`, `has`, or `should`

---

## Improvement Priority Guide

Fix items with the lowest scores first. When tied, follow this order:

1. Swift 6 Concurrency (directly affects app stability)
2. Error Handling (user experience and debugging)
3. Code Structure (long-term maintainability)
4. SwiftData / WidgetKit / HealthKit (feature-level quality)
5. Testing (regression prevention)
6. Naming & Documentation (collaboration efficiency)

---

*Update this document whenever the project structure or tech stack changes.*
