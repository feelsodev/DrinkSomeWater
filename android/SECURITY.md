# SECURITY.md – 벌컥벌컥 Android

> Android/Wear OS 보안 가이드라인 및 체크리스트

---

## 개요

이 문서는 벌컥벌컥 Android 앱 (`com.onceagain.drinksomewater`)의 보안 정책을 정의합니다. 모듈 구성은 `:app`, `:core`, `:widget`, `:wear`, `:analytics`이며, minSdk 29 / targetSdk 35 기준입니다.

---

## 1. Health Connect 프라이버시

### 권한 요청 흐름

Health Connect 권한은 앱 시작 시 일괄 요청하지 않습니다. 사용자가 해당 기능에 진입할 때만 요청하고, 왜 필요한지 사전 설명 화면을 반드시 제공해야 합니다.

```kotlin
// 올바른 예: 기능 진입 시 권한 확인 후 요청
val permissions = setOf(
    HealthPermission.getReadPermission(HydrationRecord::class),
    HealthPermission.getWritePermission(HydrationRecord::class)
)
```

### 데이터 범위 제한

- 수분 섭취 기록(`HydrationRecord`)만 읽기/쓰기 권한 요청
- 불필요한 건강 데이터 유형 권한 요청 금지
- 읽어온 Health Connect 데이터를 앱 외부 서버로 전송하지 않음
- 분석 이벤트에 실제 수치 값 포함 금지 (집계 수준만 허용)

### 사용자 거부 시 대응

- 권한 거부 후 강제 재요청 금지
- 거부 상태에서도 앱 핵심 기능(음수 기록)은 내부 DataStore로 동작해야 함
- `shouldShowRequestPermissionRationale()` 결과에 따라 설명 UI 분기

---

## 2. DataStore 보안

### Preferences DataStore 사용 원칙

`:core` 모듈에서 DataStore를 단일 진입점으로 관리합니다.

```kotlin
// core/data/datastore/UserPreferencesDataStore.kt
val Context.userPreferencesDataStore by preferencesDataStore(
    name = "user_preferences"
)
```

### 저장 금지 항목

DataStore(및 SharedPreferences)에 절대 저장하지 않는 데이터:

- 사용자 실명, 이메일, 전화번호
- 결제 정보
- 외부 서비스 인증 토큰 (Firebase ID Token 등)
- 기기 고유 식별자 (IMEI, MAC 주소 등)

### EncryptedSharedPreferences 고려

민감한 설정값 (예: 향후 계정 연동 토큰)이 생기면 `EncryptedSharedPreferences`로 전환합니다. 현재 버전에서는 수분 목표량, 알림 설정 등 비민감 데이터만 저장하므로 일반 DataStore로 충분합니다.

---

## 3. Glance 위젯 보안

### 위젯에서 접근 가능한 데이터 범위

위젯은 `:core:data`의 Repository를 통해 오늘의 음수량과 목표량만 읽습니다. 사용자 식별 정보나 Health Connect 원시 데이터를 위젯 UI에 직접 노출하지 않습니다.

```kotlin
// widget 모듈에서 허용되는 데이터만 노출
data class WaterWidgetState(
    val currentAmount: Int,   // ml
    val goalAmount: Int,       // ml
    val percentage: Float
)
```

### ActionCallback 보안

`ActionCallback` 구현체에서 지켜야 할 규칙:

- `Intent` extras에 개인정보 포함 금지
- ActionCallback을 통해 실행되는 동작은 단순 음수량 증가에 한정
- `GlanceId`를 외부 로그나 분석 이벤트에 그대로 노출하지 않음

```kotlin
class AddWaterActionCallback : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        // amount 값만 전달, 사용자 식별자 없음
        val amount = parameters[ActionParameters.Key<Int>("amount")] ?: return
        // ...
    }
}
```

---

## 4. Wear OS 보안

### DataLayer 통신 보안

폰과 워치 간 데이터는 Wearable DataLayer API를 통해서만 주고받습니다. 별도 네트워크 통신으로 동기화하지 않습니다.

- DataItem 경로 상수는 `:core` 모듈에 정의하고 양쪽에서 공유
- 경로 예시: `/water/today`, `/water/goal`
- 전송 데이터는 수분 섭취량과 목표량에 한정

```kotlin
// core에서 공유하는 경로 상수
object WearDataPaths {
    const val WATER_TODAY = "/water/today"
    const val WATER_GOAL = "/water/goal"
}
```

### 폰과 워치 데이터 범위

| 전송 항목 | 방향 | 허용 여부 |
|-----------|------|-----------|
| 오늘 음수량 (ml) | 폰 → 워치 | 허용 |
| 목표량 (ml) | 폰 → 워치 | 허용 |
| 음수 기록 추가 | 워치 → 폰 | 허용 |
| 사용자 ID / 이메일 | 양방향 | 금지 |
| Health Connect 원시 데이터 | 양방향 | 금지 |

---

## 5. 알림 보안

### POST_NOTIFICATIONS 권한 (Android 13+)

Android 13 (API 33) 이상에서는 `POST_NOTIFICATIONS` 런타임 권한이 필요합니다. 권한 없이 알림을 발송하지 않으며, 거부 시 앱이 강제 종료되어서는 안 됩니다.

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

```kotlin
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
    // 권한 확인 후 알림 예약
}
```

### 알림 페이로드 규칙

- 알림 제목/본문에 음수량 수치 외 개인정보 포함 금지
- 알림 `extras`에 사용자 식별자 포함 금지
- PendingIntent에 민감 데이터 삽입 금지
- `FLAG_IMMUTABLE` 사용 (Android 12+ 필수)

```kotlin
val pendingIntent = PendingIntent.getActivity(
    context, 0, intent,
    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
)
```

