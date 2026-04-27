# SECURITY.md – DrinkSomeWater
> Security guidelines and checklist

This document defines the security principles and practices for the DrinkSomeWater iOS app (`com.feelso.DrinkSomeWater`). It contains specific rules tailored to the project's use of Swift 6, SwiftUI, SwiftData, WidgetKit, and HealthKit.

---

## Table of Contents

1. [HealthKit Privacy](#1-healthkit-privacy)
2. [SwiftData Data Security](#2-swiftdata-data-security)
3. [App Group Boundaries](#3-app-group-boundaries)
4. [Notification Security](#4-notification-security)
5. [Swift 6 Concurrency Safety](#5-swift-6-concurrency-safety)
6. [Dependency Policy](#6-dependency-policy)
7. [General Security Rules](#7-general-security-rules)
8. [Security Checklist](#8-security-checklist)

---

## 1. HealthKit Privacy

### Permission Scope

DrinkSomeWater accesses **only a single data type** from HealthKit: water intake.

| Data Type | Identifier | Direction |
|------------|--------|------|
| Water Intake | `HKQuantityType.quantityType(forIdentifier: .dietaryWater)` | Read + Write |

Authorization for any other HealthKit categories (heart rate, sleep, weight, etc.) must never be requested.

### Required Info.plist Keys

```xml
<key>NSHealthShareUsageDescription</key>
<string>Reads your water intake records from the Health app to display progress toward your hydration goal.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>Saves your logged water intake to the Health app.</string>
```

Both keys must be present, and the descriptions must clearly state the actual purpose. Vague or overly broad wording can result in App Store rejection.

### When to Request Authorization

- Do not request on app launch.
- Request when the user first attempts to use the HealthKit integration feature.
- Show a UI explaining why the permission is needed before the authorization request.

```swift
// Correct: request authorization in response to user action
func requestHealthKitPermission() async throws {
    let types: Set = [
        HKQuantityType(.dietaryWater)
    ]
    try await healthStore.requestAuthorization(toShare: types, read: types)
}
```

### Data Isolation Principles

- Do not send data read from HealthKit to external servers.
- Do not store HealthKit data in locations accessible outside the app.
- Do not include HealthKit values in logs, crash reports, or analytics events.

### Handling Permission Denial

The app must function normally when authorization is denied or revoked.

- Water intake tracking must work using only internal app records, without HealthKit.
- Clearly communicate the denied permission state in the UI and provide an option to direct users to the Settings app.
- Never call HealthKit APIs or crash when authorization is absent.

---

## 2. SwiftData Data Security

### ModelContainer Configuration

`ModelContainer` stores data at the default path within the app sandbox. Confirm the following when configuring:

```swift
// Production container: persistent storage
let container = try ModelContainer(
    for: WaterIntake.self, DailyGoal.self,
    configurations: ModelConfiguration(isStoredInMemoryOnly: false)
)
```

- `isStoredInMemoryOnly: true` is only for test environments. Take care that it doesn't leak into production builds.

### Prohibited Data in Storage

Do not store the following in SwiftData models:

- Personally identifiable information (name, email, phone number)
- Location data
- Device unique identifiers
- Raw data read from HealthKit (keep separate from internal app records)

Store only the data required for app functionality: water intake amounts, goal settings, notification times, etc.

### Migration Integrity

Explicitly define a migration plan for any SwiftData schema changes.

```swift
// Explicit schema version management
let schema = Schema([WaterIntake.self, DailyGoal.self], version: Schema.Version(2, 0, 0))
```

- Write tests to verify that existing data is not lost or corrupted during migration.
- If migration fails, the app must safely recover to its previous state.

### iCloud Backup Policy

| Item | Setting | Reason |
|------|------|------|
| SwiftData store | Included in backup (default) | Protect user data |
| Temporary cache | `isExcludedFromBackup = true` | Prevent unnecessary backup size |
| Sensitive intermediate files | `isExcludedFromBackup = true` | Prevent leakage via backup |

Explicitly set backup exclusion for temporary files and regenerable caches.

```swift
var resourceValues = URLResourceValues()
resourceValues.isExcludedFromBackup = true
try cacheURL.setResourceValues(resourceValues)
```

---

## 3. App Group Boundaries

### Shared Container Identifiers

| Target | Identifier |
|------|--------|
| App Group | `group.com.feelso.DrinkSomeWater` |
| Main App Bundle ID | `com.feelso.DrinkSomeWater` |
| Widget Bundle ID | `com.feelso.DrinkSomeWater.widget` |

### Limiting the Shared Scope

The App Group container is accessible to both the main app and the widget. Minimizing shared data is the guiding principle.

Data accessible from the widget:

| Data | Key | Type |
|--------|-----|------|
| Today's intake | `todayIntake` | `Double` |
| Daily goal | `dailyGoal` | `Double` |
| Last updated time | `lastUpdated` | `Date` |

Data not needed by the widget must not be stored in App Group UserDefaults. Main app-only settings should use standard `UserDefaults.standard`.

### UserDefaults(suiteName:) Usage Principles

```swift
// Shared UserDefaults: only minimum data needed by the widget
let sharedDefaults = UserDefaults(suiteName: "group.com.feelso.DrinkSomeWater")

// Main app-only settings: use standard UserDefaults
let appDefaults = UserDefaults.standard
```

- Do not store personally identifiable information or health metric records in App Group UserDefaults.
- Define key names as constants before storing to prevent data leakage from typos.

```swift
enum SharedDefaultsKey {
    static let todayIntake = "todayIntake"
    static let dailyGoal = "dailyGoal"
    static let lastUpdated = "lastUpdated"
}
```

### Widget Data Access Boundaries

The widget extension consumes App Group data in read-only mode. The widget must not perform write operations directly to the SwiftData `ModelContainer`. All data mutations must happen through the main app.

---

## 4. Notification Security

### Authorization Request Flow

```swift
let center = UNUserNotificationCenter.current()
let options: UNAuthorizationOptions = [.alert, .sound, .badge]
let granted = try await center.requestAuthorization(options: options)
```

- Request notification authorization when the user first activates the notification feature.
- Do not request automatically on app launch.
- When authorization is denied, the app's core functionality (water intake logging) must still work.

### Notification Payload Rules

Content allowed and prohibited in local notification payloads:

| Allowed | Prohibited |
|------|------|
| Generic hydration reminder text | Today's intake values |
| Goal achievement encouragement | Accumulated health data |
| Time-based notification text | Personally identifiable information |

```swift
// Correct
content.title = "Time to drink some water"
content.body = "Have a glass of water to reach your daily goal."

// Incorrect (prohibited)
content.body = "You've had \(intake)ml today. \(remaining)ml to go."
```

Notifications serve only as simple reminders. Guide users to open the app to see specific health metrics.

### Notification Identifier Management

Do not include user data in notification identifiers.

```swift
// Correct
let identifier = "water.reminder.morning"

// Incorrect (prohibited)
let identifier = "reminder.\(userId).\(intakeAmount)"
```

---

## 5. Swift 6 Concurrency Safety

### Sendable Conformance

Enable Swift 6 strict concurrency to detect data races at compile time.

```swift
// Correct: value types are automatically Sendable
struct WaterEntry: Sendable {
    let amount: Double
    let timestamp: Date
}
```

- All model types must explicitly conform to `Sendable` or meet the conditions for automatic synthesis.
- Minimize the use of `@unchecked Sendable`. When unavoidable, always document the reason with a comment.

```swift
// Must state the reason when used
// REASON: Internal synchronization guaranteed by NSLock. Automatic Sendable synthesis not possible (NSObject subclass)
final class SomeCache: @unchecked Sendable {
    private let lock = NSLock()
    // ...
}
```

### Protecting UI State with @MainActor

All UI-related state must be protected with `@MainActor`.

```swift
@MainActor
@Observable
final class WaterViewModel {
    var todayIntake: Double = 0
    var dailyGoal: Double = 2000
    var entries: [WaterEntry] = []
}
```

- Apply `@MainActor` to the entire ViewModel class to prevent missing annotations on individual properties.
- Avoid overusing `MainActor.run { }` blocks. Replace with type-level annotations instead.

### Protecting Shared Resources with actor

Protect shared resources accessed concurrently by multiple tasks using `actor`.

```swift
actor HealthKitManager {
    private let healthStore = HKHealthStore()
    
    func save(_ sample: HKQuantitySample) async throws {
        try await healthStore.save(sample)
    }
}
```

- Use a single `HealthKitManager` instance throughout the app.
- Do not perform UI updates directly inside an actor. Return results and handle them in a `@MainActor` context.

### Structured Concurrency First

```swift
// Preferred: structured concurrency
async let intake = fetchTodayIntake()
async let goal = fetchDailyGoal()
let (todayIntake, dailyGoal) = try await (intake, goal)

// Avoid: unstructured Task proliferation
Task { await fetchTodayIntake() }
Task { await fetchDailyGoal() }
```

Unstructured `Task { }` makes lifecycle management difficult. Prefer `async let`, `TaskGroup`, and the `.task` view modifier.

---

## 6. Dependency Policy

### Apple 1st-Party Frameworks Only

DrinkSomeWater uses no external dependencies. Frameworks in use:

| Framework | Purpose |
|-----------|------|
| SwiftUI | UI composition |
| SwiftData | Local data persistence |
| WidgetKit | Widgets |
| HealthKit | Water intake read/write |
| UserNotifications | Hydration reminder notifications |

Reasons for using only Apple frameworks:

- **No supply chain attack exposure**: No vector for malicious code injection from external package repository breaches.
- **Auditability**: Source code managed by Apple is validated at the platform level.
- **No update dependencies**: No risk of external package version conflicts or abandoned maintenance.

### Procedure for Adding 3rd-Party Dependencies

Follow this process if an external dependency becomes necessary:

1. **Necessity review**: First confirm whether Apple frameworks or a custom implementation can substitute.
2. **Source audit**: Review the package source code directly. Do not use binary-only distribution packages.
3. **Permission review**: Confirm the system permissions the package requests or accesses.
4. **Maintenance status**: Check recent commit history, issue response, and any disclosed security vulnerabilities.
5. **Minimal scope**: Use only the needed functionality and don't expose the entire package to the app.
6. **Commit lock file**: Always commit `Package.resolved` to pin the version.

### Supply Chain Attack Defense

- Enable Swift Package Manager checksum verification.
- Do not use untrusted mirrors or forked repositories.
- Review changelogs and diffs before applying dependency updates.

---

## 7. General Security Rules

### No Hardcoded Secrets

Do not include the following in source code, Info.plist, or configuration files:

- API keys, secret keys, tokens
- Passwords, passphrases
- Internal server addresses or endpoints (the current app has no network features)

```swift
// Prohibited
let apiKey = "sk-1234abcd..."

// Since the app has no external API integrations, this situation should never arise
```

### Info.plist Privacy Key Completeness

A usage description key must exist in Info.plist for every system resource the app accesses.

| Permission | Key |
|------|-----|
| HealthKit read | `NSHealthShareUsageDescription` |
| HealthKit write | `NSHealthUpdateUsageDescription` |

When adding new system permissions, add the Info.plist key at the same time. Missing keys are grounds for App Store rejection.

### Debug/Release Build Separation

```swift
#if DEBUG
// Debug-only code: never included in release builds
print("Today's intake: \(intake)ml")
#endif
```

- Debug logs, test accounts, and development flags must only live inside `#if DEBUG` blocks.
- Always use conditional compilation to prevent debug information from leaking into release builds.

### Logging Security

```swift
// Prohibited: logging sensitive information
os_log("User intake: %{public}d", intake)

// Allowed: logging general events
os_log("Water record saved", log: .default, type: .info)
```

- Do not use the `%{public}` specifier in `os_log` for sensitive data.
- Do not include HealthKit values or personal goal data in logs.
- Apply lint rules to ensure no `print()` statements remain in production builds.

---

## 8. Security Checklist

Mechanically verify all items below before a release or security audit.

### Code Inspection

```bash
# Search for hardcoded secrets (should return no results)
grep -r "password\|secret\|apiKey\|api_key\|token\|private_key" \
  --include="*.swift" --include="*.plist" .

# Search for print() statements (should not exist in release builds)
grep -r "^[^/]*print(" --include="*.swift" .

# List @unchecked Sendable usage (each usage must have a comment)
grep -rn "@unchecked Sendable" --include="*.swift" .
```

### Info.plist Inspection

```bash
# Verify NSHealthShareUsageDescription key exists
/usr/libexec/PlistBuddy -c "Print NSHealthShareUsageDescription" \
  DrinkSomeWater/Info.plist

# Verify NSHealthUpdateUsageDescription key exists
/usr/libexec/PlistBuddy -c "Print NSHealthUpdateUsageDescription" \
  DrinkSomeWater/Info.plist
```

### Checklist Items

| Item | Verification Method | Expected Result |
|------|-----------|-----------|
| No hardcoded secrets | `grep` search | No results |
| `NSHealthShareUsageDescription` present | PlistBuddy query | Value printed |
| `NSHealthUpdateUsageDescription` present | PlistBuddy query | Value printed |
| HealthKit permission scope includes only `.dietaryWater` | Code review | No other HKQuantityTypeIdentifier |
| App Group ID matches `group.com.feelso.DrinkSomeWater` | Entitlements file check | Main app/widget match |
| All `@unchecked Sendable` usages have reason comments | Code review | `REASON:` comment at every usage |
| Notification content has no numeric health data | Code review | No intake variable in body |
| No `print()` outside `#if DEBUG` | `grep` search | No results |
| No 3rd-party dependencies | `Package.swift` check | dependencies array empty |
| No direct SwiftData writes from widget | Code review | No ModelContext save in widget target |
| Shared UserDefaults keys use `SharedDefaultsKey` constants | Code review | No direct string literals |
| Zero Swift strict concurrency warnings in release build | `xcodebuild` log | 0 warnings |

---

*Last updated: 2026-04-27*
*Target project: DrinkSomeWater (`com.feelso.DrinkSomeWater`) – Swift 6, Xcode 16+*
