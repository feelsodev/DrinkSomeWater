# SECURITY.md – 벌컥벌컥 iOS
> iOS/watchOS 보안 가이드라인 및 체크리스트

---

## 개요

이 문서는 벌컥벌컥 iOS/watchOS 앱의 보안 정책과 구현 지침을 정의한다. 모든 PR은 하단 체크리스트를 통과해야 한다.

**프로젝트 설정 참고**
- Bundle ID: `$(APP_BUNDLE_ID)` (xcconfig에서 관리)
- AdMob App ID: `$(ADMOB_APP_ID)`
- xcconfig 위치: `Tuist/Config/Debug.xcconfig`, `Tuist/Config/Release.xcconfig`

---

## 1. HealthKit 프라이버시

### 원칙

HealthKit 데이터는 기기 밖으로 나가지 않는다. 수분 섭취량(`.dietaryWater`)은 사용자의 건강 정보이므로 외부 서버 전송, 로깅, 분석 이벤트 페이로드 포함이 모두 금지된다.

### 권한 설정

`Project.swift`에 아래 두 키가 선언되어 있어야 한다. 문구는 실제 사용 목적과 일치해야 한다.

```
NSHealthShareUsageDescription  — 건강 데이터 읽기 용도 설명
NSHealthUpdateUsageDescription — 건강 데이터 쓰기 용도 설명
```

### 권한 요청 시점

- 권한 요청은 기능을 처음 사용하는 시점에 한다. 앱 실행 직후 즉시 요청하지 않는다.
- `HKHealthStore.isHealthDataAvailable()`을 먼저 확인한다. 시뮬레이터와 iPad에서 false를 반환할 수 있다.
- 권한이 거부되면 앱 내 수동 입력 모드로 graceful degradation한다. 크래시나 빈 화면을 보여주면 안 된다.

### 금지 사항

- HealthKit에서 읽은 값을 Firebase Analytics, Amplitude 등 외부 SDK에 전달하는 것
- `HKQuantitySample`을 로그 파일에 기록하는 것
- 권한 상태를 서버에 업로드하는 것

---

## 2. iCloud 동기화 보안

### 사용 범위

`NSUbiquitousKeyValueStore`를 통해 기기 간 동기화하는 데이터는 아래로 제한한다.

- 사용자 설정값 (목표 수분량, 알림 주기 등)
- 테마/UI 환경 설정

### 제외 대상

아래 데이터는 iCloud에 저장하지 않는다.

- HealthKit에서 읽은 건강 수치
- 광고 관련 식별자
- 임시 세션 토큰

### 구현 지침

- `NSUbiquitousKeyValueStore`의 최대 저장 용량(1MB)을 초과하지 않도록 저장 데이터 크기를 관리한다.
- 동기화 충돌 처리 시 `NSUbiquitousKeyValueStoreDidChangeExternallyNotification`을 올바르게 처리한다.
- iCloud가 비활성화된 환경에서도 앱이 정상 동작해야 한다.

---

## 3. App Group / 위젯 보안

### 공유 데이터 범위

App Group(`UserDefaults(suiteName:)`)을 통해 위젯과 공유하는 데이터는 화면 표시에 필요한 최솟값으로 제한한다.

**허용**
- 오늘의 수분 섭취량 합계
- 목표 수분량
- 마지막 업데이트 타임스탬프

**금지**
- 전체 섭취 히스토리
- 사용자 계정 정보
- HealthKit raw 샘플 데이터

### WidgetDataManager 사용

위젯과의 데이터 교환은 반드시 `WidgetDataManager`를 통한다. 위젯 익스텐션에서 `HKHealthStore`에 직접 접근하지 않는다.

### App Group Identifier

App Group identifier는 xcconfig에서 관리한다. 앱 타겟, 위젯 익스텐션, Watch 앱 익스텐션이 동일한 identifier를 사용하는지 빌드 전에 확인한다.

---

## 4. StoreKit 2 보안

### 구독 상태 관리

- `Transaction.currentEntitlements`를 통해 현재 구독 상태를 확인한다.
- 구독 상태는 앱 로컬에서 캐싱하되, 앱 포그라운드 복귀 시 StoreKit에서 재검증한다.
- 구독 상태를 나타내는 Bool 플래그를 `UserDefaults`에 단독 저장하고 이를 유일한 권한 판단 기준으로 사용하지 않는다. 항상 StoreKit 트랜잭션을 기준으로 한다.