---

## 6. 광고 SDK 보안

### AdMob App ID 관리

AdMob App ID는 소스 코드에 하드코딩하지 않습니다. `local.properties` 또는 CI 환경변수로 관리합니다.

```properties
# local.properties (git에 포함하지 않음)
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

### 하드코딩 금지

- `ca-app-pub-` 패턴을 소스 코드에서 grep으로 주기적 검증
- 테스트용 App ID (`ca-app-pub-3940256099942544~3347511713`)도 프로덕션 코드에 남기지 않음

---

## 7. Firebase 보안

### google-services.json 관리

`google-services.json`은 `.gitignore`에 반드시 포함합니다. CI에서는 환경변수 또는 Secret Manager를 통해 주입합니다.

```gitignore
# .gitignore
app/google-services.json
```

CI 주입 예시 (GitHub Actions):

```yaml
- name: Create google-services.json
  run: echo '${{ secrets.GOOGLE_SERVICES_JSON }}' > app/google-services.json
```

### Firebase 보안 규칙

- Firestore / Realtime Database를 사용하는 경우 인증된 사용자만 접근하도록 보안 규칙 설정
- 현재 버전에서는 Analytics와 Crashlytics만 사용하므로 서버 측 규칙 불필요
- Firebase Analytics에 PII(개인 식별 정보) 전송 금지

---

## 8. ProGuard / R8

### 릴리즈 빌드 난독화

릴리즈 빌드에서 R8 난독화를 반드시 활성화합니다.

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

각 라이브러리 모듈 (`:core`, `:analytics` 등)은 `consumer-rules.pro`를 제공해 소비 모듈이 별도로 규칙을 추가하지 않아도 되도록 합니다.

```
# core/consumer-rules.pro
-keep class com.onceagain.drinksomewater.core.domain.model.** { *; }
```

### 주의 사항

- Health Connect, Glance, Hilt 관련 ProGuard 규칙은 공식 문서 기준으로 유지
- 난독화 후 크래시 리포트 역추적을 위해 `mapping.txt`를 Play Console에 업로드
- 디버그 빌드에서 `isMinifyEnabled = false` 유지

---

## 9. 의존성 관리

### Version Catalog 사용

모든 의존성 버전은 `gradle/libs.versions.toml`에서 중앙 관리합니다. 버전을 `build.gradle.kts`에 직접 하드코딩하지 않습니다.

```toml
# gradle/libs.versions.toml
[versions]
kotlin = "2.0.0"
hilt = "2.51"
compose-bom = "2024.05.00"

[libraries]
hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }
```

### 의존성 업데이트 정책

- 패치 버전: 검증 없이 적용 가능
- 마이너 버전: 변경 로그 확인 후 적용
- 메이저 버전: 마이그레이션 가이드 검토 후 적용
- 보안 취약점이 발견된 의존성은 48시간 내 업데이트

### 취약점 스캔

Gradle의 의존성 취약점 스캔을 활용합니다.

```kotlin
// build.gradle.kts (루트)
plugins {
    id("org.owasp.dependencycheck") version "9.0.9"
}
```

CI 파이프라인에서 주기적으로 `./gradlew dependencyCheckAnalyze`를 실행합니다.

---

## 10. 보안 체크리스트

PR 머지 전 또는 릴리즈 전에 아래 항목을 검증합니다.

### 자동 검증 (grep 기반)

```bash
# API 키 / 시크릿 하드코딩 확인
grep -r "ca-app-pub-" --include="*.kt" --include="*.xml" app/src/
grep -r "AIza" --include="*.kt" app/src/
grep -r "google-services" --include="*.kt" app/src/

# !! 연산자 사용 빈도 확인
grep -rn "!!" --include="*.kt" app/src/ core/src/

# GlobalScope 사용 확인
grep -rn "GlobalScope" --include="*.kt" .

# 하드코딩된 패키지명 외 민감 문자열 확인
grep -rn "password\|secret\|token\|api_key" --include="*.kt" --include="*.xml" -i app/src/
```

### 수동 확인 항목

- [ ] `app/google-services.json`이 `.gitignore`에 포함되어 있다
- [ ] `local.properties`가 `.gitignore`에 포함되어 있다
- [ ] `AdMob App ID`가 소스 코드에 하드코딩되어 있지 않다
- [ ] Health Connect 권한 목록이 실제 사용 범위와 일치한다
- [ ] 알림 페이로드에 개인정보가 없다
- [ ] DataLayer 전송 데이터에 사용자 식별자가 없다
- [ ] 릴리즈 빌드에 `isMinifyEnabled = true`가 설정되어 있다
- [ ] `mapping.txt`를 Play Console에 업로드할 준비가 되어 있다
- [ ] 의존성 중 알려진 취약점이 없다 (`dependencyCheckAnalyze` 통과)
- [ ] Firebase Analytics 이벤트 파라미터에 PII가 없다
- [ ] `com.onceagain.drinksomewater` 패키지 외부로 민감 데이터를 전송하지 않는다

---

## 모듈별 보안 책임

| 모듈 | 주요 보안 책임 |
|------|----------------|
| `:app` | 권한 요청 흐름, 알림 페이로드, ProGuard 설정 |
| `:core` | DataStore 저장 항목 제한, Health Connect 데이터 범위 |
| `:widget` | ActionCallback 데이터 제한, 위젯 노출 정보 최소화 |
| `:wear` | DataLayer 경로 상수 관리, 전송 데이터 범위 |
| `:analytics` | PII 전송 금지, 이벤트 파라미터 검증 |

---

*보안 취약점 발견 시 공개 이슈 대신 비공개 채널로 보고하세요. 이 문서는 릴리즈마다 검토합니다.*
