# SECURITY.md – 벌컥벌컥 (Gulp) Android

> Security guidelines and checklist for Android/Wear OS

---

## Overview

This document defines the security policy for the 벌컥벌컥 (Gulp) Android app (`com.onceagain.drinksomewater`). The module setup is `:app`, `:core`, `:widget`, `:wear`, `:analytics`, targeting minSdk 29 / targetSdk 35.

---

## 1. Health Connect Privacy

### Permission Request Flow

Health Connect permissions are not requested all at once on app launch. Request them only when the user enters the relevant feature, and always show an explanation screen first describing why the permission is needed.

```kotlin
// Correct: check and request permission when entering a feature
val permissions = setOf(
    HealthPermission.getReadPermission(HydrationRecord::class),
    HealthPermission.getWritePermission(HydrationRecord::class)
)
```

### Data Scope Limits

- Request only read/write permissions for hydration records (`HydrationRecord`)
- Do not request permissions for unnecessary health data types
- Do not send Health Connect data to external servers outside the app
- Do not include actual numeric values in analytics events (aggregated levels only)

### Handling Permission Denial

- Do not forcibly re-request permission after denial
- The app's core feature (logging water intake) must still work via internal DataStore when permission is denied
- Branch the explanation UI based on `shouldShowRequestPermissionRationale()` result

---

## 2. DataStore Security

### Preferences DataStore Usage Principles

Manage DataStore as a single entry point in the `:core` module.

```kotlin
// core/data/datastore/UserPreferencesDataStore.kt
val Context.userPreferencesDataStore by preferencesDataStore(
    name = "user_preferences"
)
```

### Prohibited Storage Items

Never store the following in DataStore (or SharedPreferences):

- User real name, email, phone number
- Payment information
- External service auth tokens (Firebase ID Token, etc.)
- Device unique identifiers (IMEI, MAC address, etc.)

### EncryptedSharedPreferences Consideration

If sensitive config values appear (e.g., future account linking tokens), switch to `EncryptedSharedPreferences`. The current version stores only non-sensitive data like water goals and notification settings, so regular DataStore is sufficient.

---

## 3. Glance Widget Security

### Data Scope Accessible from Widget

The widget reads only today's water intake and the daily goal through the Repository in `:core:data`. It does not directly expose user identification data or raw Health Connect data in the widget UI.

```kotlin
// Only permitted data exposed from the widget module
data class WaterWidgetState(
    val currentAmount: Int,   // ml
    val goalAmount: Int,       // ml
    val percentage: Float
)
```

### ActionCallback Security

Rules for `ActionCallback` implementations:

- Do not include personal data in `Intent` extras
- Actions triggered through ActionCallback are limited to incrementing water intake
- Do not expose `GlanceId` directly in external logs or analytics events

```kotlin
class AddWaterActionCallback : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        // Only amount value passed, no user identifier
        val amount = parameters[ActionParameters.Key<Int>("amount")] ?: return
        // ...
    }
}
```

---

## 4. Wear OS Security

### DataLayer Communication Security

Data between the phone and watch is exchanged only through the Wearable DataLayer API. Do not sync via separate network calls.

- DataItem path constants are defined in the `:core` module and shared by both sides
- Example paths: `/water/today`, `/water/goal`
- Transmitted data is limited to water intake and daily goal

```kotlin
// Path constants shared from core
object WearDataPaths {
    const val WATER_TODAY = "/water/today"
    const val WATER_GOAL = "/water/goal"
}
```

### Phone and Watch Data Scope

| Item | Direction | Allowed |
|------|-----------|---------|
| Today's water intake (ml) | Phone → Watch | Allowed |
| Daily goal (ml) | Phone → Watch | Allowed |
| Add water log entry | Watch → Phone | Allowed |
| User ID / Email | Both directions | Prohibited |
| Raw Health Connect data | Both directions | Prohibited |

---

## 5. Notification Security

### POST_NOTIFICATIONS Permission (Android 13+)

Android 13 (API 33) and above requires the `POST_NOTIFICATIONS` runtime permission. Do not send notifications without permission, and the app must not crash if permission is denied.

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

```kotlin
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    // Check permission before scheduling notifications
}
```

### Notification Payload Rules

- Do not include personal data in notification title/body beyond water intake values
- Do not include user identifiers in notification `extras`
- Do not insert sensitive data into PendingIntent
- Use `FLAG_IMMUTABLE` (required for Android 12+)

```kotlin
val pendingIntent = PendingIntent.getActivity(
    context, 0, intent,
    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
)
```

---

## 6. Ad SDK Security

### AdMob App ID Management

Do not hardcode the AdMob App ID in source code. Manage it via `local.properties` or CI environment variables.

```properties
# local.properties (not included in git)
ADMOB_APP_ID=ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX
```