### 서버사이드 검증

서버 연동이 있는 경우 App Store Server API를 통해 서버에서 트랜잭션을 검증한다. 클라이언트 단독 검증에만 의존하지 않는다.

### 트랜잭션 완료 처리

모든 트랜잭션에 대해 `Transaction.finish()`를 반드시 호출한다. 미완료 트랜잭션이 누적되면 구독 상태가 오작동할 수 있다.

---

## 5. 광고 SDK 보안

### AdMob 설정값 관리

AdMob 관련 ID는 소스 코드에 하드코딩하지 않는다. 모두 xcconfig를 통해 주입한다.

| 키 | xcconfig 변수 |
|----|---------------|
| AdMob App ID | `$(ADMOB_APP_ID)` |
| Banner Ad Unit ID | `$(ADMOB_BANNER_ID)` |
| Rewarded Ad Unit ID | `$(ADMOB_REWARDED_ID)` |
| Native Ad Unit ID | `$(ADMOB_NATIVE_ID)` |

`xcconfig` 파일 자체는 `.gitignore`에 포함시키거나, 민감 값을 분리한 별도 파일(`Secrets.xcconfig`)로 관리하고 git에서 제외한다.

### SKAdNetwork

`Info.plist`의 `SKAdNetworkItems`에는 AdMob이 공식 제공하는 목록만 포함한다. 출처 불명의 SKAdNetwork ID를 추가하지 않는다.

### 광고 데이터 격리

광고 SDK 초기화 코드는 사용자가 ATT(앱 추적 투명성) 동의 여부를 결정한 이후에 실행한다.

---

## 6. Firebase 보안

### GoogleService-Info.plist 관리

- `GoogleService-Info.plist`는 git에 커밋하지 않는다. CI/CD에서 환경 변수 또는 시크릿 매니저를 통해 주입한다.
- 파일이 실수로 커밋된 경우 즉시 Firebase 콘솔에서 해당 앱의 API 키를 재발급한다.

### Analytics 데이터 범위

Firebase Analytics로 전송하는 이벤트 페이로드에 다음을 포함하지 않는다.

- 수분 섭취량 수치
- HealthKit에서 읽은 모든 값
- 사용자 식별 가능 정보 (이름, 이메일 등)

허용 이벤트 예시: 화면 전환, 버튼 탭, 기능 사용 여부 (수치 없이)

### Firebase Remote Config

Remote Config 값을 보안 게이팅(유료 기능 잠금 해제 등)의 유일한 판단 근거로 사용하지 않는다. 서버 값은 언제든 클라이언트에서 조작될 수 있다.

---

## 7. Swift 6 동시성 안전

### 공유 가변 상태 보호

- 여러 Task에서 접근하는 가변 상태는 `actor`로 감싸거나 `@MainActor`로 격리한다.
- `@unchecked Sendable`은 내부적으로 동기화가 보장된 타입(예: `NSLock` 사용)에만 적용하고, 반드시 주석으로 근거를 남긴다.

```swift
// 예시: 올바른 @unchecked Sendable 사용
final class ThreadSafeStorage: @unchecked Sendable {
    private let lock = NSLock()
    private var cache: [String: Data] = [:]
    // NSLock으로 내부 동기화가 보장되므로 @unchecked Sendable 적용
}
```

### Sendable 경계

- HealthKit 데이터, 사용자 설정 모델 등 isolation 경계를 넘나드는 타입은 `Sendable`을 명시적으로 준수한다.
- `nonisolated(unsafe)` 키워드 사용은 최후 수단이며, 사용 시 코드 리뷰에서 반드시 논의한다.

---

## 8. 알림 보안

### 페이로드 제한

로컬 알림(`UNMutableNotificationContent`)의 `title`, `body`, `userInfo`에 다음을 포함하지 않는다.

- 수분 섭취 수치 (예: "오늘 1,200ml 마셨어요"처럼 구체적 수치)
- 건강 관련 추론 정보
- 세션 토큰 또는 인증 정보

알림 문구는 일반적인 격려 메시지나 리마인더로 한정한다.

### 알림 권한 요청 시점

