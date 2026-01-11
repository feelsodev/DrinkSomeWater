# DrinkSomeWater Technical Specification

> SwiftUI + UIKit + @Observable + async/await 아키텍처

## 1. Overview

### 1.1 Project Summary
- **App Name**: 벌컥벌컥 (Gulp) - 물 섭취 추적 iOS 앱
- **Architecture**: SwiftUI + UIKit + @Observable Store + async/await
- **Min iOS**: iOS 26+
- **Swift**: Swift 6
- **UI Framework**: SwiftUI (Home, History), UIKit (Settings, Onboarding)

### 1.2 Core Features
| Feature | Description |
|---------|-------------|
| 물 섭취 기록 | 퀵버튼으로 간편하게 물 섭취량 기록 |
| 물 빼기/초기화 | 잘못 기록한 양 수정 및 하루 기록 리셋 |
| 목표량 설정 | 일일 목표량 커스텀 설정 (1,000~4,000ml) |
| 기록 조회 | 캘린더/리스트/타임라인 3가지 뷰 모드 |
| 퀵버튼 커스텀 | 자주 마시는 용량 설정 (추가/삭제/정렬) |
| HealthKit 연동 | Apple 건강앱과 물 섭취량/체중 동기화 |
| 개인화 권장량 | 체중 기반 일일 권장 물 섭취량 계산 |
| 랜덤 알림 문구 | 10가지 로컬라이징된 동기부여 문구 |
| 홈 화면 위젯 | Small/Medium/Large 크기 위젯 |
| 잠금화면 위젯 | Circular/Rectangular/Inline 위젯 |
| 인터랙티브 위젯 | AppIntent로 위젯에서 바로 물 추가 |
| 온보딩 플로우 | 5단계 앱 소개 및 설정 가이드 |
| Watch 앱 | 손목에서 물 섭취 기록 및 컴플리케이션 |
| Native Ad | 기록 리스트에 네이티브 광고 표시 |

---

## 2. Architecture

### 2.1 App Flow

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   Intro (스플래시)                                          │
│         │                                                   │
│         ▼                                                   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              🆕 온보딩 (최초 실행 시)                │   │
│   │  [앱 소개] → [목표 설정] → [HealthKit] → [알림] → [위젯] │
│   │                    (스킵 가능)                       │   │
│   └─────────────────────────────────────────────────────┘   │
│         │                                                   │
│         ▼                                                   │
│   ┌─────────────────────────────────────────────────────┐   │
│   │                                                     │   │
│   │              [ 메인 컨텐츠 ]                        │   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                             │
│   ┌─────────────┬─────────────┬─────────────┐               │
│   │     💧      │     📅      │     ⚙️      │               │
│   │    오늘     │    기록     │    설정     │               │
│   └─────────────┴─────────────┴─────────────┘               │
│                                                             │
│   🆕 위젯 (홈 화면 / 잠금화면)                              │
│   ┌─────────┐ ┌─────────────────┐ ┌───┐                     │
│   │ Small   │ │    Medium       │ │🔒 │                     │
│   │ 60%/💧  │ │ +150ml  +300ml  │ │60%│                     │
│   └─────────┘ └─────────────────┘ └───┘                     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 @Observable Store Pattern

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  ViewController │────▶│      Store      │────▶│    Service      │
│                 │◀────│   @Observable   │◀────│                 │
│  - render()     │     │  - send(Action) │     │  - async/await  │
│  - observation  │     │  - @MainActor   │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                      │
         └──────────────────────┘
         withObservationTracking
```

### 2.3 Store Example

```swift
@MainActor
@Observable
final class HomeStore {
    enum Action {
        case refresh
        case refreshGoal
        case refreshQuickButtons
        case addWater(Int)
        case subtractWater(Int)
        case resetTodayWater
        case checkNotificationPermission
        case dismissNotificationBanner
    }

    let provider: ServiceProviderProtocol

    var total: Float = 0
    var ml: Float = 0
    var progress: Float { total == 0 ? 0 : ml / total }
    var remainingMl: Int { max(0, Int(total - ml)) }
    var remainingCups: Int { remainingMl / 250 }
    var quickButtons: [Int] = [100, 200, 300, 500]
    var showNotificationBanner: Bool = false

    func send(_ action: Action) async {
        switch action {
        case .refresh:
            let records = await provider.waterService.fetchWater()
            if let todayRecord = records.first(where: { $0.date.checkToday }) {
                ml = Float(todayRecord.value)
            }

        case .refreshGoal:
            let goal = await provider.waterService.fetchGoal()
            total = Float(goal)

        case .addWater(let amount):
            _ = await provider.waterService.updateWater(by: Float(amount))
            await send(.refresh)
            Analytics.shared.logWaterIntake(amountMl: amount, method: .quickButton)

        case .subtractWater(let amount):
            let newValue = max(0, Int(ml) - amount)
            let diff = Int(ml) - newValue
            if diff > 0 {
                _ = await provider.waterService.updateWater(by: Float(-diff))
                await send(.refresh)
            }

        case .resetTodayWater:
            _ = await provider.waterService.resetTodayWater()
            await send(.refresh)

        // ... 기타 액션
        }
    }
}
```

### 2.4 SwiftUI View Binding

```swift
struct HomeView: View {
    @Bindable var store: HomeStore
    @State private var showGoalSetting = false

