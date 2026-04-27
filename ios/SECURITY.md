# SECURITY.md – 벌컥벌컥 (Gulp) iOS
> iOS/watchOS security guidelines and checklist

---

## Overview

This document defines the security policies and implementation guidelines for the 벌컥벌컥 (Gulp) iOS/watchOS app. All PRs must pass the checklist at the bottom.

**Project config reference**
- Bundle ID: `$(APP_BUNDLE_ID)` (managed via xcconfig)
- AdMob App ID: `$(ADMOB_APP_ID)`
- xcconfig locations: `Tuist/Config/Debug.xcconfig`, `Tuist/Config/Release.xcconfig`

---

## 1. HealthKit Privacy

### Principle

HealthKit data never leaves the device. Water intake (`.dietaryWater`) is personal health information, so sending it to external servers, logging it, or including it in analytics event payloads is strictly prohibited.

### Permission Configuration

The following two keys must be declared in `Project.swift`. The descriptions must match their actual purpose.

```
NSHealthShareUsageDescription  — Explains why the app reads health data
NSHealthUpdateUsageDescription — Explains why the app writes health data
```

### When to Request Permission

- Request permission at the moment the feature is first used. Don't request immediately on app launch.
- Check `HKHealthStore.isHealthDataAvailable()` first. It can return false on simulators and iPads.
- If permission is denied, gracefully degrade to manual entry mode within the app. Never show a crash or blank screen.

### Prohibitions

- Passing values read from HealthKit to external SDKs such as Firebase Analytics or Amplitude
- Writing `HKQuantitySample` data to log files
- Uploading permission status to a server

---

## 2. iCloud Sync Security

### Scope

Data synced between devices via `NSUbiquitousKeyValueStore` is limited to:

- User preferences (daily water goal, notification interval, etc.)
- Theme and UI settings

### Exclusions

The following data must not be stored in iCloud:

- Health values read from HealthKit
- Advertising-related identifiers
- Temporary session tokens

### Implementation Guidelines

- Manage stored data size to stay within `NSUbiquitousKeyValueStore`'s maximum capacity (1 MB).
- Handle sync conflicts by correctly processing `NSUbiquitousKeyValueStoreDidChangeExternallyNotification`.
- The app must work normally even when iCloud is disabled.

---

## 3. App Group / Widget Security

### Shared Data Scope

Data shared with the widget via App Group (`UserDefaults(suiteName:)`) is limited to the minimum needed for display.

**Allowed**
- Today's total water intake
- Daily water goal
- Last update timestamp

**Prohibited**
- Full intake history
- User account information
- HealthKit raw sample data

### Using WidgetDataManager

All data exchange with the widget must go through `WidgetDataManager`. The widget extension must not access `HKHealthStore` directly.

### App Group Identifier

The App Group identifier is managed via xcconfig. Confirm that the app target, widget extension, and Watch app extension all use the same identifier before building.

---

## 4. StoreKit 2 Security

### Subscription State Management

- Use `Transaction.currentEntitlements` to check current subscription status.
- Cache subscription state locally, but re-validate against StoreKit when the app returns to foreground.
- Don't store a subscription status Bool flag in `UserDefaults` and treat it as the sole source of truth for entitlements. Always use StoreKit transactions as the authoritative source.

### Server-Side Validation

If server integration is present, validate transactions on the server via the App Store Server API. Don't rely solely on client-side validation.

### Transaction Completion

Always call `Transaction.finish()` for every transaction. Unfinished transactions accumulating can cause subscription state to malfunction.

---

## 5. Ad SDK Security

### Managing AdMob Config Values

AdMob-related IDs must not be hardcoded in source files. All are injected via xcconfig.

| Key | xcconfig Variable |
|----|------------------|
| AdMob App ID | `$(ADMOB_APP_ID)` |
| Banner Ad Unit ID | `$(ADMOB_BANNER_ID)` |
| Rewarded Ad Unit ID | `$(ADMOB_REWARDED_ID)` |
| Native Ad Unit ID | `$(ADMOB_NATIVE_ID)` |

The `xcconfig` files themselves should be added to `.gitignore`, or sensitive values should be managed in a separate file (`Secrets.xcconfig`) that is excluded from git.

### SKAdNetwork

`SKAdNetworkItems` in `Info.plist` should only include the list officially provided by AdMob. Don't add SKAdNetwork IDs from unknown sources.

### Ad Data Isolation

Ad SDK initialization code must run only after the user has made an ATT (App Tracking Transparency) decision.

---

## 6. Firebase Security

### Managing GoogleService-Info.plist

- `GoogleService-Info.plist` must not be committed to git. Inject it in CI/CD via environment variables or a secret manager.
- If the file is accidentally committed, immediately regenerate the API key for that app in the Firebase console.

### Analytics Data Scope

The following must not be included in event payloads sent to Firebase Analytics:

