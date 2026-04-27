# QUALITY_SCORE.md – 벌컥벌컥 (Gulp) iOS
> iOS/watchOS code quality scoring criteria

---

## Scoring System

| Grade | Score | Meaning |
|-------|-------|---------|
| S | 90~100 | Production-ready, exemplary practice |
| A | 75~89 | Good, minor room for improvement |
| B | 60~74 | Functional but needs refactoring |
| C | 40~59 | Significant tech debt, immediate improvement needed |
| D | 0~39 | Structural issues, consider redesign |

---

## 1. Code Structure (weight: 20 points)

**Reference paths**: `Sources/Stores/`, `Sources/Services/`, `Sources/Views/`, `Sources/Data/`

| Score | Criteria |
|-------|----------|
| 5 | Full adherence to @Observable Store Pattern. Views reference only Stores, Stores call Services, Services communicate only with the Data layer. Sources/ subfolder rules followed 100%. |
| 4 | Layers are mostly separated, but 1-2 places where Views directly reference Services or Data access code is mixed into Stores. |
| 3 | Layering concept exists but responsibility boundaries are unclear. UI logic mixed into Stores, or business rules missing from Services. |
| 2 | Folder structure exists but no meaningful layer separation. God Object pattern observed. |
| 1 | All logic concentrated in a single file or single type. |

**Detail checks**
- Is `@Observable` or `ObservationIgnored` used correctly?
- Are Stores declared as `@Observable class`?
- Do Views avoid calling URLSession/HKHealthStore directly?
- Are `Sources/` subfolders organized into `Stores/`, `Services/`, `Views/`, `Data/`, `Models/`?

---

## 2. Swift 6 Concurrency (weight: 20 points)

| Score | Criteria |
|-------|----------|
| 5 | All shared mutable state is explicitly marked with `@MainActor` or `actor`. Full `Sendable` conformance with zero data race compiler warnings. No `@unchecked Sendable` usage, or if unavoidable, a comment explaining the rationale is present. |
| 4 | 1-3 compiler warnings, but no runtime data race risk. 1-2 uses of `@unchecked Sendable` with clear justification. |
| 3 | Uses `async/await` but `DispatchQueue` mixing remains. Partial `Sendable` conformance. |
| 2 | Swift Concurrency adopted but `Task.detached` overused or unnecessary `MainActor.run` nesting occurs. |
| 1 | GCD/callback-based code predominates with little Swift Concurrency applied. |

**Detail checks**
- Do Store property mutations happen in `@MainActor` context?
- Are parallel operations structured with `async let` or `TaskGroup`?
- When using `actor`, is it never accessed externally without `await`?
- Is the count of `@unchecked Sendable` three or fewer?

---

## 3. SwiftUI / UIKit Interop (weight: 15 points)

| Score | Criteria |
|-------|----------|
| 5 | SwiftUI is the primary UI layer. UIKit is confined to Settings/Onboarding screens with correct `UIViewControllerRepresentable` / `UIViewRepresentable` implementations. Delegates handled through the Coordinator pattern. |
| 4 | SwiftUI-first, but UIKit usage is slightly broader than guidelines. No memory leak risk in Representable implementations. |
| 3 | SwiftUI and UIKit mixed with no clear criteria. `updateUIViewController` implementation is incomplete. |
| 2 | UIKit outweighs SwiftUI. `UIHostingController` abused directly without Representable. |
| 1 | Entirely UIKit-based or no clear boundary between SwiftUI and UIKit. |

**Detail checks**
- Is the Settings screen wrapped via `UIViewControllerRepresentable` (or is there a plan to rewrite it in SwiftUI)?
- Are delegates handled through `UIViewControllerRepresentable.makeCoordinator()`?
- Is `@State`/`@Binding` to UIKit state sync done correctly in `updateUIViewController`?

---

## 4. WidgetKit (weight: 10 points)

| Score | Criteria |
|-------|----------|
| 5 | `TimelineProvider` correctly implemented, interactions via `AppIntent` work. App data shared through `WidgetDataManager`, and layouts are individually optimized for Small/Medium/Large/Accessory sizes. |
| 4 | Main sizes supported, but Accessory (lock screen) widget is missing or `TimelineReloadPolicy` is not optimized. |
| 3 | Basic `TimelineProvider` implemented, but `getSnapshot` and `getTimeline` data are inconsistent or show stale data. |
| 2 | Only a single size supported with no AppIntent. Data sharing implemented without App Group. |
| 1 | Widget builds but fails to show real data, or always shows a placeholder. |

**Detail checks**
- Does the App Group identifier match between the app and widget extension?
- Does `WidgetDataManager` share data via `UserDefaults(suiteName:)`?
- Is `TimelineReloadPolicy.atEnd` or `.after(_:)` set appropriately?
- Is text unclipped in `.systemSmall`?

---

## 5. HealthKit (weight: 10 points)

| Score | Criteria |
|-------|----------|
| 5 | Permission is requested at first use of the feature. `HKQuantityType.quantityType(forIdentifier: .dietaryWater)` is used correctly, with graceful degradation on permission denial. Background delivery is properly configured when needed. |
| 4 | Permission flow is correct, but guidance messaging is insufficient when permission is denied. |
| 3 | HKHealthStore is accessed in some places without checking permissions. No exception handling for simulator or devices that don't support HealthKit. |
| 2 | No `HKHealthStore.isHealthDataAvailable()` check. Errors are silently ignored or cause crashes. |
| 1 | HealthKit integration is non-functional or data is accessed without permission. |

