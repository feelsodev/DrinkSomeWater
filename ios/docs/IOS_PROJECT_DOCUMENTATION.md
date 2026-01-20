# 벌컥벌컥 (Gulp) - iOS 프로젝트 상세 문서

> 💧 물 섭취 추적 iOS & watchOS 앱 완전 가이드
> 
> **이 문서는 iOS/watchOS 플랫폼 전용입니다.** Android 문서는 `android/` 폴더를 참조하세요.

**최종 업데이트**: 2026년 1월 20일  
**버전**: 26.2.0  
**작성자**: Auto-generated Documentation

---

## 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [기술 스택](#2-기술-스택)
3. [도메인 모델](#3-도메인-모델)
4. [기능 상세 명세](#4-기능-상세-명세)
5. [유저 플로우](#5-유저-플로우)
6. [비즈니스 정책](#6-비즈니스-정책)
7. [데이터 분석 (Analytics)](#7-데이터-분석-analytics)
8. [인프라 및 빌드](#8-인프라-및-빌드)

---

## 1. 프로젝트 개요

### 1.1 앱 소개

**벌컥벌컥 (Gulp)**은 사용자가 일일 물 섭취량을 간편하게 기록하고 추적할 수 있는 iOS 앱입니다. Apple Watch 연동, 홈 화면 위젯, Apple Health 동기화를 지원합니다.

### 1.2 핵심 가치

| 가치 | 설명 |
|------|------|
| **간편함** | 퀵버튼으로 탭 한 번에 물 기록 |
| **시각화** | 물결 애니메이션으로 진행도 직관적 표시 |
| **연속성** | iPhone, Apple Watch, 위젯 간 실시간 동기화 |
| **동기부여** | 10가지 랜덤 알림 메시지로 꾸준한 습관 형성 |

### 1.3 타겟 플랫폼

| 플랫폼 | 최소 버전 | 타입 |
|--------|----------|------|
| iOS | 26.0+ | 메인 앱 |
| watchOS | 11.0+ | 컴패니언 앱 |
| WidgetKit | iOS 26.0+ | 홈/잠금화면 위젯 |

> **참고**: iOS 26.0은 내부 개발 버전 넘버링입니다. 실제 배포 시 해당 연도의 최신 iOS 버전에 맞춰 조정됩니다.

### 1.4 앱 구조 개요

```
┌─────────────────────────────────────────────────────────────────┐
│                         iOS App                                  │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │  Intro (스플래시) → Onboarding (최초 1회)                │   │
│   └────────────────────────┬────────────────────────────────┘   │
│                            ▼                                     │
│   ┌─────────────┬─────────────┬─────────────┐                   │
│   │     💧      │     📅      │     ⚙️      │                   │
│   │    오늘     │    기록     │    설정     │   ← MainTabView   │
│   │  HomeView   │ HistoryView │  Settings   │                   │
│   └─────────────┴─────────────┴─────────────┘                   │
│                            │                                     │
│              ┌─────────────┼─────────────┐                      │
│              ▼             ▼             ▼                      │
│         Widget        HealthKit   WatchConnectivity             │
└──────────────┬─────────────┬─────────────┬──────────────────────┘
               │             │             │
               ▼             ▼             ▼
         홈화면 위젯     Apple Health   Apple Watch
```

---

## 2. 기술 스택

### 2.1 핵심 기술

| 카테고리 | 기술 | 버전 |
|----------|------|------|
| **언어** | Swift | 6.0 |
| **UI 프레임워크** | SwiftUI + UIKit | - |
| **아키텍처** | @Observable Store Pattern | - |
| **동시성** | async/await, Swift Concurrency | - |
| **빌드 시스템** | Tuist | 4.x |

### 2.2 외부 의존성

| 패키지 | 버전 | 용도 |
|--------|------|------|
| **Firebase iOS SDK** | 11.0.0+ | Analytics, Crashlytics, RemoteConfig |
| **Google Mobile Ads** | 11.2.0+ | 네이티브 광고, 리워드 광고 |
| **SnapKit** | 5.7.0+ | Auto-layout DSL (UIKit) |
| **FSCalendar** | 2.8.4+ | 캘린더 UI 컴포넌트 |

### 2.3 시스템 프레임워크

| 프레임워크 | 용도 |
|------------|------|
| **HealthKit** | 체중 읽기, 물 섭취량 동기화 |
| **WidgetKit** | 홈화면/잠금화면 위젯 |
| **WatchConnectivity** | iPhone ↔ Watch 실시간 동기화 |
| **UserNotifications** | 로컬 푸시 알림 |
| **AppIntents** | 인터랙티브 위젯 버튼 |

### 2.4 아키텍처 패턴: @Observable Store

ReactorKit에서 영감을 받은 단방향 데이터 흐름 아키텍처:

```swift
@MainActor
@Observable
final class HomeStore {
    enum Action {
        case refresh
        case addWater(Int)
        case subtractWater(Int)
        case resetTodayWater
    }
    
    var total: Float = 0       // 목표량
    var ml: Float = 0          // 현재 섭취량
    var progress: Float { ... } // 계산된 진행률
    
    func send(_ action: Action) async {
        switch action {
        case .addWater(let amount):
            // 물 추가 로직
        }
    }
}
```

**사용법:**
```swift
struct HomeView: View {
    @Bindable var store: HomeStore
    
    var body: some View {
        Text("\(Int(store.ml))ml")
            .task { await store.send(.refresh) }
    }
}
```

---

## 3. 도메인 모델

### 3.1 핵심 엔티티

#### WaterRecord (물 섭취 기록)

```swift
struct WaterRecord: ModelType, Identifiable {
    var id: String { date.dateToString }
    var date: Date          // 기록 날짜
    var value: Int          // 섭취량 (ml)
    var isSuccess: Bool     // 목표 달성 여부
    var goal: Int           // 해당일 목표량 (ml)
}
```

| 필드 | 타입 | 설명 | 예시 |
|------|------|------|------|
| `date` | Date | 기록 날짜/시간 | 2026-01-20 14:30:00 |
| `value` | Int | 섭취한 물의 양 (ml) | 1500 |
| `isSuccess` | Bool | 목표 달성 여부 | true |
| `goal` | Int | 해당일 목표량 (ml) | 2000 |

#### UserProfile (사용자 프로필)

```swift
struct UserProfile: Codable, Equatable {
    var weight: Double              // 체중 (kg)
    var useHealthKitWeight: Bool    // HealthKit 체중 사용 여부
    
    var recommendedIntake: Int {    // 권장 섭취량 계산
        Int(weight * 33)            // 체중(kg) × 33ml
    }
    
    static var `default`: UserProfile {
        UserProfile(weight: 65, useHealthKitWeight: false)
    }
}
```

#### NotificationSettings (알림 설정)

```swift
struct NotificationSettings {
    var isEnabled: Bool                    // 알림 활성화 여부
    var startTime: NotificationTime        // 시작 시간 (기본 08:00)
    var endTime: NotificationTime          // 종료 시간 (기본 22:00)
    var interval: NotificationInterval     // 알림 간격
    var enabledWeekdays: Set<Weekday>      // 활성화된 요일
    var customTimes: [NotificationTime]    // 커스텀 알림 시간
}

enum NotificationInterval: Int {
    case thirtyMinutes = 30    // 30분
    case oneHour = 60          // 1시간
    case twoHours = 120        // 2시간
    case threeHours = 180      // 3시간
}
```

### 3.2 상태 관리 (Stores)

#### 핵심 Stores

| Store | 파일 | 역할 | 주요 상태 |
|-------|------|------|----------|
| **HomeStore** | `HomeStore.swift` | 오늘 탭 상태 | `ml`, `total`, `progress`, `quickButtons` |
| **HistoryStore** | `HistoryStore.swift` | 기록 탭 상태 | `waterRecordList`, `successDates`, `selectedRecord` |
| **ProfileStore** | `ProfileStore.swift` | 프로필 관리 | `profile`, `dailyGoal` |
| **NotificationStore** | `NotificationStore.swift` | 알림 상태 | `isAuthorized`, `settings` |
| **OnboardingStore** | `OnboardingStore.swift` | 온보딩 상태 | `currentPage`, `goal` |
| **CalendarStore** | `CalendarStore.swift` | 캘린더 상태 | `selectedDate`, `events` |
| **InformationStore** | `InformationStore.swift` | 앱 정보 | `appVersion` |

#### 설정 관련 Stores (이름 유사 주의)

> ⚠️ **주의**: `SettingStore`와 `SettingsStore`는 **별개의 Store**로 둘 다 현재 사용 중입니다.

| Store | 파일 | 용도 | 생성 방식 |
|-------|------|------|----------|
| **SettingStore** (단수) | `SettingStore.swift` | 목표 설정 모달 전용 | `MainStore.createSettingStore()` |
| **SettingsStore** (복수) | `SettingsStore.swift` | 설정 탭 전체 관리 | 직접 생성 |

**SettingStore** (단수):
```swift
// 목표 설정 모달에서 사용, shouldDismiss 패턴
var value: Int = 0
var shouldDismiss: Bool = false
enum Action { case loadGoal, changeGoalWater(Int), setGoal, cancel }
```

**SettingsStore** (복수):
```swift
// 설정 탭에서 사용, 목표 + 퀵버튼 관리
var goalValue: Int = 2000
var quickButtons: [Int] = [100, 200, 300, 500]
enum Action { case loadGoal, updateGoal(Int), loadQuickButtons, updateQuickButtons([Int]) }
```

#### 유틸리티 Stores

| Store | 파일 | 역할 | 생성 방식 |
|-------|------|------|----------|
| **MainStore** | `MainStore.swift` | 전역 상태 + 팩토리 | 직접 생성 |
| **DrinkStore** | `DrinkStore.swift` | 물 추가 액션 | `MainStore.createDrinkStore()` |

### 3.3 서비스 레이어

| 서비스 | 프로토콜 | 역할 |
|--------|----------|------|
| **WaterService** | `WaterServiceProtocol` | 물 섭취 CRUD |
| **UserDefaultsService** | `UserDefaultsServiceProtocol` | 로컬 데이터 저장 |
| **HealthKitService** | `HealthKitServiceProtocol` | Apple Health 연동 |
| **NotificationService** | `NotificationServiceProtocol` | 푸시 알림 관리 |
| **WatchConnectivityService** | `WatchConnectivityServiceProtocol` | Watch 동기화 |
| **AlertService** | `AlertServiceProtocol` | 알림창 표시 |
| **AdMobService** | - | 광고 관리 |
| **RemoteConfigService** | - | Firebase 원격 설정 |

### 3.4 데이터 저장소 키 (UserDefaults)

| 키 | 타입 | 설명 |
|----|------|------|
| `current` | `[[String: Any]]` | 물 섭취 기록 배열 |
| `goal` | `Int` | 일일 목표량 (ml) |
| `quickButtons` | `[Int]` | 퀵버튼 설정 |
| `customQuickButtons` | `[Int]` | 커스텀 퀵버튼 설정 |
| `notificationEnabled` | `Bool` | 알림 활성화 |
| `notificationStartHour` | `Int` | 알림 시작 시간 (시) |
| `notificationStartMinute` | `Int` | 알림 시작 시간 (분) |
| `notificationEndHour` | `Int` | 알림 종료 시간 (시) |
| `notificationEndMinute` | `Int` | 알림 종료 시간 (분) |
| `notificationIntervalMinutes` | `Int` | 알림 간격 (분) |
| `notificationWeekdays` | `[Int]` | 알림 요일 |
| `notificationCustomTimes` | `[[String: Int]]` | 커스텀 알림 시간 배열 |
| `userWeight` | `Double` | 사용자 체중 (kg) |
| `useHealthKitWeight` | `Bool` | HealthKit 체중 사용 여부 |
| `notificationBannerDismissed` | `Bool` | 알림 배너 닫음 여부 |
| `onboardingCompleted` | `Bool` | 온보딩 완료 여부 |

> **Source of Truth**: `DrinkSomeWater/Sources/Services/UserDefaultsService.swift`

---

## 4. 기능 상세 명세

### 4.1 오늘 탭 (HomeView)

**목적**: 오늘의 물 섭취량을 기록하고 진행 상황을 시각화

#### 기능 목록

| 기능 | 설명 | 구현 |
|------|------|------|
| **물 섭취 기록** | 퀵버튼으로 정해진 양 추가 | `HomeStore.addWater(Int)` |
| **물 섭취 취소** | 잘못 기록한 양 빼기 | `HomeStore.subtractWater(Int)` |
| **오늘 기록 초기화** | 하루 기록 리셋 | `HomeStore.resetTodayWater` |
| **목표량 수정** | 일일 목표 변경 | `GoalSettingView` sheet |
| **퀵버튼 커스터마이징** | 버튼 추가/삭제/순서변경 | `QuickButtonSettingView` sheet |
| **진행도 시각화** | 물결 애니메이션으로 표시 | `WaveAnimationView` |
| **남은 양 표시** | 목표까지 남은 ml/컵 수 | `store.remainingMl`, `store.remainingCups` |

#### 퀵버튼 기본값

```swift
static let defaultQuickButtons = [100, 200, 300, 500]  // ml 단위
```

#### UI 컴포넌트

```
┌─────────────────────────────────────┐
│  [알림 배너 - 권한 없을 때 표시]     │
├─────────────────────────────────────┤
│           1500ml                    │  ← 현재 섭취량 (display font)
│      목표: 2000ml ✏️                │  ← 목표량 + 편집 버튼
│   💧 약 2컵 정도 더 마시면 달성!     │  ← 동기부여 메시지
├─────────────────────────────────────┤
│       ┌─────────────────┐           │
│       │    ≈≈≈≈≈≈≈     │           │  ← 물결 애니메이션 병
│       │   ≈≈≈≈≈≈≈≈≈    │           │     (진행률 시각화)
│       │  ≈≈≈≈≈≈≈≈≈≈≈   │           │
│       └─────────────────┘           │
├─────────────────────────────────────┤
│  빠른 추가 ▼     [+/-🔄] [편집]     │
│  ┌────────┐ ┌────────┐              │
│  │+100ml  │ │+200ml  │              │  ← 퀵버튼 (2행)
│  └────────┘ └────────┘              │
│  ┌────────┐ ┌────────┐              │
│  │+300ml  │ │+500ml  │              │
│  └────────┘ └────────┘              │
└─────────────────────────────────────┘
```

### 4.2 기록 탭 (HistoryView)

**목적**: 과거 물 섭취 기록을 다양한 뷰 모드로 확인

#### 뷰 모드

| 모드 | 아이콘 | 설명 |
|------|--------|------|
| **캘린더** | 📅 | FSCalendar로 월별 달성 현황 |
| **리스트** | 📋 | 최신순 정렬된 기록 목록 |
| **타임라인** | 🕐 | 월별 그룹화된 타임라인 |

#### 캘린더 모드 기능

- 달성일 하이라이트 (primary color)
- 날짜 선택 시 상세 카드 표시
- 이번 달 달성 통계 배지

#### 리스트 모드 기능

- 최신순 정렬
- 각 기록별 진행도 바
- 5개 기록마다 네이티브 광고 삽입

#### 타임라인 모드 기능

- 월별 섹션 그룹화
- 수직 타임라인 UI
- 월별 달성 통계 표시

### 4.3 설정 탭 (SettingsViewController)

**목적**: 앱 설정 및 사용자 프로필 관리

#### 설정 항목

| 섹션 | 항목 | 설명 |
|------|------|------|
| **프로필** | 일일 목표량 | 1,000ml ~ 4,500ml (100ml 단위) |
| | 퀵버튼 설정 | 커스텀 버튼 추가/삭제/순서변경 |
| | Apple Health | 체중 동기화, 물 섭취 기록 |
| **알림** | 알림 설정 | 시간, 간격, 요일 설정 |
| **정보** | 위젯 가이드 | 위젯 설치 방법 안내 |
| | 앱 평가 | App Store 리뷰 링크 |
| | 문의하기 | 이메일 링크 |
| | 버전 | 현재 앱 버전 표시 |

### 4.4 온보딩

**목적**: 최초 실행 시 앱 사용법 안내 및 초기 설정

#### 온보딩 페이지 (5단계)

| 순서 | 페이지 | 내용 |
|------|--------|------|
| 1 | **인트로** | 앱 소개 및 환영 메시지 |
| 2 | **목표 설정** | 슬라이더로 일일 목표량 설정 |
| 3 | **HealthKit** | Apple Health 연동 권한 요청 |
| 4 | **알림** | 푸시 알림 권한 요청 |
| 5 | **위젯** | 홈 화면 위젯 설치 안내 |

#### 온보딩 플로우

```
[인트로] → [목표설정] → [HealthKit] → [알림] → [위젯] → [메인앱]
    ↓ (스킵 가능)                                         ↓
    └──────────────── 온보딩 완료 플래그 저장 ────────────┘
```

### 4.5 홈 화면 위젯

**목적**: 앱을 열지 않고도 물 섭취량 확인 및 기록

#### 위젯 종류

| 크기 | 기능 | 인터랙티브 |
|------|------|-----------|
| **Small** | 원형 진행도 + 퍼센트 + 섭취량 | ❌ |
| **Medium** | 진행도 + 빠른 추가 버튼 2개 | ✅ (150ml, 300ml) |
| **Large** | 진행도 + 동기부여 메시지 + 버튼 3개 | ✅ (150ml, 300ml, 500ml) |
| **잠금화면 Circular** | 원형 게이지 | ❌ |
| **잠금화면 Rectangular** | 섭취량/목표량 표시 | ❌ |
| **잠금화면 Inline** | 텍스트 형태 | ❌ |

#### 데이터 동기화

```swift
// App Group을 통한 데이터 공유
WidgetDataManager.shared.syncFromMainApp(todayWater: value, goal: goal)
WidgetCenter.shared.reloadAllTimelines()
```

### 4.6 Apple Watch 앱

**목적**: 손목에서 바로 물 섭취량 기록

#### Watch 화면

| 화면 | 기능 |
|------|------|
| **홈** | 오늘 섭취량, 목표, 진행률 표시 |
| **퀵 추가** | 150ml, 250ml, 300ml, 500ml 버튼 |
| **직접 입력** | 50ml 단위 조절 |

#### Watch 컴플리케이션

| 타입 | 표시 내용 |
|------|----------|
| **Circular** | 진행률 게이지 |
| **Rectangular** | 섭취량/목표량 상세 |
| **Corner** | 아이콘 + 퍼센트 |
| **Inline** | 텍스트 형태 |

#### iPhone ↔ Watch 동기화

```swift
// iPhone → Watch
watchConnectivityService.syncToWatch(todayWater: value, goal: goal)

// Watch → iPhone (양방향)
session.sendMessage(["action": "addWater", "amount": 150], ...)
```

### 4.7 알림 시스템

**목적**: 정기적인 물 마시기 리마인더

#### 알림 메시지 (10가지 랜덤)

```swift
static let messages = [
    "물 마실 시간이에요! 💧",
    "집중력 UP! 물 한 잔 어때요? 🧠",
    "건강한 하루를 위해 물 한 잔! 🌿",
    "수분 보충 타임~ 💦",
    "물 마시고 상쾌하게! ✨",
    "하루 목표까지 파이팅! 💪",
    "물 한 잔의 여유를 가져보세요 🍃",
    "건강을 위한 작은 습관, 물 마시기 💙",
    "지금 물 한 잔 어때요? 🥤",
    "수분 충전! 물을 마셔요 💧"
]
```

#### 알림 스케줄링 정책

- **최대 알림 수**: 64개 (iOS 제한)
- **스케줄링 방식**: 요일별 × 시간대별 조합
- **간격 옵션**: 30분, 1시간, 2시간, 3시간
- **시간대**: 시작~종료 시간 내에서만 발송

---

## 5. 유저 플로우

### 5.1 최초 실행 플로우

```
앱 설치 → 앱 실행 → Intro (스플래시)
                         ↓
                    온보딩 시작
                         ↓
            ┌─────────────────────────┐
            │   1. 앱 소개 페이지      │
            │   2. 목표량 설정         │
            │   3. HealthKit 권한      │
            │   4. 알림 권한           │
            │   5. 위젯 가이드         │
            └───────────┬─────────────┘
                        ↓
               온보딩 완료 플래그 저장
                        ↓
                  메인 앱 진입
                (HomeView - 오늘 탭)
```

### 5.2 일일 사용 플로우

```
앱 실행 → 오늘 탭 (HomeView)
              │
              ├── [퀵버튼 탭] → 물 추가 → 위젯/Watch 동기화
              │                            → Analytics 이벤트
              │                            → HealthKit 저장
              │
              ├── [+/- 토글] → 빼기 모드 → 물 빼기
              │
              ├── [목표 수정] → 시트 표시 → 목표 저장
              │
              └── [퀵버튼 편집] → 버튼 추가/삭제/순서변경
```

### 5.3 기록 확인 플로우

```
기록 탭 (HistoryView)
      │
      ├── [캘린더 모드] → 날짜 탭 → 해당일 기록 카드 표시
      │                          → Analytics: calendar_date_selected
      │
      ├── [리스트 모드] → 스크롤 → 기록 확인
      │                        → 5개마다 광고 표시
      │
      └── [타임라인 모드] → 월별 그룹 확인
```

### 5.4 Watch 사용 플로우

```
Watch 앱 실행 → 홈 화면 (진행률 표시)
                    │
                    ├── [퀵 추가] → 버튼 탭 → 물 추가
                    │                        → iPhone 동기화
                    │
                    └── [직접 입력] → 양 조절 → 확인 → 물 추가
```

### 5.5 위젯 사용 플로우

```
홈 화면 → 위젯 확인 (진행률)
             │
             └── [Medium/Large 위젯] → 버튼 탭
                                          ↓
                                     AddWaterIntent 실행
                                          ↓
                                     물 추가 + 위젯 갱신
```

---

## 6. 비즈니스 정책

### 6.1 물 섭취 관련 정책

| 정책 | 규칙 |
|------|------|
| **기본 목표량** | 2,000ml (온보딩에서 변경 가능) |
| **목표량 범위** | 1,000ml ~ 4,500ml (100ml 단위) |
| **권장량 계산** | 체중(kg) × 33 = 권장 섭취량(ml) |
| **기본 퀵버튼** | 100ml, 200ml, 300ml, 500ml |
| **기록 단위** | 1ml 단위 (퀵버튼은 사용자 설정) |
| **일일 리셋** | 자정에 새로운 WaterRecord 생성 |

### 6.2 목표 달성 판정

```swift
// 목표 달성 조건
isSuccess = (todayValue >= dailyGoal)

// 연속 달성일 계산 (스트릭)
func calculateStreak() -> Int {
    // 오늘부터 역순으로 연속 달성일 카운트
    // 하루라도 빠지면 스트릭 리셋
}
```

### 6.3 알림 정책

| 정책 | 값 | 소스 |
|------|-----|------|
| **기본 시작 시간** | 08:00 | `NotificationSettings.default` |
| **기본 종료 시간** | 22:00 | `NotificationSettings.default` |
| **기본 간격** | 1시간 (`.oneHour`) | `NotificationSettings.default` |
| **서비스 폴백 간격** | 2시간 (120분) | `NotificationService.loadSettings()` |
| **기본 요일** | 월~일 (모든 요일) | `Weekday.allCases` |
| **최대 알림 수** | 64개 (iOS 제한) | `maxPendingNotifications` |
| **알림 메시지** | 10가지 중 랜덤 선택 | `NotificationMessages.random` |

> **참고**: `NotificationSettings.default`는 `.oneHour`(1시간)를 사용하지만, `NotificationService.loadSettings()`의 폴백 값은 120분(2시간)입니다. 실제 동작은 저장된 값 → 서비스 폴백 순서로 결정됩니다.

### 6.4 데이터 동기화 정책

| 동기화 대상 | 타이밍 | 방향 |
|------------|--------|------|
| **위젯** | 물 추가/변경 즉시 | 앱 → 위젯 |
| **Watch** | 물 추가/변경 즉시 | 양방향 |
| **HealthKit** | 물 추가 시 | 앱 → Health |
| **오프라인 Watch** | Watch 미연결 시 | 펜딩 후 재연결 시 동기화 |

#### 위젯 인터랙티브 동기화 흐름

위젯에서 물을 추가할 때 앱이 실행 중이지 않을 수 있으므로, **펜딩 메커니즘**을 사용합니다:

```
[위젯 버튼 탭]
      │
      ▼
[AddWaterIntent 실행]
      │
      ▼
[WidgetDataManager.addWater(amount)]
      │
      ├─ todayWater += amount (즉시 반영)
      ├─ needsSync = true (펜딩 플래그)
      └─ pendingWater = amount (펜딩 양)
      │
      ▼
[앱 다음 실행 시]
      │
      ▼
[WidgetDataManager.checkPendingWaterFromWidget()]
      │
      ├─ pendingWater 반환
      └─ needsSync = false, pendingWater = 0 (초기화)
      │
      ▼
[WaterService.updateWater(pendingWater)]
```

**소스**: `Shared/WidgetDataManager.swift:69-100`

### 6.5 광고 정책

| 광고 유형 | 위치 | 빈도 |
|----------|------|------|
| **네이티브 광고** | 기록 리스트 | 5개 기록마다 1개 |
| **리워드 광고** | 설정 (선택적) | 사용자 요청 시 |

### 6.6 데이터 보존 정책

- **로컬 저장**: UserDefaults + App Group
- **기록 보존**: 무제한 (삭제 기능 없음)
- **백업**: iCloud 백업에 포함
- **동기화 충돌**: 최신 타임스탬프 우선

---

## 7. 데이터 분석 (Analytics)

### 7.1 Analytics 모듈 구조

```
Analytics/
├── Sources/
│   ├── Analytics.swift              # 싱글톤 서비스
│   ├── AnalyticsEvent.swift         # 이벤트 정의 (50+ 이벤트)
│   └── AnalyticsUserProperty.swift  # 사용자 속성 정의
```

### 7.2 이벤트 티어 (우선순위)

#### Tier 1: 핵심 이벤트 (Core Events)

| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `water_intake` | `amount_ml`, `method`, `hour` | 물 추가 시 |
| `goal_achieved` | `goal_ml`, `actual_ml`, `streak_days` | 목표 달성 시 |
| `goal_failed` | `goal_ml`, `actual_ml`, `percentage` | 자정에 미달성 시 |
| `app_open` | `hour`, `day_of_week`, `days_since_install` | 앱 실행 시 |
| `screen_view` | `screen_name`, `previous_screen` | 화면 전환 시 |

#### Tier 2: 온보딩 퍼널

| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `onboarding_started` | `source` | 온보딩 시작 |
| `onboarding_step_viewed` | `step` | 각 단계 진입 |
| `onboarding_step_completed` | `step`, `time_spent_sec` | 각 단계 완료 |
| `onboarding_skipped` | `step` | 스킵 버튼 탭 |
| `onboarding_completed` | `total_time_sec` | 온보딩 완료 |
| `first_water_intake` | `amount_ml`, `minutes_since_install` | 첫 물 기록 |
| `permission_requested` | `type` (notification/healthkit) | 권한 요청 |
| `permission_granted` | `type` | 권한 승인 |
| `permission_denied` | `type` | 권한 거부 |

#### Tier 3: 기능 사용

| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `water_subtracted` | `amount_ml` | 물 빼기 |
| `water_reset` | `previous_amount_ml` | 오늘 리셋 |
| `quick_button_tap` | `amount_ml`, `button_index`, `is_custom` | 퀵버튼 탭 |
| `goal_changed` | `old_goal`, `new_goal`, `source` | 목표 변경 |
| `goal_quick_set_used` | `new_goal` | 퀵 목표 설정 |
| `quick_button_customized` | `button_index`, `amount_ml` | 버튼 커스텀 |
| `calendar_viewed` | `month`, `year` | 캘린더 뷰 |
| `calendar_date_selected` | `date`, `had_records`, `was_achieved` | 날짜 선택 |
| `notification_setting_changed` | `enabled`, `start_time`, `end_time`, `interval_hours` | 알림 설정 변경 |
| `widget_added` | `widget_type` | 위젯 추가 |
| `widget_interaction` | `widget_type`, `action`, `amount_ml` | 위젯 상호작용 |

#### Tier 4: HealthKit

| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `healthkit_connected` | - | 연결 성공 |
| `healthkit_disconnected` | `reason` | 연결 해제 |
| `healthkit_sync_success` | `record_count`, `sync_type` | 동기화 성공 |
| `healthkit_sync_failed` | `error_code`, `error_message` | 동기화 실패 |
| `weight_updated` | `weight_kg`, `source` | 체중 업데이트 |
| `recommended_goal_accepted` | `recommended_ml`, `weight_kg` | 권장량 수락 |
| `recommended_goal_rejected` | `recommended_ml`, `custom_ml` | 권장량 거부 |

#### Tier 5: 리텐션

| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `streak_achieved` | `streak_days` | 연속 달성 |
| `streak_broken` | `previous_streak_days` | 스트릭 깨짐 |
| `notification_received` | `notification_id`, `message_type` | 알림 수신 |
| `notification_tapped` | `notification_id`, `time_to_tap_sec` | 알림 탭 |
| `notification_dismissed` | `notification_id` | 알림 닫음 |
| `inactive_return` | `days_inactive` | 비활성 후 복귀 |

#### Tier 6: 수익화

**광고 이벤트 (현재 구현됨)**:

| 이벤트 | 파라미터 | 트리거 |
|--------|----------|--------|
| `ad_impression` | `ad_type`, `ad_unit_id`, `screen` | 광고 노출 |
| `ad_clicked` | `ad_type`, `ad_unit_id` | 광고 클릭 |
| `ad_closed` | `ad_type`, `view_duration_sec` | 광고 닫음 |
| `rewarded_ad_started` | `reward_type` | 리워드 광고 시작 |
| `rewarded_ad_completed` | `reward_type`, `reward_amount` | 리워드 완료 |

**인앱 구매 이벤트 (Analytics 모듈에 정의됨, StoreKit 미구현)**:

| 이벤트 | 파라미터 | 상태 |
|--------|----------|------|
| `premium_prompt_shown` | `trigger_point`, `variant` | 🔮 향후 구현 예정 |
| `purchase_started` | `product_id`, `price` | 🔮 향후 구현 예정 |
| `purchase_completed` | `product_id`, `price`, `currency` | 🔮 향후 구현 예정 |
| `purchase_failed` | `product_id`, `error_code` | 🔮 향후 구현 예정 |

> **참고**: 인앱 구매 이벤트는 `AnalyticsEvent.swift`에 정의되어 있으나, 현재 앱에는 StoreKit 구현이 없습니다. 이는 향후 프리미엄 기능 도입을 위한 사전 정의입니다.

### 7.3 사용자 속성 (User Properties)

| 속성 | 타입 | 설명 |
|------|------|------|
| `daily_goal_ml` | Int | 일일 목표량 |
| `weight_kg` | Double | 체중 |
| `notification_enabled` | Bool | 알림 활성화 여부 |
| `healthkit_enabled` | Bool | HealthKit 연동 여부 |
| `onboarding_completed` | Bool | 온보딩 완료 여부 |
| `days_since_install` | Int | 설치 후 일수 |
| `total_intake_count` | Int | 총 기록 횟수 |
| `current_streak` | Int | 현재 연속 달성일 |
| `user_segment` | String | 사용자 세그먼트 (light/medium/heavy) |
| `premium_status` | String | 프리미엄 상태 (free/premium) |
| `app_version` | String | 앱 버전 |
| `ios_version` | String | iOS 버전 |

### 7.4 이벤트 흐름도

```
[사용자 액션]
      │
      ▼
[Store.send(action)]
      │
      ▼
[비즈니스 로직 실행]
      │
      ▼
[Analytics.shared.log(event)]
      │
      ├─ #if canImport(FirebaseAnalytics) ──→ Firebase Analytics 전송 (항상)
      │
      └─ #if DEBUG ──→ Console 출력 (추가)
```

> **중요**: Firebase Analytics 전송은 `canImport(FirebaseAnalytics)` 조건으로 결정되며, 빌드 설정(Debug/Release)과 무관합니다. `ENABLE_ANALYTICS` xcconfig 플래그는 현재 코드에서 실제로 체크되지 않습니다. Debug 빌드에서는 Firebase 전송과 함께 Console에도 출력됩니다.
>
> **소스**: `Analytics/Sources/Analytics.swift:29-36`

### 7.5 핵심 분석 지표

| 지표 | 정의 | 활용 |
|------|------|------|
| **DAU** | 일일 활성 사용자 | 일일 참여도 |
| **물 섭취 빈도** | 일일 평균 기록 횟수 | 참여도 지표 |
| **목표 달성률** | 목표 달성 일수 / 활성 일수 | 핵심 KPI |
| **스트릭 분포** | 연속 달성일 분포 | 리텐션 지표 |
| **온보딩 완료율** | 완료 / 시작 | 퍼널 분석 |
| **알림 CTR** | 탭 / 수신 | 알림 효과 |
| **위젯 사용률** | 위젯 물추가 / 전체 물추가 | 기능 채택률 |

---

## 8. 인프라 및 빌드

### 8.1 빌드 시스템

| 항목 | 값 |
|------|-----|
| **빌드 툴** | Tuist 4 |
| **버전 관리** | mise (`.mise.toml`) |
| **Swift 버전** | 6.0 |
| **iOS 타겟** | 26.0+ |
| **watchOS 타겟** | 11.0+ |

### 8.2 프로젝트 타겟

| 타겟 | 타입 | 번들 ID |
|------|------|---------|
| **DrinkSomeWater** | iOS App | `com.onceagain.DrinkSomeWater` |
| **DrinkSomeWaterWidget** | App Extension | `com.onceagain.DrinkSomeWater.Widget` |
| **DrinkSomeWaterWatch** | watchOS App | `com.onceagain.DrinkSomeWater.watchkitapp` |
| **Analytics** | Framework | `com.onceagain.DrinkSomeWater.Analytics` |
| **DrinkSomeWaterTests** | Unit Tests | `com.feelso.DrinkSomeWaterTests` |

### 8.3 빌드 설정

#### Debug 설정

```xcconfig
APP_BUNDLE_ID = com.onceagain.DrinkSomeWater.debug
APP_NAME = DrinkSomeWater-Dev
ADMOB_APP_ID = ca-app-pub-3940256099942544~1458002511  // 테스트 ID
ENABLE_ANALYTICS = NO
ENABLE_DEBUG_MENU = YES
LOG_LEVEL = verbose
```

#### Release 설정

```xcconfig
APP_BUNDLE_ID = com.onceagain.DrinkSomeWater
APP_NAME = DrinkSomeWater
ADMOB_APP_ID = ca-app-pub-8353974542825246~9138292219  // 프로덕션 ID
ENABLE_ANALYTICS = YES
ENABLE_DEBUG_MENU = NO
LOG_LEVEL = error
```

### 8.4 CI/CD

#### Xcode Cloud

```bash
# ci_scripts/ci_post_clone.sh
mise install           # Tuist 설치
tuist install          # SPM 의존성 설치
tuist generate --no-open  # 프로젝트 생성
```

```bash
# ci_scripts/ci_post_xcodebuild.sh
# dSYM을 Firebase Crashlytics에 업로드
```

#### GitHub Actions

| 워크플로우 | 트리거 | 기능 |
|-----------|--------|------|
| **auto-tag.yml** | 수동 | 버전 태그 + GitHub Release 생성 |
| **update-version.yml** | 수동 | 버전 업데이트 PR 생성 |

### 8.5 버전 관리

```
버전 형식: YY.WW.N
- YY: 연도 (25 = 2025)
- WW: 주차 (1~52)
- N: 패치 번호

예: 26.2.0 = 2026년 2주차, 첫 번째 릴리스
```

### 8.6 빌드 명령어

```bash
# 개발 환경 설정
mise install tuist

# 프로젝트 생성
tuist install
tuist generate

# 빌드
tuist build

# 테스트
tuist test

# Xcode 열기
open DrinkSomeWater.xcworkspace
```

### 8.7 Entitlements

| 타겟 | 권한 |
|------|------|
| **Main App** | HealthKit, App Groups |
| **Widget** | App Groups |
| **Watch** | App Groups |

**App Group ID**: `group.com.onceagain.DrinkSomeWater`

### 8.8 테스트

| 모듈 | 테스트 파일 | 케이스 수 |
|------|------------|----------|
| HomeStore | HomeStoreTests.swift | 12 |
| WaterService | WaterServiceTests.swift | 13 |
| HistoryStore | HistoryStoreTests.swift | 8 |
| ProfileStore | ProfileStoreTests.swift | 12 |
| Notification | NotificationTests.swift | 10 |
| Models | DrinkSomeWaterTests.swift | 11 |

**총 테스트**: 53+ 케이스

---

## 부록

### A. 디자인 시스템 (DesignTokens)

```swift
typealias DS = DesignTokens

// Spacing
DS.Spacing.xs     // 8pt
DS.Spacing.sm     // 12pt
DS.Spacing.md     // 16pt
DS.Spacing.lg     // 20pt
DS.Spacing.xl     // 24pt

// Corner Radius
DS.Size.cornerRadiusSmall   // 8pt
DS.Size.cornerRadiusMedium  // 12pt
DS.Size.cornerRadiusLarge   // 16pt
DS.Size.cornerRadiusPill    // 32pt

// Colors
DS.Color.primary        // #59BFF2 (메인 파란색)
DS.Color.success        // #59C79E (성공 녹색)
DS.Color.textPrimary    // #333340 (주요 텍스트)
DS.Color.textSecondary  // #808088 (보조 텍스트)
DS.Color.backgroundPrimary  // #F5F5F8 (배경)
```

### B. 로컬라이제이션 키

| 키 | 한국어 | 영어 |
|----|--------|------|
| `home.goal` | 목표: %@ml | Goal: %@ml |
| `home.goal.achieved` | 오늘 목표 달성! | Goal achieved! |
| `home.goal.remaining` | 약 %@컵 더 마시면 달성! | %@ more cups to go! |
| `history.title` | 기록 | History |
| `settings.title` | 설정 | Settings |

### C. 파일 구조

```
DrinkSomeWater/
├── DrinkSomeWater/           # iOS 메인 앱
│   ├── Sources/
│   │   ├── Views/            # SwiftUI 뷰
│   │   ├── Stores/           # @Observable Store
│   │   ├── Services/         # 비즈니스 로직
│   │   ├── Models/           # 데이터 모델
│   │   ├── ViewComponent/    # 재사용 컴포넌트
│   │   ├── ViewController/   # UIKit 컨트롤러
│   │   ├── DesignSystem/     # 디자인 토큰
│   │   └── Extensions-Utilities/
│   └── Resources/
├── DrinkSomeWaterWatch/      # watchOS 앱
├── DrinkSomeWaterWidget/     # 위젯
├── Analytics/                # Analytics 모듈
├── DrinkSomeWaterTests/      # 테스트
├── Shared/                   # 공유 코드
├── Tuist/                    # 빌드 설정
└── docs/                     # 문서
```

---

**문서 끝**
