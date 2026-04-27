# Release Guide

> Gulp Android app release procedure

---

## 1. Creating a Keystore

### 1.1 Keystore creation command

```bash
keytool -genkey -v -keystore drinksomewater-release.keystore \
  -alias drinksomewater \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

### 1.2 Input example

```
Enter keystore password: ********
Re-enter new password: ********
What is your first and last name?
  [Unknown]: Your Name
What is the name of your organizational unit?
  [Unknown]: Development
What is the name of your organization?
  [Unknown]: Once Again
What is the name of your City or Locality?
  [Unknown]: Seoul
What is the name of your State or Province?
  [Unknown]: Seoul
What is the two-letter country code for this unit?
  [Unknown]: KR
Is CN=Your Name, OU=Development, O=Once Again, L=Seoul, ST=Seoul, C=KR correct?
  [no]: yes

Enter key password for <drinksomewater>
  (RETURN if same as keystore password): ********
```

### 1.3 Storing the keystore file

> **Important**: Keep the keystore file and password in a safe place. If lost, you won't be able to update the app!

- Keystore file: store in a safe location outside the project
- Password: record in a password manager or secure location
- Backup: at least 2 backup copies recommended

---

## 2. Local Build Configuration

### 2.1 local.properties setup

Add the following to your `android/local.properties` file:

```properties
# Signing Config (DO NOT COMMIT!)
KEYSTORE_FILE=/path/to/drinksomewater-release.keystore
KEYSTORE_PASSWORD=your_keystore_password
KEY_ALIAS=drinksomewater
KEY_PASSWORD=your_key_password
```

> **Warning**: `local.properties` is already in `.gitignore`. Never commit it!

### 2.2 Release build

```bash
cd android

# App release build
./gradlew :app:assembleRelease

# Wear OS release build  
./gradlew :wear:assembleRelease

# Full release build
./gradlew assembleRelease
```

### 2.3 Build output locations

- App APK: `app/build/outputs/apk/release/app-release.apk`
- App Bundle: `app/build/outputs/bundle/release/app-release.aab`
- Wear APK: `wear/build/outputs/apk/release/wear-release.apk`

---

## 3. CI/CD Setup (GitHub Actions)

### 3.1 GitHub Secrets configuration

Go to Repository Settings → Secrets and variables → Actions and add the following secrets:

| Secret Name | Description |
|-------------|-------------|
| `KEYSTORE_BASE64` | Base64-encoded keystore file |
| `KEYSTORE_PASSWORD` | Keystore password |
| `KEY_ALIAS` | Key alias |
| `KEY_PASSWORD` | Key password |

### 3.2 Base64 encoding method

```bash
# macOS / Linux
base64 -i drinksomewater-release.keystore | pbcopy
# or
cat drinksomewater-release.keystore | base64

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("drinksomewater-release.keystore"))
```

### 3.3 GitHub Actions Workflow example

```yaml
name: Release Build

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Decode Keystore
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}
        run: |
          echo $KEYSTORE_BASE64 | base64 --decode > android/app/release.keystore

      - name: Build Release APK
        env:
          KEYSTORE_FILE: release.keystore
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
        run: |
          cd android
          ./gradlew assembleRelease

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: android/app/build/outputs/apk/release/*.apk
```

---

## 4. Play Store Upload

### 4.1 Generate App Bundle (recommended)

```bash
./gradlew :app:bundleRelease
```

Output: `app/build/outputs/bundle/release/app-release.aab`

### 4.2 Play Console upload

1. Go to [Google Play Console](https://play.google.com/console)
2. Select app → Release → Production (or test track)
3. Click "Create new release"
4. Upload App Bundle (.aab) file
5. Write release notes
6. Review and publish

### 4.3 Internal test track

Before the first release, it's recommended to test on the internal test track:

1. Release → Testing → Internal testing
2. Register tester email addresses
3. Upload AAB and share the test link

---

## 5. Release Checklist

### Before build

- [ ] `versionCode` incremented (app/build.gradle.kts)
- [ ] `versionName` updated
- [ ] All tests passing (`./gradlew test`)
- [ ] Lint checks passing (`./gradlew lint`)
- [ ] Debug code/logs removed

### After build

- [ ] Release APK/AAB generated successfully
- [ ] Release build installed and basic features tested
- [ ] ProGuard applied (obfuscated code)
- [ ] App launches without crashes

### Before Play Store upload

- [ ] Screenshots are up to date
- [ ] App description updated (new features)
- [ ] Release notes written
- [ ] Privacy policy URL confirmed

---

## 6. Version Management

### Version code rules

```
versionCode = MAJOR * 10000 + MINOR * 100 + PATCH
```

Examples:
- 1.0.0 → 10000
- 1.2.3 → 10203
- 2.0.0 → 20000

### app/build.gradle.kts update

```kotlin
defaultConfig {
    applicationId = "com.onceagain.drinksomewater"
    minSdk = 29
    targetSdk = 35
    versionCode = 10000  // 1.0.0
    versionName = "1.0.0"
}
```

---

## 7. Troubleshooting

### Signing error

```
Execution failed for task ':app:packageRelease'.
> A failure occurred while executing ...
> SigningConfig "release" is missing required property "storeFile"
```

**Fix**: Verify that signing information is set in `local.properties` or environment variables.

### Obfuscation error

```
R8: ... can't find referenced class
```

**Fix**: Add a keep rule for the relevant class in `proguard-rules.pro`.

### Play Store upload failure

```
You uploaded an APK that is signed with a different certificate
```

**Fix**: Must sign with the same keystore. If the keystore is lost, consider using Play App Signing.