    var body: some View {
        VStack {
            Text("\(Int(store.ml))ml")
                .font(.system(size: 48, weight: .bold))

            Text(String(format: "목표: %@ml", "\(Int(store.total))"))

            // 퀵버튼
            ForEach(store.quickButtons, id: \.self) { amount in
                Button("+\(amount)ml") {
                    Task { await store.send(.addWater(amount)) }
                }
            }
        }
        .task {
            await store.send(.refreshGoal)
            await store.send(.refresh)
        }
        .sheet(isPresented: $showGoalSetting) {
            GoalSettingView(...)
        }
    }
}
```

### 2.5 UIKit ViewController (Settings)

```swift
final class SettingsViewController: BaseViewController {
    private let store: SettingsStore

    override func viewDidLoad() {
        super.viewDidLoad()
        observation = startObservation { [weak self] in self?.render() }

        Task {
            await store.send(.loadGoal)
        }
    }

    override func render() {
        // UIKit 기반 설정 화면 렌더링
    }
}
```

---

## 3. File Structure

```
DrinkSomeWater/Sources/
├── AppDelegate.swift
├── SceneDelegate.swift
├── IntroViewController.swift
├── Environment.swift                    # 환경 설정
│
├── DesignSystem/
│   └── DesignTokens.swift              # DS 디자인 토큰 (Color, Font, Size)
│
├── Extensions-Utillities/
│   ├── Date+Ext.swift
│   ├── Float+Ext.swift
│   ├── String+Ext.swift
│   └── UIView+Ext.swift
│
├── Models/
│   ├── Info.swift
│   ├── ModelType.swift
│   ├── NotificationSettings.swift
│   ├── UserProfile.swift               # 사용자 프로필 (체중, 권장량)
│   ├── WaterRecord.swift
│   ├── AppVersion.swift                # 앱 버전 모델
│   └── AppUpdateConfig.swift           # 업데이트 설정
│
├── Services/
│   ├── AlertService.swift
│   ├── BaseService.swift
│   ├── HealthKitService.swift          # HealthKit 연동
│   ├── NotificationService.swift
│   ├── ServiceProvider.swift
│   ├── UserDefaultsService.swift
│   ├── WaterService.swift
│   ├── AdMobService.swift              # 🆕 AdMob 광고 서비스
│   ├── WatchConnectivityService.swift  # 🆕 Watch 연동 서비스
│   ├── RemoteConfigService.swift       # 🆕 원격 설정 서비스
│   └── AppUpdateChecker.swift          # 🆕 앱 업데이트 체커
│
├── StaticComponent/
│   ├── NotificationMessages.swift      # 알림 문구 (로컬라이징)
│   └── WaterImage.swift
│
├── Stores/
│   ├── ObservationToken.swift
│   ├── HomeStore.swift
│   ├── HistoryStore.swift
│   ├── NotificationStore.swift
│   ├── ProfileStore.swift              # 프로필/HealthKit 연동
│   ├── SettingsStore.swift
│   ├── OnboardingStore.swift           # 온보딩 상태 관리
│   ├── DrinkStore.swift (legacy)
│   ├── CalendarStore.swift (legacy)
│   ├── MainStore.swift (legacy)
│   ├── SettingStore.swift (legacy)
│   └── InformationStore.swift (legacy) # 정보 화면 Store
│
├── Types/
│   └── UserDefaultsKey.swift
│
├── Vendor/
│   └── WaveAnimationView.swift
│
├── Views/                              # 🆕 SwiftUI Views
│   ├── MainTabView.swift               # SwiftUI TabView (메인)
│   ├── HomeView.swift                  # 홈 화면 (SwiftUI)
│   ├── HistoryView.swift               # 기록 화면 (SwiftUI)
│   └── AppGuideView.swift              # 앱 가이드 뷰
│
├── ViewComponent/
│   ├── Beaker.swift
│   ├── CalendarDescriptView.swift
│   ├── IntrinsicTableView.swift
│   ├── WaterRecordResultView.swift
│   ├── FSCalendarRepresentable.swift   # 🆕 FSCalendar SwiftUI 래퍼
│   ├── WaveAnimationViewRepresentable.swift  # 🆕 Wave 애니메이션 래퍼
│   ├── NativeAdView.swift              # 🆕 네이티브 광고 뷰
│   └── NativeAdTableViewCell.swift     # 🆕 광고 테이블 셀
│
└── ViewController/
    ├── BaseComponent/
    │   ├── BaseTableViewCell.swift
    │   └── BaseViewController.swift
    │
    ├── Onboarding/
    │   ├── OnboardingViewController.swift
    │   └── OnboardingPageViewController.swift
    │
    └── Settings/
        ├── SettingsViewController.swift
        ├── SettingsCell.swift
        ├── NotificationSettingViewController.swift
        ├── ProfileSettingViewController.swift
        └── WidgetGuideViewController.swift  # 🆕 위젯 가이드