```kotlin
// build.gradle.kts (:app)
val admobAppId = localProperties.getProperty("ADMOB_APP_ID")
    ?: System.getenv("ADMOB_APP_ID")
    ?: error("ADMOB_APP_ID not set")

manifestPlaceholders["admobAppId"] = admobAppId
```

```xml
<!-- AndroidManifest.xml -->
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="${admobAppId}" />
```

### No Hardcoding

- Periodically verify there are no `ca-app-pub-` patterns in source code using grep
- Do not leave test App IDs (`ca-app-pub-3940256099942544~3347511713`) in production code

---

## 7. Firebase Security

### google-services.json Management

`google-services.json` must be included in `.gitignore`. In CI, inject it via environment variables or Secret Manager.

```gitignore
# .gitignore
app/google-services.json
```

CI injection example (GitHub Actions):

```yaml
- name: Create google-services.json
  run: echo '${{ secrets.GOOGLE_SERVICES_JSON }}' > app/google-services.json
```

### Firebase Security Rules

- If using Firestore / Realtime Database, configure security rules so only authenticated users can access data
- The current version uses only Analytics and Crashlytics, so no server-side rules are needed
- Do not send PII (Personally Identifiable Information) to Firebase Analytics

---

## 8. ProGuard / R8

### Release Build Obfuscation

R8 obfuscation must be enabled in release builds.

```kotlin
// build.gradle.kts (:app)
buildTypes {
    release {
        isMinifyEnabled = true
        isShrinkResources = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

### consumer-rules.pro

Each library module (`:core`, `:analytics`, etc.) should provide a `consumer-rules.pro` so consuming modules don't need to add their own rules.

```
# core/consumer-rules.pro
-keep class com.onceagain.drinksomewater.core.domain.model.** { *; }
```

### Notes

- Keep ProGuard rules for Health Connect, Glance, and Hilt based on official documentation
- Upload `mapping.txt` to Play Console to enable crash report deobfuscation after obfuscation
- Keep `isMinifyEnabled = false` for debug builds

---

## 9. Dependency Management

### Version Catalog Usage

All dependency versions are centrally managed in `gradle/libs.versions.toml`. Do not hardcode versions directly in `build.gradle.kts`.

```toml
# gradle/libs.versions.toml
[versions]
kotlin = "2.0.0"
hilt = "2.51"
compose-bom = "2024.05.00"

[libraries]
hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }
```

### Dependency Update Policy

- Patch versions: Can be applied without review
- Minor versions: Check changelog before applying
- Major versions: Review migration guide before applying
- Dependencies with known security vulnerabilities must be updated within 48 hours

### Vulnerability Scanning

Use Gradle's dependency vulnerability scanning.

```kotlin
// build.gradle.kts (root)
plugins {
    id("org.owasp.dependencycheck") version "9.0.9"
}
```

Run `./gradlew dependencyCheckAnalyze` periodically in the CI pipeline.

---

## 10. Security Checklist

Verify the following items before merging a PR or before release.

### Automated Verification (grep-based)

```bash
# Check for hardcoded API keys / secrets
grep -r "ca-app-pub-" --include="*.kt" --include="*.xml" app/src/
grep -r "AIza" --include="*.kt" app/src/
grep -r "google-services" --include="*.kt" app/src/

# Check !! operator frequency
grep -rn "!!" --include="*.kt" app/src/ core/src/

# Check GlobalScope usage
grep -rn "GlobalScope" --include="*.kt" .

# Check for sensitive strings beyond hardcoded package names
grep -rn "password\|secret\|token\|api_key" --include="*.kt" --include="*.xml" -i app/src/
```

### Manual Verification Items

- [ ] `app/google-services.json` is in `.gitignore`
- [ ] `local.properties` is in `.gitignore`
- [ ] `AdMob App ID` is not hardcoded in source code
- [ ] Health Connect permission list matches actual usage scope
- [ ] Notification payload contains no personal data
- [ ] DataLayer transmitted data contains no user identifiers
- [ ] Release build has `isMinifyEnabled = true`
- [ ] `mapping.txt` is ready to upload to Play Console
- [ ] No known vulnerabilities in dependencies (`dependencyCheckAnalyze` passes)
- [ ] Firebase Analytics event parameters contain no PII
- [ ] No sensitive data is sent outside the `com.onceagain.drinksomewater` package

---

## Security Responsibilities by Module

| Module | Key Security Responsibilities |
|--------|-------------------------------|
| `:app` | Permission request flow, notification payload, ProGuard configuration |
| `:core` | DataStore storage restrictions, Health Connect data scope |
| `:widget` | ActionCallback data restrictions, minimize widget exposed information |
| `:wear` | DataLayer path constant management, transmitted data scope |
| `:analytics` | No PII transmission, event parameter validation |

---

*If you discover a security vulnerability, report it through a private channel rather than a public issue. This document is reviewed with each release.*