**Detail checks**
- Is `HKHealthStore.isHealthDataAvailable()` called before accessing HealthKit?
- Are `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` present in Info.plist (or Project.swift)?
- Does the app function without crashing when permission is denied?
- When using `HKObserverQuery`, is background delivery registration paired correctly?

---

## 6. watchOS (weight: 10 points)

| Score | Criteria |
|-------|----------|
| 5 | WatchConnectivity works reliably and the app is usable independently without iPhone. Complications are implemented with correct `CLKComplicationDataSource` or WidgetKit-based complications. UI is optimized for the small screen. |
| 4 | WatchConnectivity works at a basic level, but offline scenario handling is insufficient. Complications support only 1-2 families. |
| 3 | The Watch app doesn't function without an iPhone connection. No error handling for WCSession activation failures. |
| 2 | The Watch app is a simple copy of the iOS app's UI. WatchConnectivity is absent or one-directional. |
| 1 | The Watch app builds but core features don't work. |

**Detail checks**
- Is `WCSession.default.activateSession()` called at app startup?
- Is the `session(_:didReceiveMessage:)` delegate implemented?
- Does the Watch app have its own local storage (`UserDefaults` or CoreData)?
- Does the complication timeline provide at least a full day's worth of entries?

---

## 7. Testing (weight: 10 points)

| Score | Criteria |
|-------|----------|
| 5 | Store/Service unit test coverage 80% or above. Snapshot tests cover key views. Tests run automatically in CI. |
| 4 | Coverage 60-79%. Snapshot tests exist but cover only some views. |
| 3 | Coverage 40-59%. Only Store tests exist with no Service/View tests. |
| 2 | Coverage 20-39%, or tests only compile without real assertions. |
| 1 | Few or no tests at all. |

**Detail checks**
- Are there test files per Store and Service under `DrinkSomeWaterTests/`?
- Are there snapshot tests in `DrinkSomeWaterSnapshotTests/`?
- Are external dependencies (HealthKit, Network) isolated using Mocks/Stubs?
- Is async code validated with `XCTestExpectation` or `async/await` tests?

---

## 8. Naming / Documentation (weight: 5 points)

| Score | Criteria |
|-------|----------|
| 5 | Full adherence to Swift API Design Guidelines. Public APIs have `///` doc comments. Complex logic has inline comments. No abbreviations; names clearly communicate intent. |
| 4 | Mostly follows guidelines, but some parameter labels are awkward or some public APIs lack comments. |
| 3 | Inconsistent naming. Vague names like `data`, `info`, `manager2` are present. |
| 2 | Many abbreviations, intent is hard to read. Almost no comments. |
| 1 | No naming conventions. Temporary variable names remain in the codebase. |

**Detail checks**
- Do function names start with a verb (e.g. `fetchWaterIntake()`, `scheduleNotification()`)?
- Do `Bool` properties start with `is`, `has`, or `should`?
- Are `class` / `struct` names nouns?
- Are `TODO:` / `FIXME:` comments written with an issue number?

---

## Weighted Total Score Calculation

| Item | Weight | Max | Formula |
|------|--------|-----|---------|
| 1. Code Structure | ×4 | 20 | score × 4 |
| 2. Swift 6 Concurrency | ×4 | 20 | score × 4 |
| 3. SwiftUI / UIKit Interop | ×3 | 15 | score × 3 |
| 4. WidgetKit | ×2 | 10 | score × 2 |
| 5. HealthKit | ×2 | 10 | score × 2 |
| 6. watchOS | ×2 | 10 | score × 2 |
| 7. Testing | ×2 | 10 | score × 2 |
| 8. Naming/Documentation | ×1 | 5 | score × 1 |
| **Total** | | **100** | |

---

## Self-Check Checklist

Review all items below before a code review. Every item must PASS before opening a PR.

### Structure / Architecture

- [ ] View files don't call `URLSession`, `HKHealthStore`, or `UserDefaults` directly
- [ ] Stores are declared as `@Observable class`
- [ ] `Sources/Stores/`, `Sources/Services/`, `Sources/Views/` folder conventions are followed
- [ ] New files are placed in the correct folder

### Swift 6 Concurrency

- [ ] Zero data race warnings in Swift 6 compiler mode
- [ ] A comment explaining the rationale is present whenever `@unchecked Sendable` is used
- [ ] `@MainActor` or `await MainActor.run` is used instead of `DispatchQueue.main.async`
- [ ] `Task.detached` is not used, or only when unavoidable

### WidgetKit

- [ ] App Group identifier is identical across app/widget/Watch
- [ ] Data is shared through `WidgetDataManager`
- [ ] Widget previews display correctly at all supported sizes

### HealthKit

- [ ] `HKHealthStore.isHealthDataAvailable()` is checked before access
- [ ] The app functions normally when permission is denied
- [ ] HealthKit data is not sent to external servers

### Testing

- [ ] Tests are written for any modified Store/Service
- [ ] Snapshot tests are added for new views
- [ ] All tests pass locally

### Naming / Documentation

- [ ] Public functions/properties have `///` comments
- [ ] No vague names (`temp`, `data2`, `flag`)
- [ ] `TODO:`/`FIXME:` entries include an issue number

---

*Last updated: 2026-04-27*