Shared/
└── WidgetDataManager.swift             # 메인앱 + 위젯 공유 데이터

DrinkSomeWaterWidget/
├── DrinkSomeWaterWidget.swift          # Widget Entry Point
├── WaterEntry.swift                    # Timeline Entry
├── WaterProvider.swift                 # Timeline Provider
├── Views/
│   ├── SmallWidgetView.swift           # 2x2 위젯
│   ├── MediumWidgetView.swift          # 4x2 위젯 + 버튼
│   ├── LargeWidgetView.swift           # 4x4 위젯 + 동기부여 메시지
│   └── LockScreenWidgetView.swift      # 잠금화면 위젯
└── Intents/
    └── AddWaterIntent.swift            # AppIntent

DrinkSomeWaterWatch/
└── Sources/
    ├── DrinkSomeWaterWatchApp.swift
    ├── Stores/
    │   └── WatchStore.swift
    ├── Views/
    │   ├── ContentView.swift
    │   ├── HomeView.swift
    │   ├── QuickAddView.swift
    │   └── CustomAmountView.swift
    └── Complications/
        ├── DrinkSomeWaterWidgetBundle.swift  # 위젯 번들
        └── WaterComplication.swift           # 컴플리케이션 뷰
```

---

## 4. Screen Specifications

### 4.1 Home (오늘) - SwiftUI

```
┌────────────────────────────────────────┐
│   [알림 배너 - 권한 없을 시 표시]       │
│   🔔 알림을 켜서 물 마시기 알림을...    │
│                                        │
│            1,200ml                     │ ← 현재 섭취량
│        ┌──────────────┐                │
│        │ 목표: 2000ml ✏️│               │ ← 탭하면 목표 설정
│        └──────────────┘                │
│                                        │
│   ┌────────────────────────────────┐   │
│   │  💧 2잔 더 마시면 목표 달성!   │   │ ← 남은 컵 수 표시
│   └────────────────────────────────┘   │
│                                        │
│         ┌──────────────┐               │
│         │    물병      │               │
│         │  Wave 애니   │               │
│         └──────────────┘               │
│                                        │
│   빠른 추가 ──────── [+/-] [편집]      │ ← 추가/빼기 모드 전환
│                                        │
│   ┌────────┐ ┌────────┐                │
│   │  +100  │ │  +200  │                │ ← 퀵버튼 (커스텀 가능)
│   └────────┘ └────────┘                │
│   ┌────────┐ ┌────────┐                │
│   │  +300  │ │  +500  │                │
│   └────────┘ └────────┘                │
│                                        │
└────────────────────────────────────────┘
```

**View**: `HomeView.swift` (SwiftUI)
**Store**: `HomeStore`
**Actions**: `refresh`, `refreshGoal`, `refreshQuickButtons`, `addWater(Int)`, `subtractWater(Int)`, `resetTodayWater`, `checkNotificationPermission`, `dismissNotificationBanner`

### 4.2 History (기록) - SwiftUI

```
┌────────────────────────────────────────┐
│   📅 기록              📊 12일 달성   │
│                                        │
│   ┌─────────┬─────────┬─────────┐      │
│   │ 캘린더  │  리스트  │타임라인 │      │ ← 3가지 뷰 모드
│   └─────────┴─────────┴─────────┘      │
│                                        │
│   [캘린더 모드]                         │
│   ┌────────────────────────────────┐   │
│   │        FSCalendar              │   │
│   │    (달성일 하이라이트)         │   │
│   └────────────────────────────────┘   │
│   ● 오늘  ● 선택됨  ● 달성            │ ← 범례
│                                        │
│   [리스트 모드]                         │
│   ┌────────────────────────────────┐   │
│   │ 15 │ 금요일    ████████░░ 80%  │   │
│   │ 1월│ 1600/2000ml       ✓      │   │
│   └────────────────────────────────┘   │
│   ┌── Native Ad ────────────────────┐  │ ← 5개마다 광고
│   └────────────────────────────────┘   │
│                                        │
│   [타임라인 모드]                       │
│   2025년 1월                7/15 달성  │
│   ● 15일 (금) - 1600ml    ✓ 달성      │
│   │                                    │
│   ● 14일 (목) - 2100ml    ✓ 달성      │
│                                        │
└────────────────────────────────────────┘
```

**View**: `HistoryView.swift` (SwiftUI)
**Store**: `HistoryStore`
**Actions**: `viewDidLoad`, `selectDate(Date)`
**State**: `waterRecordList`, `successDates`, `selectedRecord`, `monthlySuccessCount`

### 4.3 Settings (설정) - UIKit

```
┌────────────────────────────────────────┐
│   ⚙️ 설정                              │
│                                        │
│   ─────────── 목표 ───────────         │
│   │ 🎯 일일 목표량         2,000ml >│   │
│                                        │
│   ─────────── 퀵버튼 ───────────       │
│   │ ⚡ 퀵버튼 설정       100,200... >│   │
│                                        │
│   ─────────── 알림 ───────────         │
│   │ 🔔 물 마시기 알림              >│   │
│                                        │
│   ─────────── 건강 ───────────         │
│   │ 🍎 프로필 설정 (HealthKit)     >│   │
│                                        │
│   ─────────── 도움말 ───────────       │
│   │ 📱 위젯 설정 가이드            >│   │
│                                        │
│   ─────────── 지원 ───────────         │
│   │ ⭐ 앱 리뷰 남기기               │   │
│   │ 💬 문의하기                     │   │
│   │ 🎁 개발자 응원하기 (Rewarded)   │   │
│   │ 📄 오픈소스 라이선스           >│   │
│                                        │
│   ─────────── 정보 ───────────         │
│   │ 버전                    25.1.1  │   │
│                                        │
└────────────────────────────────────────┘
```

**View**: `SettingsViewController.swift` (UIKit)
**Store**: `SettingsStore`
**Actions**: `loadGoal`, `updateGoal(Int)`, `loadQuickButtons`, `updateQuickButtons([Int])`

### 4.4 Bottom Sheets / Modals

| Sheet | Purpose | Trigger | Type |
|-------|---------|---------|------|
| GoalSettingView | 목표량 설정 (1,000-4,000ml) | Home 목표 탭 | SwiftUI Sheet |
| QuickButtonSettingView | 퀵버튼 커스텀 (추가/삭제/정렬) | Home 편집 버튼 | SwiftUI Sheet |
| WaterAdjustmentView | 물 빼기/초기화 | Home | SwiftUI Sheet |

---

## 5. Dependencies

### 5.1 Tuist SPM

```swift
// Tuist/Package.swift
let package = Package(
    name: "DrinkSomeWater",
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.7.0"),
        .package(url: "https://github.com/WenchaoD/FSCalendar", from: "2.8.4"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", from: "11.2.0"),
    ]
)
```

### 5.2 Internal Modules

- `Analytics` - Firebase Analytics 래퍼 모듈

### 5.3 Local Vendor

- `WaveAnimationView.swift` - 물결 애니메이션 (SPM 미지원으로 로컬 포함)

---

## 6. Data Flow

### 6.1 Water Recording

```
User taps Quick Button
        │
        ▼
