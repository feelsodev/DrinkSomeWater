# 릴리스 가이드

> 벌컥벌컥 Android 앱 릴리스 절차

---

## 1. 키스토어 생성

### 1.1 키스토어 생성 명령어

```bash
keytool -genkey -v -keystore drinksomewater-release.keystore \
  -alias drinksomewater \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

### 1.2 입력 정보 예시

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

### 1.3 키스토어 파일 보관

> **중요**: 키스토어 파일과 비밀번호를 안전하게 보관하세요. 분실 시 앱 업데이트가 불가능합니다!

- 키스토어 파일: 프로젝트 외부 안전한 위치에 보관
- 비밀번호: 비밀번호 관리자나 안전한 장소에 기록
- 백업: 최소 2곳 이상에 백업 권장

---

## 2. 로컬 빌드 설정

### 2.1 local.properties 설정

`android/local.properties` 파일에 다음 내용 추가:

```properties
# Signing Config (DO NOT COMMIT!)
KEYSTORE_FILE=/path/to/drinksomewater-release.keystore
KEYSTORE_PASSWORD=your_keystore_password
KEY_ALIAS=drinksomewater
KEY_PASSWORD=your_key_password
```

> **주의**: `local.properties`는 `.gitignore`에 이미 포함되어 있습니다. 절대 커밋하지 마세요!

### 2.2 릴리스 빌드

```bash
cd android

# App 릴리스 빌드
./gradlew :app:assembleRelease

# Wear OS 릴리스 빌드  
./gradlew :wear:assembleRelease

# 전체 릴리스 빌드
./gradlew assembleRelease
```

### 2.3 빌드 결과물 위치

- App APK: `app/build/outputs/apk/release/app-release.apk`
- App Bundle: `app/build/outputs/bundle/release/app-release.aab`
- Wear APK: `wear/build/outputs/apk/release/wear-release.apk`

---

## 3. CI/CD 설정 (GitHub Actions)

### 3.1 GitHub Secrets 설정

Repository Settings → Secrets and variables → Actions에서 다음 시크릿 추가:

| Secret Name | Description |
|-------------|-------------|
| `KEYSTORE_BASE64` | 키스토어 파일을 Base64 인코딩한 값 |
| `KEYSTORE_PASSWORD` | 키스토어 비밀번호 |
| `KEY_ALIAS` | 키 별칭 |
| `KEY_PASSWORD` | 키 비밀번호 |

### 3.2 Base64 인코딩 방법

```bash
# macOS / Linux
base64 -i drinksomewater-release.keystore | pbcopy
# 또는
cat drinksomewater-release.keystore | base64

# Windows (PowerShell)
[Convert]::ToBase64String([IO.File]::ReadAllBytes("drinksomewater-release.keystore"))
```

### 3.3 GitHub Actions Workflow 예시

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

## 4. Play Store 업로드

### 4.1 App Bundle 생성 (권장)

```bash
./gradlew :app:bundleRelease
```

결과물: `app/build/outputs/bundle/release/app-release.aab`

### 4.2 Play Console 업로드

1. [Google Play Console](https://play.google.com/console) 접속
2. 앱 선택 → 릴리스 → 프로덕션 (또는 테스트 트랙)
3. "새 릴리스 만들기" 클릭
4. App Bundle (.aab) 파일 업로드
5. 릴리스 노트 작성
6. 검토 및 출시

### 4.3 내부 테스트 트랙

첫 릴리스 전에 내부 테스트 트랙에서 테스트 권장:

1. 릴리스 → 테스트 → 내부 테스트
2. 테스터 이메일 등록
3. AAB 업로드 후 테스트 링크 공유

---

## 5. 릴리스 체크리스트

### 빌드 전

- [ ] `versionCode` 증가 확인 (app/build.gradle.kts)
- [ ] `versionName` 업데이트 확인
- [ ] 모든 테스트 통과 (`./gradlew test`)
- [ ] Lint 검사 통과 (`./gradlew lint`)
- [ ] 디버그 코드/로그 제거 확인

### 빌드 후

- [ ] 릴리스 APK/AAB 생성 확인
- [ ] 릴리스 빌드 설치 및 기본 기능 테스트
- [ ] ProGuard 적용 확인 (난독화된 코드)
- [ ] 크래시 없이 앱 실행 확인

### Play Store 업로드 전

- [ ] 스크린샷 최신 버전 확인
- [ ] 앱 설명 업데이트 (새 기능)
- [ ] 릴리스 노트 작성
- [ ] 개인정보 처리방침 URL 확인

---

## 6. 버전 관리

### 버전 코드 규칙

```
versionCode = MAJOR * 10000 + MINOR * 100 + PATCH
```

예시:
- 1.0.0 → 10000
- 1.2.3 → 10203
- 2.0.0 → 20000

### app/build.gradle.kts 업데이트

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

## 7. 트러블슈팅

### 서명 오류

```
Execution failed for task ':app:packageRelease'.
> A failure occurred while executing ...
> SigningConfig "release" is missing required property "storeFile"
```

**해결**: `local.properties` 또는 환경 변수에 서명 정보가 설정되었는지 확인

### 난독화 오류

```
R8: ... can't find referenced class
```

**해결**: `proguard-rules.pro`에 해당 클래스 keep 규칙 추가

### Play Store 업로드 실패

```
You uploaded an APK that is signed with a different certificate
```

**해결**: 동일한 키스토어로 서명해야 함. 키스토어 분실 시 Play App Signing 사용 고려