- Water intake amounts
- Any values read from HealthKit
- Personally identifiable information (name, email, etc.)

Allowed event examples: screen transitions, button taps, feature usage (without numeric values)

### Firebase Remote Config

Don't use Remote Config values as the sole gate for security decisions (e.g. unlocking premium features). Server-side values can always be manipulated on the client.

---

## 7. Swift 6 Concurrency Safety

### Protecting Shared Mutable State

- Mutable state accessed from multiple Tasks must be wrapped in an `actor` or isolated with `@MainActor`.
- Apply `@unchecked Sendable` only to types that guarantee internal synchronization (e.g. using `NSLock`), and always include a comment explaining why.

```swift
// Example: correct use of @unchecked Sendable
final class ThreadSafeStorage: @unchecked Sendable {
    private let lock = NSLock()
    private var cache: [String: Data] = [:]
    // @unchecked Sendable applied because internal sync is guaranteed via NSLock
}
```

### Sendable Boundaries

- Types that cross isolation boundaries, such as HealthKit data or user settings models, must explicitly conform to `Sendable`.
- The `nonisolated(unsafe)` keyword is a last resort and must be discussed in code review whenever used.

---

## 8. Notification Security

### Payload Restrictions

The `title`, `body`, and `userInfo` of local notifications (`UNMutableNotificationContent`) must not contain:

- Specific water intake amounts (e.g. "You've had 1,200ml today")
- Health-related inferences
- Session tokens or authentication credentials

Notification copy is limited to general encouragement messages and reminders.

### When to Request Notification Permission

Notification permission, like HealthKit permission, is requested at first use of the feature. Don't request it immediately on app launch.

---

## 9. Build Security

### Debug / Release Separation

`Tuist/Config/Debug.xcconfig` and `Tuist/Config/Release.xcconfig` serve different purposes.

| Item | Debug | Release |
|------|-------|---------|
| API_BASE_URL | Dev/staging server | Production server |
| ADMOB_APP_ID | Test AdMob ID | Real AdMob ID |
| Log level | verbose | error only |
| Assertions | enabled | disabled |

### Prohibitions

- Ensure test code inside `#if DEBUG` blocks is not included in Release builds.
- Don't output sensitive data via `print()` or `NSLog()` in Release builds.
- Don't commit real API keys in xcconfig files. Manage keys in local-only files or CI secrets.

### Bitcode / Symbols

- When submitting to the App Store, upload dSYM files to Crashlytics or Firebase Crashlytics so crash tracking works.
- Don't share dSYM files publicly.

---

## 10. Security Checklist

Review the items below before merging a PR. You can verify quickly with grep commands.

### Hardcoding Checks

```bash
# Check for hardcoded AdMob IDs
grep -r "ca-app-pub-" ios/ --include="*.swift"

# Check for API key patterns
grep -r "AIza" ios/ --include="*.swift"

# Check for hardcoded URLs (verify xcconfig variable usage)
grep -r "https://api\." ios/ --include="*.swift"
```

If any of the above commands return results, replace them with xcconfig variables.

### HealthKit Data Leak Check

```bash
# Check whether health data is included in analytics events
grep -r "dietaryWater\|waterIntake\|healthStore" ios/ --include="*.swift" | grep -i "analytics\|log\|event"
```

### Sensitive File Git Tracking Check

```bash
# Check whether GoogleService-Info.plist is tracked by git
git ls-files ios/ | grep "GoogleService-Info.plist"

# Check whether Secrets xcconfig is tracked by git
git ls-files ios/ | grep "Secrets.xcconfig"
```

If the above commands return results, immediately add to `.gitignore` and remove from git history.

### Checklist Items

**HealthKit**
- [ ] HealthKit values are not included in Firebase Analytics events
- [ ] `HKHealthStore.isHealthDataAvailable()` is checked before access
- [ ] Graceful degradation works when permission is denied

**Ads / Config**
- [ ] AdMob IDs are not hardcoded in Swift files
- [ ] xcconfig variables like `$(ADMOB_APP_ID)` and `$(ADMOB_BANNER_ID)` are used
- [ ] Ad SDK is initialized after ATT consent

**Firebase**
- [ ] `GoogleService-Info.plist` is included in `.gitignore`
- [ ] Analytics payloads contain no health values

**iCloud / App Group**
- [ ] HealthKit data is not stored in `NSUbiquitousKeyValueStore`
- [ ] App Group shared data is limited to the minimum needed for display

**Build**
- [ ] Sensitive data is not output via `print()` in Release builds
- [ ] Debug/Release xcconfig points to the correct environment values
- [ ] Test code in `#if DEBUG` blocks is not included in Release

**Concurrency**
- [ ] Zero data race warnings in Swift 6 compiler mode
- [ ] A comment explaining the rationale is present whenever `@unchecked Sendable` is used

**Notifications**
- [ ] Notification payloads contain no water intake amounts or health inferences

---

*Last updated: 2026-04-27*