HomeViewController.addWater(amount)
        │
        ▼
HomeStore.send(.addWater(amount))
        │
        ▼
WaterService.updateWater(by: amount)
        │
        ▼
UserDefaults 저장
        │
        ▼
HomeStore.send(.refresh)
        │
        ▼
UI 자동 업데이트 (Observation)
```

### 6.2 Goal Setting

```
User opens Goal Sheet
        │
        ▼
GoalSettingViewController
        │
        ▼
Slider changed → currentGoal 업데이트
        │
        ▼
Save tapped
        │
        ▼
WaterService.updateGoal(to: value)
        │
        ▼
dismiss → onSave callback
        │
        ▼
HomeStore.send(.refreshGoal)
```

---

## 7. Swift Concurrency

### 7.1 Isolation Model

```
┌─────────────────────────────────────────────────────┐
│                    MainActor                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │ HomeStore   │  │HistoryStore│  │SettingsStore│  │
│  │ @Observable │  │ @Observable │  │ @Observable │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
│                                                     │
│  ┌─────────────────────────────────────────────┐    │
│  │           ViewControllers                   │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
                        │
                        ▼ async/await
┌─────────────────────────────────────────────────────┐
│                    Services                         │
│  ┌─────────────────────────────────────────────┐    │
│  │  WaterService, UserDefaultsService          │    │
│  │  (UserDefaults 동기 접근 - 실제 I/O 없음)   │    │
│  └─────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────┘
```

### 7.2 Key Patterns

```swift
// Store: @MainActor로 UI 스레드에서 실행
@MainActor
@Observable
final class HomeStore {
    func send(_ action: Action) async {
        // async 작업 가능, UI 업데이트 안전
    }
}

// ViewController: Task로 async 호출
override func viewDidLoad() {
    super.viewDidLoad()
    Task {
        await store.send(.refresh)
    }
}

// FSCalendar delegate: nonisolated + Task
nonisolated func calendar(_ calendar: FSCalendar, didSelect date: Date, ...) {
    Task { @MainActor in
        await store.send(.selectDate(date))
    }
}
```

---

## 8. Build & Run

```bash
# Tuist 설치
mise install tuist

