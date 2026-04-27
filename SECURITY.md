# SECURITY.md – DrinkSomeWater
> 보안 가이드라인 및 체크리스트

이 문서는 DrinkSomeWater iOS 앱(`com.feelso.DrinkSomeWater`)의 보안 원칙과 실천 지침을 정의한다. Swift 6, SwiftUI, SwiftData, WidgetKit, HealthKit을 기반으로 한 프로젝트 특성에 맞춘 구체적인 규칙을 담고 있다.

---

## 목차

1. [HealthKit 프라이버시](#1-healthkit-프라이버시)
2. [SwiftData 데이터 보안](#2-swiftdata-데이터-보안)
3. [App Group 경계](#3-app-group-경계)
4. [알림 보안](#4-알림-보안)
5. [Swift 6 동시성 안전](#5-swift-6-동시성-안전)
6. [의존성 정책](#6-의존성-정책)
7. [일반 보안 규칙](#7-일반-보안-규칙)
8. [보안 체크리스트](#8-보안-체크리스트)

---

## 1. HealthKit 프라이버시

### 권한 범위

DrinkSomeWater는 HealthKit에서 **물 섭취량 단일 데이터 타입**만 접근한다.

| 데이터 타입 | 식별자 | 방향 |
|------------|--------|------|
| 물 섭취량 | `HKQuantityType.quantityType(forIdentifier: .dietaryWater)` | 읽기 + 쓰기 |

다른 HealthKit 카테고리(심박수, 수면, 체중 등)에 대한 권한은 절대 요청하지 않는다.

### Info.plist 필수 키

```xml
<key>NSHealthShareUsageDescription</key>
<string>건강 앱의 물 섭취 기록을 읽어 음수 목표 달성 현황을 표시합니다.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>기록한 물 섭취량을 건강 앱에 저장합니다.</string>
```

두 키 모두 반드시 존재해야 하며, 설명은 실제 사용 목적을 명확하게 기술해야 한다. 모호하거나 포괄적인 문구는 App Store 심사에서 거절될 수 있다.

### 권한 요청 시점

- 앱 시작 시 즉시 요청하지 않는다.
- 사용자가 HealthKit 연동 기능을 처음 사용하려 할 때 요청한다.
- 권한 요청 전에 왜 필요한지 맥락을 설명하는 UI를 먼저 보여준다.

```swift
// 올바른 예: 사용자 액션에 응답하여 권한 요청
func requestHealthKitPermission() async throws {
    let types: Set = [
        HKQuantityType(.dietaryWater)
    ]
    try await healthStore.requestAuthorization(toShare: types, read: types)
}
```

### 데이터 격리 원칙

- HealthKit에서 읽은 데이터를 외부 서버로 전송하지 않는다.
- HealthKit 데이터를 앱 외부에서 접근 가능한 위치에 저장하지 않는다.
- 로그, 크래시 리포트, 분석 이벤트에 HealthKit 수치를 포함하지 않는다.

### 권한 거부 시 처리

권한이 거부되거나 취소된 경우 앱이 정상적으로 동작해야 한다.

- HealthKit 없이도 앱 내부 기록만으로 음수 추적이 가능해야 한다.
- 권한 거부 상태를 UI에서 명확히 안내하고, 설정 앱으로 유도하는 옵션을 제공한다.
- 권한 없이 HealthKit API를 호출하거나 크래시가 발생해서는 안 된다.

---

## 2. SwiftData 데이터 보안

### ModelContainer 설정

`ModelContainer`는 앱 샌드박스 내 기본 경로에 데이터를 저장한다. 설정 시 다음 사항을 확인한다.

```swift
// 프로덕션 컨테이너: 영구 저장소
let container = try ModelContainer(
    for: WaterIntake.self, DailyGoal.self,
    configurations: ModelConfiguration(isStoredInMemoryOnly: false)
)
```

- `isStoredInMemoryOnly: true`는 테스트 환경에서만 사용한다. 프로덕션 빌드에 혼입되지 않도록 주의한다.

### 민감 데이터 저장 금지

SwiftData 모델에 다음 정보를 저장하지 않는다.

- 개인 식별 정보 (이름, 이메일, 전화번호)
- 위치 정보
- 기기 고유 식별자
- HealthKit에서 읽어온 원본 데이터 (앱 내부 기록과 별도 보관)

물 섭취량, 목표 설정, 알림 시간 등 앱 기능에 필요한 데이터만 저장한다.

### 마이그레이션 무결성

SwiftData 스키마 변경 시 마이그레이션 계획을 명시적으로 정의한다.

```swift
// 스키마 버전 명시적 관리
let schema = Schema([WaterIntake.self, DailyGoal.self], version: Schema.Version(2, 0, 0))
```

- 마이그레이션 중 기존 데이터가 손실되거나 변조되지 않음을 검증하는 테스트를 작성한다.
- 마이그레이션 실패 시 앱이 이전 상태로 안전하게 복구되어야 한다.

### iCloud 백업 정책

| 항목 | 설정 | 이유 |
|------|------|------|
| SwiftData 저장소 | 백업 포함 (기본값) | 사용자 데이터 보호 |
| 임시 캐시 | `isExcludedFromBackup = true` | 불필요한 백업 크기 방지 |
| 민감 중간 파일 | `isExcludedFromBackup = true` | 백업 통한 유출 방지 |

임시 파일이나 재생성 가능한 캐시에는 백업 제외를 명시적으로 설정한다.

```swift
var resourceValues = URLResourceValues()
resourceValues.isExcludedFromBackup = true
try cacheURL.setResourceValues(resourceValues)
```

---

## 3. App Group 경계

### 공유 컨테이너 식별자

| 대상 | 식별자 |
|------|--------|
| App Group | `group.com.feelso.DrinkSomeWater` |
| 메인 앱 Bundle ID | `com.feelso.DrinkSomeWater` |
| 위젯 Bundle ID | `com.feelso.DrinkSomeWater.widget` |

### 공유 범위 제한

App Group 컨테이너는 메인 앱과 위젯이 함께 접근할 수 있다. 공유 데이터를 최소화하는 것이 원칙이다.

위젯에서 접근 가능한 데이터:

| 데이터 | 키 | 타입 |
|--------|-----|------|
| 오늘 섭취량 | `todayIntake` | `Double` |
| 일일 목표량 | `dailyGoal` | `Double` |
| 마지막 업데이트 시간 | `lastUpdated` | `Date` |

위젯에서 접근하지 않는 데이터는 App Group UserDefaults에 저장하지 않는다. 메인 앱 전용 설정은 표준 `UserDefaults.standard`를 사용한다.

### UserDefaults(suiteName:) 사용 원칙

```swift
// 공유 UserDefaults: 위젯에 필요한 최소 데이터만
let sharedDefaults = UserDefaults(suiteName: "group.com.feelso.DrinkSomeWater")

// 메인 앱 전용 설정: 표준 UserDefaults 사용
let appDefaults = UserDefaults.standard
```

- App Group UserDefaults에 개인 식별 정보, 건강 수치 기록을 저장하지 않는다.
- 저장 전 키 이름을 상수로 정의하여 오타로 인한 데이터 누수를 방지한다.

```swift
enum SharedDefaultsKey {
    static let todayIntake = "todayIntake"
    static let dailyGoal = "dailyGoal"
    static let lastUpdated = "lastUpdated"
}
```

### 위젯 데이터 접근 경계

위젯 익스텐션은 읽기 전용으로 App Group 데이터를 소비한다. 위젯에서 SwiftData `ModelContainer`에 직접 쓰기 작업을 수행하지 않는다. 데이터 변경은 메인 앱을 통해서만 이루어진다.

---

## 4. 알림 보안

### 권한 요청 흐름

```swift
let center = UNUserNotificationCenter.current()
let options: UNAuthorizationOptions = [.alert, .sound, .badge]
let granted = try await center.requestAuthorization(options: options)
```

- 알림 권한은 사용자가 알림 기능을 처음 활성화하려 할 때 요청한다.
- 앱 시작 시 자동으로 요청하지 않는다.
- 권한 거부 시 알림 없이도 앱의 핵심 기능(물 섭취 기록)이 동작해야 한다.

### 알림 페이로드 규칙

로컬 알림 콘텐츠에 포함하는 정보:

| 허용 | 금지 |
|------|------|
| 일반적인 음수 리마인더 문구 | 오늘 섭취량 수치 |
| 목표 달성 격려 메시지 | 누적 건강 데이터 |
| 시간 기반 알림 텍스트 | 개인 식별 정보 |

```swift
// 올바른 예
content.title = "물 마실 시간이에요"
content.body = "목표 달성을 위해 물 한 잔 마셔보세요."

// 잘못된 예 (금지)
content.body = "오늘 \(intake)ml 마셨어요. \(remaining)ml 남았습니다."
```

알림은 단순 리마인더 역할만 한다. 구체적인 건강 수치는 앱을 열었을 때 확인하도록 유도한다.

### 알림 식별자 관리

알림 식별자에 사용자 데이터를 포함하지 않는다.

```swift
// 올바른 예
let identifier = "water.reminder.morning"

// 잘못된 예 (금지)
let identifier = "reminder.\(userId).\(intakeAmount)"
```

---

## 5. Swift 6 동시성 안전

### Sendable 준수

Swift 6 strict concurrency를 활성화하여 컴파일 타임에 data race를 감지한다.

```swift
// 올바른 예: 값 타입은 자동으로 Sendable
struct WaterEntry: Sendable {
    let amount: Double
    let timestamp: Date
}
```

- 모든 모델 타입은 `Sendable`을 명시적으로 준수하거나, 자동 합성 조건을 충족해야 한다.
- `@unchecked Sendable`은 사용을 최소화한다. 불가피하게 사용할 경우 반드시 이유를 주석으로 명시한다.

```swift
// 사용 시 반드시 사유 명시
// REASON: NSLock으로 내부 동기화가 보장됨. Swift 6 Sendable 자동 합성 불가 (NSObject 상속)
final class SomeCache: @unchecked Sendable {
    private let lock = NSLock()
    // ...
}
```

### @MainActor UI 상태 보호

모든 UI 관련 상태는 `@MainActor`로 보호한다.

```swift
@MainActor
@Observable
final class WaterViewModel {
    var todayIntake: Double = 0
    var dailyGoal: Double = 2000
    var entries: [WaterEntry] = []
}
```

- ViewModel 클래스 전체에 `@MainActor`를 적용하여 속성별 누락을 방지한다.
- `MainActor.run { }` 블록의 과도한 사용은 지양한다. 타입 수준 어노테이션으로 대체한다.

### actor로 공유 자원 보호

여러 태스크에서 동시 접근하는 공유 자원은 `actor`로 보호한다.

```swift
actor HealthKitManager {
    private let healthStore = HKHealthStore()
    
    func save(_ sample: HKQuantitySample) async throws {
        try await healthStore.save(sample)
    }
}
```

- 앱 전체에서 단일 `HealthKitManager` 인스턴스를 사용한다.
- actor 내부에서 UI 업데이트를 직접 수행하지 않는다. 결과를 반환하고 `@MainActor` 컨텍스트에서 처리한다.

### 구조적 동시성 우선

```swift
// 권장: 구조적 동시성
async let intake = fetchTodayIntake()
async let goal = fetchDailyGoal()
let (todayIntake, dailyGoal) = try await (intake, goal)

// 지양: 비구조적 Task 남발
Task { await fetchTodayIntake() }
Task { await fetchDailyGoal() }
```

비구조적 `Task { }`는 생명주기 관리가 어렵다. `async let`, `TaskGroup`, `.task` 뷰 모디파이어를 우선 사용한다.

---

## 6. 의존성 정책

### Apple 1st-party 프레임워크 전용

DrinkSomeWater는 외부 의존성을 사용하지 않는다. 사용 프레임워크:

| 프레임워크 | 용도 |
|-----------|------|
| SwiftUI | UI 구성 |
| SwiftData | 로컬 데이터 영속성 |
| WidgetKit | 위젯 |
| HealthKit | 물 섭취량 읽기/쓰기 |
| UserNotifications | 음수 리마인더 알림 |

Apple 프레임워크만 사용하는 이유:

- **공급망 공격 노출 없음**: 외부 패키지 저장소 침해 사고로 인한 악성 코드 유입 경로가 없다.
- **감사 가능성**: Apple이 관리하는 소스 코드는 플랫폼 차원에서 검증된다.
- **업데이트 의존성 없음**: 외부 패키지 버전 충돌이나 유지보수 중단 위험이 없다.

### 3rd-party 의존성 추가 시 검토 절차

외부 의존성 추가가 필요해진 경우 다음 절차를 따른다.

1. **필요성 검토**: Apple 프레임워크나 직접 구현으로 대체 가능한지 먼저 확인한다.
2. **소스 감사**: 패키지 소스 코드를 직접 검토한다. 바이너리 전용 배포 패키지는 사용하지 않는다.
3. **권한 검토**: 패키지가 요청하거나 접근하는 시스템 권한을 확인한다.
4. **유지보수 상태 확인**: 최근 커밋 이력, 이슈 대응 현황, 보안 취약점 공개 이력을 확인한다.
5. **최소 범위 적용**: 필요한 기능만 사용하고, 패키지 전체를 앱에 노출하지 않는다.
6. **잠금 파일 커밋**: `Package.resolved`를 반드시 커밋하여 버전을 고정한다.

### 공급망 공격 방어

- Swift Package Manager의 checksum 검증을 활성화한다.
- 신뢰할 수 없는 미러나 포크된 저장소를 사용하지 않는다.
- 의존성 업데이트는 변경 로그와 diff를 검토한 후 적용한다.

---

## 7. 일반 보안 규칙

### 하드코딩된 시크릿 금지

소스 코드, Info.plist, 설정 파일에 다음을 포함하지 않는다.

- API 키, 시크릿 키, 토큰
- 비밀번호, 패스프레이즈
- 내부 서버 주소나 엔드포인트 (현재 앱은 네트워크 기능 없음)

```swift
// 금지
let apiKey = "sk-1234abcd..."

// 현재 앱에는 외부 API 연동이 없으므로 위 상황 자체가 발생하면 안 됨
```

### Info.plist 프라이버시 키 완전성

앱이 접근하는 모든 시스템 리소스에 대한 사용 목적 설명 키가 Info.plist에 존재해야 한다.

| 권한 | 키 |
|------|-----|
| HealthKit 읽기 | `NSHealthShareUsageDescription` |
| HealthKit 쓰기 | `NSHealthUpdateUsageDescription` |

새로운 시스템 권한을 추가할 때 Info.plist 키를 함께 추가한다. 키 누락은 App Store 심사 거절 사유가 된다.

### 디버그/릴리즈 빌드 분리

```swift
#if DEBUG
// 디버그 전용 코드: 절대 릴리즈 빌드에 포함되지 않음
print("오늘 섭취량: \(intake)ml")
#endif
```

- 디버그 로그, 테스트 계정, 개발용 플래그는 `#if DEBUG` 블록 안에만 둔다.
- 릴리즈 빌드에서 디버그 정보가 유출되지 않도록 반드시 조건부 컴파일을 사용한다.

### 로깅 보안

```swift
// 금지: 민감 정보 로깅
os_log("사용자 섭취량: %{public}d", intake)

// 허용: 일반 이벤트 로깅
os_log("음수 기록 저장 완료", log: .default, type: .info)
```

- `os_log`의 `%{public}` 지정자는 민감 데이터에 사용하지 않는다.
- HealthKit 수치, 개인 목표 데이터는 로그에 포함하지 않는다.
- 프로덕션 빌드에서 `print()` 문이 남아있지 않도록 린트 규칙을 적용한다.

---

## 8. 보안 체크리스트

릴리즈 전 또는 보안 감사 시 아래 항목을 기계적으로 검증한다.

### 코드 검사

```bash
# 하드코딩된 시크릿 탐색 (결과 없어야 함)
grep -r "password\|secret\|apiKey\|api_key\|token\|private_key" \
  --include="*.swift" --include="*.plist" .

# print() 문 탐색 (릴리즈 빌드에 없어야 함)
grep -r "^[^/]*print(" --include="*.swift" .

# @unchecked Sendable 사용 목록 확인 (각 사용처에 주석 있어야 함)
grep -rn "@unchecked Sendable" --include="*.swift" .
```

### Info.plist 검사

```bash
# NSHealthShareUsageDescription 키 존재 확인
/usr/libexec/PlistBuddy -c "Print NSHealthShareUsageDescription" \
  DrinkSomeWater/Info.plist

# NSHealthUpdateUsageDescription 키 존재 확인
/usr/libexec/PlistBuddy -c "Print NSHealthUpdateUsageDescription" \
  DrinkSomeWater/Info.plist
```

### 체크리스트 항목

| 항목 | 확인 방법 | 기대 결과 |
|------|-----------|-----------|
| 하드코딩된 시크릿 없음 | `grep` 탐색 | 결과 없음 |
| `NSHealthShareUsageDescription` 존재 | PlistBuddy 조회 | 값 출력 |
| `NSHealthUpdateUsageDescription` 존재 | PlistBuddy 조회 | 값 출력 |
| HealthKit 권한 범위가 `.dietaryWater`만 포함 | 코드 리뷰 | 다른 HKQuantityTypeIdentifier 없음 |
| App Group ID가 `group.com.feelso.DrinkSomeWater`로 일치 | Entitlements 파일 확인 | 메인 앱/위젯 일치 |
| `@unchecked Sendable` 사용처에 사유 주석 있음 | 코드 리뷰 | 모든 사용처에 `REASON:` 주석 |
| 알림 콘텐츠에 수치 데이터 없음 | 코드 리뷰 | body에 intake 변수 없음 |
| `#if DEBUG` 외부에 `print()` 없음 | `grep` 탐색 | 결과 없음 |
| 3rd-party 의존성 없음 | `Package.swift` 확인 | dependencies 배열 비어있음 |
| 위젯에서 SwiftData 직접 쓰기 없음 | 코드 리뷰 | 위젯 타겟에 ModelContext 저장 코드 없음 |
| 공유 UserDefaults 키가 `SharedDefaultsKey` 상수 사용 | 코드 리뷰 | 문자열 리터럴 직접 사용 없음 |
| 릴리즈 빌드에서 Swift strict concurrency 경고 없음 | `xcodebuild` 빌드 로그 | 경고 0건 |

---

*최종 업데이트: 2026-04-27*
*대상 프로젝트: DrinkSomeWater (`com.feelso.DrinkSomeWater`) – Swift 6, Xcode 16+*