알림 권한도 HealthKit과 동일하게 기능 첫 사용 시점에 요청한다. 앱 실행 직후 즉시 요청하지 않는다.

---

## 9. 빌드 보안

### Debug / Release 분리

`Tuist/Config/Debug.xcconfig`와 `Tuist/Config/Release.xcconfig`는 목적이 다르다.

| 항목 | Debug | Release |
|------|-------|---------|
| API_BASE_URL | 개발/스테이징 서버 | 프로덕션 서버 |
| ADMOB_APP_ID | 테스트 AdMob ID | 실제 AdMob ID |
| 로그 레벨 | verbose | error만 |
| 어설션 | 활성화 | 비활성화 |

### 금지 사항

- `#if DEBUG` 블록 안의 테스트 코드가 Release 빌드에 포함되지 않도록 한다.
- Release 빌드에서 `print()` 또는 `NSLog()`로 민감 데이터를 출력하지 않는다.
- xcconfig 파일에 실제 API 키를 커밋하지 않는다. 키는 로컬 전용 파일 또는 CI 시크릿으로 관리한다.

### Bitcode / 심볼

- App Store 제출 시 dSYM 파일을 Crashlytics 또는 Firebase Crashlytics에 업로드해 크래시 추적이 가능하도록 한다.
- dSYM 파일은 외부에 공개하지 않는다.

---

## 10. 보안 체크리스트

PR 머지 전 아래 항목을 확인한다. grep 명령으로 빠르게 검증할 수 있다.

### 하드코딩 검사

```bash
# AdMob ID 하드코딩 검사
grep -r "ca-app-pub-" ios/ --include="*.swift"

# API 키 패턴 검사
grep -r "AIza" ios/ --include="*.swift"

# 하드코딩된 URL 검사 (xcconfig 변수 사용 여부)
grep -r "https://api\." ios/ --include="*.swift"
```

위 명령에서 결과가 나오면 xcconfig 변수로 교체해야 한다.

### HealthKit 데이터 유출 검사

```bash
# Analytics 이벤트에 건강 데이터 포함 여부
grep -r "dietaryWater\|waterIntake\|healthStore" ios/ --include="*.swift" | grep -i "analytics\|log\|event"
```

### 민감 파일 git 추적 검사

```bash
# GoogleService-Info.plist git 추적 여부
git ls-files ios/ | grep "GoogleService-Info.plist"

# xcconfig 파일 git 추적 여부 (Secrets 포함 파일)
git ls-files ios/ | grep "Secrets.xcconfig"
```

위 명령에 결과가 있으면 즉시 `.gitignore`에 추가하고 git history에서 제거한다.

### 체크리스트 항목

**HealthKit**
- [ ] HealthKit 수치가 Firebase Analytics 이벤트에 포함되지 않는다
- [ ] `HKHealthStore.isHealthDataAvailable()` 확인 후 접근한다
- [ ] 권한 거부 시 graceful degradation이 동작한다

**광고 / 설정**
- [ ] AdMob ID가 Swift 파일에 하드코딩되어 있지 않다
- [ ] `$(ADMOB_APP_ID)`, `$(ADMOB_BANNER_ID)` 등 xcconfig 변수를 사용한다
- [ ] ATT 동의 이후 광고 SDK를 초기화한다

**Firebase**
- [ ] `GoogleService-Info.plist`가 `.gitignore`에 포함되어 있다
- [ ] Analytics 페이로드에 건강 수치가 없다

**iCloud / App Group**
- [ ] `NSUbiquitousKeyValueStore`에 HealthKit 데이터를 저장하지 않는다
- [ ] App Group 공유 데이터가 화면 표시용 최솟값으로 제한되어 있다

**빌드**
- [ ] Release 빌드에서 `print()`로 민감 데이터를 출력하지 않는다
- [ ] Debug/Release xcconfig가 올바른 환경 값을 가리킨다
- [ ] `#if DEBUG` 블록의 테스트 코드가 Release에 포함되지 않는다

**동시성**
- [ ] Swift 6 컴파일러 모드에서 data race 경고가 0개다
- [ ] `@unchecked Sendable` 사용 시 주석으로 근거가 명시되어 있다

**알림**
- [ ] 알림 페이로드에 수분 섭취 수치나 건강 추론 정보가 없다

---

*최종 업데이트: 2026-04-27*