# 의존성 설치
tuist install

# 프로젝트 생성
tuist generate

# 빌드
tuist build

# 테스트
tuist test

# Xcode 열기
open DrinkSomeWater.xcworkspace
```

---

## 9. HealthKit Integration

### 9.1 Overview

```
┌─────────────────────────────────────────────────────┐
│                     iPhone                           │
│  ┌─────────────┐      ┌─────────────┐               │
│  │ 벌컥벌컥 앱 │ ←──→ │  HealthKit  │               │
│  │             │      │ (건강 앱)   │               │
│  │ • 물 기록   │      │             │               │
│  │ • 목표 설정 │      │ • 체중      │               │
│  │ • 알림      │      │ • 물 섭취량 │               │
│  └─────────────┘      └─────────────┘               │
│         │                    │                      │
│         └────────────────────┘                      │
│              UserDefaults                           │
│           (프로필, 설정 저장)                       │
└─────────────────────────────────────────────────────┘
```

### 9.2 HealthKit Data Types

| Type | Identifier | Usage |
|------|------------|-------|
| 체중 | `HKQuantityTypeIdentifier.bodyMass` | 읽기 - 권장량 계산 |
| 물 섭취 | `HKQuantityTypeIdentifier.dietaryWater` | 읽기/쓰기 - 동기화 |

### 9.3 Permission Flow

```
앱 최초 실행 or 프로필 설정 진입
         │
         ▼
HealthKit 권한 요청
(체중 읽기, 물 섭취 읽기/쓰기)
         │
         ├── 승인 → HealthKit에서 체중 로드 → 권장량 계산
         │
         └── 거부 → UserDefaults 수동 입력 fallback
```

### 9.4 Recommended Intake Calculation

```swift
// 체중 기반 권장량 계산
let recommendedIntake = weight (kg) × 33 (ml)

// 예시: 70kg → 2,310ml
```

### 9.5 Required Configuration

**Entitlements** (`DrinkSomeWater.entitlements`)
```xml
<key>com.apple.developer.healthkit</key>
<true/>
```

**Info.plist**
```xml
<key>NSHealthShareUsageDescription</key>
<string>체중 정보를 읽어 맞춤 권장량을 계산합니다.</string>
<key>NSHealthUpdateUsageDescription</key>
<string>물 섭취 기록을 건강 앱과 동기화합니다.</string>
```

---

## 10. Notification System

### 10.1 Random Message Pool (Localized)

```swift
enum NotificationMessages {
    // 로컬라이징된 알림 문구 (한국어/영어 지원)
    static let messages: [String] = [
        String(localized: "notification.message.1"),  // 물 마실 시간이에요!
        String(localized: "notification.message.2"),  // 수분 보충 잊지 마세요~
        String(localized: "notification.message.3"),  // 건강한 하루의 시작, 물 한잔!
        String(localized: "notification.message.4"),  // 목이 마르기 전에 마셔요
        String(localized: "notification.message.5"),  // 오늘도 벌컥벌컥!
        String(localized: "notification.message.6"),  // 물 한 잔이 피로를 씻어줘요
        String(localized: "notification.message.7"),  // 촉촉한 피부의 비결, 물!
        String(localized: "notification.message.8"),  // 집중력 UP! 물 한 잔 어때요?
        String(localized: "notification.message.9"),  // 잠깐! 물 마시고 하세요
        String(localized: "notification.message.10")  // 당신의 몸이 물을 기다려요
    ]

    static var random: String {
        messages.randomElement() ?? messages[0]
    }
}
```

### 10.2 Scheduling Strategy

**제약**: iOS 반복 알림(`repeats: true`)은 동일 메시지만 반복

**해결**: 비반복 알림을 여러 개 예약 (각각 랜덤 문구)

```
┌──────────────────────────────────────────────────┐
│  기존 방식 (❌)                                  │
│  1개 반복 알림 → 같은 문구 계속                  │
├──────────────────────────────────────────────────┤
│  새 방식 (✅)                                    │
│  64개 비반복 알림 예약 (iOS 제한)                │
│  각 알림마다 랜덤 문구 선택                      │
│  앱 실행 시 알림 재충전                          │
└──────────────────────────────────────────────────┘
```

### 10.3 Notification Flow

```
앱 실행 / 설정 변경
         │
         ▼
기존 예약 알림 취소
         │
         ▼
설정 기반으로 최대 64개 알림 예약
(각 알림에 랜덤 문구 할당)
         │
         ▼
알림 발송 시 해당 문구 표시
```

---

## 11. Profile & Personalization

### 11.1 Profile Setting Screen

```
┌────────────────────────────────────────┐
│   프로필 설정                          │
│                                        │
│   ─────────── Apple Health ──────────  │
│   │ 🍎 건강 앱 연동            [ON] │   │
│                                        │
│   ─────────── 체중 ───────────         │
│   │ ⚖️ 현재 체중              70kg │   │
│   │ (건강 앱에서 자동 연동)          │   │
│                                        │
│   ─────────── 권장량 ───────────       │
│   │ 💡 일일 권장 섭취량     2,310ml │   │
│   │ (체중 × 33ml 기준)               │   │
│                                        │
│   ┌────────────────────────────────┐   │
│   │  이 권장량으로 목표 설정하기   │   │
│   └────────────────────────────────┘   │
│                                        │
└────────────────────────────────────────┘
```

### 11.2 Data Priority

```
체중 데이터 우선순위:
1. HealthKit 체중 (자동 연동)
2. UserDefaults 수동 입력 (fallback)

목표량:
- 사용자 직접 설정 (기존 유지)
- 권장량 버튼으로 빠른 적용 가능
```

### 11.3 ProfileStore

```swift
@MainActor
@Observable
final class ProfileStore {
    enum Action {
        case load
        case requestHealthKitPermission
        case syncWeightFromHealthKit
        case updateWeight(Double)
        case toggleHealthKitWeight(Bool)
        case applyRecommendedGoal
    }

    var profile: UserProfile = .default
    var isHealthKitAvailable: Bool = false
    var isHealthKitAuthorized: Bool = false

    var recommendedIntake: Int {     // ml
        profile.recommendedIntake    // weight * 33
    }

    func send(_ action: Action) async { ... }
}
```

---

## 12. Advertising (AdMob)

### 12.1 Overview

```
┌─────────────────────────────────────────────────────┐
│                   광고 전략                          │
├─────────────────────────────────────────────────────┤
│  • 무료 앱 + 광고 수익 모델                         │
│  • 사용자 경험 해치지 않는 비침습적 광고             │
│  • Google AdMob SDK 사용                            │
└─────────────────────────────────────────────────────┘
```

### 12.2 Ad Types & Placement (현재 구현)

| 광고 유형 | 위치 | 빈도 | UX 영향 | 상태 |
|----------|------|------|--------|------|
| **Native Ad** | 기록 탭 리스트 | 5개 기록마다 | 낮음 | ✅ 구현됨 |
| **Rewarded** | 설정 > 개발자 응원하기 | 사용자 선택 | 없음 | ✅ 구현됨 |
| Banner | - | - | - | 미구현 |
| Interstitial | - | - | - | 미구현 |

### 12.3 Native Ad Placement (History List)

```
┌────────────────────────────────────────┐
│   📅 기록              📊 12일 달성   │
│                                        │
│   ┌────────────────────────────────┐   │
│   │ 15 │ 금요일    ████████░░ 80%  │   │
│   └────────────────────────────────┘   │
│   ┌────────────────────────────────┐   │
│   │ 14 │ 목요일    ██████████ 100% │   │
│   └────────────────────────────────┘   │
│   ... (3개 더)                         │
│                                        │
│   ┌────────────────────────────────┐   │
│   │    🔲 Native Ad Card            │   │ ← 5개마다 삽입
│   │    광고 제목 / 설명             │   │
│   └────────────────────────────────┘   │
│                                        │
│   ┌────────────────────────────────┐   │
│   │ 10 │ 일요일    ████████░░ 75%  │   │
│   └────────────────────────────────┘   │
│                                        │
└────────────────────────────────────────┘
```

### 12.4 AdMobService

```swift
@MainActor
final class AdMobService {
    static let shared = AdMobService()

    // Native Ad 프리로드
    func preloadNativeAds(count: Int)
    func getNativeAd() -> GADNativeAd?

    // Rewarded Ad
    func loadRewardedAd()
    var isRewardedAdReady: Bool
    func showRewardedAd(from: UIViewController, completion: (Bool) -> Void)

    // Banner (구현 예정)
    func createBannerView(rootViewController: UIViewController) -> GADBannerView
}
```

### 12.5 Required Configuration

**Tuist/Package.swift**
```swift
.package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", from: "11.2.0")
```

**Info.plist**
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
<key>SKAdNetworkItems</key>
<array>
    <!-- SKAdNetwork IDs for AdMob -->
</array>
<key>NSUserTrackingUsageDescription</key>
<string>맞춤 광고를 위해 사용됩니다.</string>
```

### 12.6 App Tracking Transparency (ATT)

iOS 14.5+ 필수:
```swift
import AppTrackingTransparency

// 앱 시작 시 권한 요청
ATTrackingManager.requestTrackingAuthorization { status in
    // 광고 초기화
}
```

### 12.7 Implementation Plan

| # | 작업 | 파일 |
|---|------|------|
| 1 | AdMob SDK 의존성 추가 | `Tuist/Package.swift` |
| 2 | AdService 생성 | `Services/AdService.swift` (신규) |
| 3 | Info.plist 설정 | `Project.swift` 또는 `Info.plist` |
| 4 | ATT 권한 요청 | `AppDelegate.swift` 또는 `SceneDelegate.swift` |
| 5 | Banner 뷰 컴포넌트 | `ViewComponent/AdBannerView.swift` (신규) |
| 6 | HomeVC에 Banner 추가 | `ViewController/Home/HomeViewController.swift` |
| 7 | Interstitial 로직 | `Services/AdService.swift` |
| 8 | 기록 카운터 추가 | `Services/UserDefaultsService.swift` |

### 12.8 Revenue Optimization Tips

- **테스트 광고 ID** 사용 (개발 중): `ca-app-pub-3940256099942544/...`
- **Mediation** 고려: AdMob + 다른 네트워크 (수익 최적화)
- **A/B 테스트**: Interstitial 빈도 최적화
- **지역별 eCPM** 확인: 한국 vs 글로벌

### 12.9 Premium/Ad-Free Option (Future)

```
┌─────────────────────────────────────────┐
│  향후 고려: 프리미엄 모델               │
├─────────────────────────────────────────┤
│  • 무료: 광고 있음                      │
│  • 프리미엄 ($0.99): 광고 제거          │
│  • In-App Purchase로 구현               │
└─────────────────────────────────────────┘
```

---

## 13. Widget Extension (v2.2)

### 13.1 Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Widget Architecture                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐     App Group      ┌─────────────────┐    │
│   │ Main App    │ ◄────────────────► │ Widget Extension│    │
│   │             │   UserDefaults     │                 │    │
│   │ • 물 기록   │   (shared)         │ • Small Widget  │    │
│   │ • 설정     │                    │ • Medium Widget │    │
│   └─────────────┘                    │ • Lock Screen   │    │
│         │                            └─────────────────┘    │
│         │ WidgetCenter.reloadAllTimelines()                 │
│         └──────────────────────────────────────────────────►│
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 13.2 App Group Configuration

```
App Group ID: group.com.onceagain.DrinkSomeWater
```

**Entitlements** (메인앱 + 위젯 Extension)
```xml
<key>com.apple.security.application-groups</key>
<array>
    <string>group.com.onceagain.DrinkSomeWater</string>
</array>
```

### 13.3 Widget Types

| Widget | Family | Description |
|--------|--------|-------------|
| **Small** | `systemSmall` | 원형 진행률 + 퍼센트 + 섭취량 |
| **Medium** | `systemMedium` | 진행률 + 인터랙티브 버튼 (+150ml, +300ml) |
| **Large** | `systemLarge` | 큰 진행률 + 동기부여 메시지 + 버튼 (150/300/500ml) |
| **Lock Circular** | `accessoryCircular` | 진행률 원형 표시 |
| **Lock Rectangular** | `accessoryRectangular` | 물 섭취량/목표량 텍스트 |
| **Lock Inline** | `accessoryInline` | 텍스트 형태 (섭취량/목표량) |

### 13.4 Small Widget Design

```
┌─────────────────┐
│    💧 1,200     │
│    ─────────    │
│     2,000ml     │
│      60%        │
└─────────────────┘
```

### 13.5 Medium Widget Design (Interactive)

```
┌──────────────────────────────────┐
│  💧 오늘 마신 물                   │
│  1,200 / 2,000ml     [+150] [+300]│
│  ████████████░░░░░░░░  60%       │
└──────────────────────────────────┘
```

- **[+150], [+300]**: 탭하면 AppIntent로 물 추가

### 13.6 Large Widget Design (Interactive)

```
┌──────────────────────────────────────────┐
│  💧 Hydration Tracker                     │
│                                          │
│    ┌────────────┐    현재: 1,200ml       │
│    │   60%     │    ─────────────        │
│    │  ◯◯◯◯    │    목표: 2,000ml        │
│    └────────────┘                        │
│                                          │
│       "조금만 더 마시면 목표 달성!"       │ ← 동기부여 메시지
│                                          │
│  ┌────────┐ ┌────────┐ ┌────────┐        │
│  │  +150  │ │  +300  │ │  +500  │        │ ← 인터랙티브 버튼
│  └────────┘ └────────┘ └────────┘        │
└──────────────────────────────────────────┘
```

### 13.7 Lock Screen Widget Design

```
Circular:        Rectangular:
  ┌───┐          ┌─────────────┐
  │60%│          │💧 1,200ml   │
  │ 💧│          │   / 2,000   │
  └───┘          └─────────────┘
```

### 13.7 Widget Data Flow

```
메인 앱에서 물 추가
        │
        ▼
WaterService.updateWater()
        │
        ├── UserDefaults (standard) 저장
        │
        ├── App Group UserDefaults 저장
        │
        └── WidgetCenter.shared.reloadAllTimelines()
                │
                ▼
        Widget Timeline Provider 호출
                │
                ▼
        Widget UI 업데이트
```

### 13.8 Interactive Widget (AppIntent)

```swift
struct AddWaterIntent: AppIntent {
    static var title: LocalizedStringResource = "물 추가"
    
    @Parameter(title: "Amount")
    var amount: Int
    
    init() {
        self.amount = 150
    }
    
    init(amount: Int) {
        self.amount = amount
    }
    
    func perform() async throws -> some IntentResult {
        // App Group UserDefaults에 물 추가
        let manager = WidgetDataManager.shared
        await manager.addWater(amount)
        
        // 위젯 타임라인 리로드
        WidgetCenter.shared.reloadAllTimelines()
        
        return .result()
    }
}
```

### 13.10 File Structure

```
DrinkSomeWaterWidget/
├── DrinkSomeWaterWidget.swift          # Widget Entry Point + Bundle
├── WaterEntry.swift                     # Timeline Entry
├── WaterProvider.swift                  # Timeline Provider
├── Views/
│   ├── SmallWidgetView.swift           # 2x2 위젯 (원형 진행률)
│   ├── MediumWidgetView.swift          # 4x2 위젯 + 버튼 (150/300ml)
│   ├── LargeWidgetView.swift           # 4x4 위젯 + 동기부여 + 버튼 (150/300/500ml)
│   └── LockScreenWidgetView.swift      # 잠금화면 위젯 (Circular/Rectangular/Inline)
└── Intents/
    └── AddWaterIntent.swift            # AppIntent

Shared/
└── WidgetDataManager.swift             # 메인앱 + 위젯 공유 (App Group)
```

---

## 14. Onboarding (v2.2)

### 14.1 Overview

최초 실행 시 사용자에게 앱 사용법을 안내하는 5페이지 스와이프 온보딩.

```
[Page 1]        [Page 2]        [Page 3]        [Page 4]        [Page 5]
  앱 소개    →   목표 설정    →   HealthKit   →    알림 설정   →   위젯 가이드
                                  연동
  
 💧벌컥벌컥      🎯 슬라이더     🍎 권한 요청     🔔 권한 요청    📱 설정 안내
   소개          1500~4500ml      (선택)          (선택)
   
                                                              [시작하기] 버튼
```

### 14.2 Page Details

| Page | Title | Content | Action |
|------|-------|---------|--------|
| 1 | 앱 소개 | 물 마시기의 중요성, 앱 기능 소개 | 없음 (스와이프) |
| 2 | 목표 설정 | 슬라이더로 일일 목표량 설정 (1,500~4,500ml) | 목표량 저장 |
| 3 | HealthKit | Apple 건강 앱 연동 안내 | 권한 요청 버튼 |
| 4 | 알림 설정 | 물 마시기 알림 설정 안내 | 권한 요청 버튼 |
| 5 | 위젯 가이드 | 홈 화면 위젯 추가 방법 안내 | [시작하기] 버튼 |

### 14.3 Flow Logic

```
앱 실행 (SceneDelegate)
        │
        ▼
UserDefaults.onboardingCompleted 확인
        │
        ├── false → OnboardingViewController 표시
        │              │
        │              ▼
        │           페이지 스와이프 또는 [스킵] 버튼
        │              │
        │              ▼
        │           [시작하기] 탭 → onboardingCompleted = true
        │              │
        │              └──────────────────┐
        │                                 │
        └── true ─────────────────────────┤
                                          │
                                          ▼
                                    MainTabBarController
```

### 14.4 OnboardingStore

```swift
@MainActor
@Observable
final class OnboardingStore {
    enum Action {
        case setGoal(Int)
        case requestHealthKitPermission
        case requestNotificationPermission
        case completeOnboarding
        case skip
    }
    
    var currentPage: Int = 0
    var goal: Int = 2000
    var isHealthKitAuthorized: Bool = false
    var isNotificationAuthorized: Bool = false
    
    func send(_ action: Action) async { ... }
}
```

### 14.5 Skip Behavior

- 모든 페이지에서 우측 상단 [스킵] 버튼 표시
- 스킵 시 기본값 적용:
  - 목표량: 2,000ml (기본값)
  - HealthKit: 연동 안함
  - 알림: 기본 설정 또는 끔
- `onboardingCompleted = true` 저장 후 메인 화면 이동

### 14.6 Widget Guide (설정 화면 접근)

온보딩 외에도 설정 화면에서 위젯 가이드 재확인 가능:

```
설정 > 도움말 > 위젯 설정 가이드
```

---

## 15. Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.3.x | 2025-01 | SwiftUI 마이그레이션 (Home/History), Large 위젯, Native Ad, 물 빼기/초기화, 로컬라이징 |
| 2.2.0 | 2025-01 | 홈/잠금화면 위젯, 인터랙티브 위젯, 온보딩 플로우 |
| 2.1.0 | 2025-01 | HealthKit 연동, 체중 기반 권장량, 랜덤 알림 문구 |
| 2.0.x | 2025-01 | 3탭 구조 리팩토링, @Observable 마이그레이션 |
| 1.x | 2021 | 초기 ReactorKit + RxSwift 버전 |
