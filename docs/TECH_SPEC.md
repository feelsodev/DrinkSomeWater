# DrinkSomeWater Technical Specification

> UIKit + @Observable + async/await 아키텍처

## 1. Overview

### 1.1 Project Summary
- **App Name**: 벌컥벌컥 (Gulp) - 물 섭취 추적 iOS 앱
- **Architecture**: UIKit + @Observable Store + async/await
- **Min iOS**: iOS 26+
- **Swift**: Swift 6

### 1.2 Core Features
| Feature | Description |
|---------|-------------|
| 물 섭취 기록 | 퀵버튼으로 간편하게 물 섭취량 기록 |
| 목표량 설정 | 일일 목표량 커스텀 설정 |
| 기록 조회 | 캘린더로 달성 이력 확인 |
| 퀵버튼 커스텀 | 자주 마시는 용량 설정 |
| 🆕 HealthKit 연동 | Apple 건강앱과 물 섭취량/체중 동기화 |
| 🆕 개인화 권장량 | 체중 기반 일일 권장 물 섭취량 계산 |
| 🆕 랜덤 알림 문구 | 10가지 동기부여 문구 랜덤 발송 |

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
        case addWater(Int)
    }
    
    let provider: ServiceProviderProtocol
    
    var total: Float = 0
    var ml: Float = 0
    var progress: Float { total == 0 ? 0 : ml / total }
    
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
        }
    }
}
```

### 2.4 ViewController Binding

```swift
final class HomeViewController: BaseViewController {
    private let store: HomeStore
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observation = startObservation { [weak self] in self?.render() }
        
        Task {
            await store.send(.refreshGoal)
            await store.send(.refresh)
        }
    }
    
    override func render() {
        let progress = store.progress
        bottle.setProgress(progress)
        waterCapacity.text = "\(Int(store.ml))ml"
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
│   ├── UserProfile.swift              # 🆕 사용자 프로필 (체중, 권장량)
│   └── WaterRecord.swift
│
├── Services/
│   ├── AlertService.swift
│   ├── BaseService.swift
│   ├── HealthKitService.swift         # 🆕 HealthKit 연동
│   ├── NotificationService.swift
│   ├── ServiceProvider.swift
│   ├── UserDefaultsService.swift
│   └── WaterService.swift
│
├── StaticComponent/
│   ├── Licenses.swift
│   ├── NotificationMessages.swift     # 🆕 알림 문구 상수 (10개)
│   └── WaterImage.swift
│
├── Stores/
│   ├── ObservationToken.swift
│   ├── HomeStore.swift
│   ├── HistoryStore.swift
│   ├── NotificationStore.swift
│   ├── ProfileStore.swift             # 🆕 프로필/HealthKit 연동
│   ├── SettingsStore.swift
│   ├── DrinkStore.swift (legacy)
│   ├── CalendarStore.swift (legacy)
│   ├── MainStore.swift (legacy)
│   ├── SettingStore.swift (legacy)
│   └── InformationStore.swift (legacy)
│
├── Types/
│   └── UserDefaultsKey.swift
│
├── Vendor/
│   └── WaveAnimationView.swift
│
├── ViewComponent/
│   ├── Beaker.swift
│   ├── CalendarDescriptView.swift
│   ├── IntrinsicTableView.swift
│   └── WaterRecordResultView.swift
│
└── ViewController/
    ├── BaseComponent/
    │   ├── BaseTableViewCell.swift
    │   └── BaseViewController.swift
    │
    ├── TabBar/
    │   └── MainTabBarController.swift
    │
    ├── Home/
    │   └── HomeViewController.swift
    │
    ├── History/
    │   └── HistoryViewController.swift
    │
├── Settings/
│   ├── SettingsViewController.swift
│   ├── SettingsCell.swift
│   ├── NotificationSettingViewController.swift
│   └── ProfileSettingViewController.swift  # 🆕 프로필 설정 화면
    │
    ├── Common/
    │   ├── GoalSettingViewController.swift
    │   ├── DrinkInputViewController.swift
    │   └── QuickButtonSettingViewController.swift
    │
    └── Licenses/
        ├── LicensesViewController.swift
        ├── LicenseCell.swift
        └── LicenseDetailViewController.swift
```

---

## 4. Screen Specifications

### 4.1 Home (오늘)

```
┌────────────────────────────────────────┐
│                            ┌────┐      │
│   오늘의 물 섭취           │ 🎯 │      │ ← 목표량 퀵 설정
│                            └────┘      │
│                                        │
│         ┌──────────────┐               │
│         │    물병      │               │
│         │  Wave 애니   │  60%          │
│         └──────────────┘               │
│                                        │
│      1,200ml / 2,000ml                 │
│                                        │
│   ┌────────────────────────────────┐   │
│   │  ☀️ 2잔 더 마시면 목표 달성!   │   │
│   └────────────────────────────────┘   │
│                                        │
│   ┌────────┐ ┌────────┐ ┌────────┐     │
│   │  +150  │ │  +300  │ │  +500  │     │ ← 기본 퀵버튼
│   └────────┘ └────────┘ └────────┘     │
│                                        │
│   ┌────────┐ ┌────────┐ ┌──────────┐   │
│   │  +250  │ │  +400  │ │ 직접입력 │   │ ← 커스텀 버튼
│   └────────┘ └────────┘ └──────────┘   │
│                                        │
└────────────────────────────────────────┘
```

**Store**: `HomeStore`
**Actions**: `refresh`, `refreshGoal`, `addWater(Int)`

### 4.2 History (기록)

```
┌────────────────────────────────────────┐
│   📅 기록              📊 12일 달성   │
│                                        │
│   ┌────────────────────────────────┐   │
│   │        FSCalendar              │   │
│   │    (달성일 하이라이트)         │   │
│   └────────────────────────────────┘   │
│                                        │
│   ┌────────────────────────────────┐   │
│   │  📌 1월 15일 (수)              │   │
│   │  목표: 2,000ml  섭취: 2,150ml  │   │
│   │  달성률: 107% ✅               │   │
│   └────────────────────────────────┘   │
│                                        │
└────────────────────────────────────────┘
```

**Store**: `HistoryStore`
**Actions**: `viewDidLoad`, `selectDate(Date)`

### 4.3 Settings (설정)

```
┌────────────────────────────────────────┐
│   ⚙️ 설정                              │
│                                        │
│   ─────────── 목표 ───────────         │
│   │ 🎯 일일 목표량         2,000ml >│   │
│                                        │
│   ─────────── 퀵버튼 ───────────       │
│   │ ⚡ 퀵버튼 설정       250, 400ml >│   │
│                                        │
│   ─────────── 알림 ───────────         │
│   │ 🔔 물 마시기 알림              >│   │
│                                        │
│   ─────────── 지원 ───────────         │
│   │ ⭐ 앱 리뷰 남기기               │   │
│   │ 💬 문의하기                     │   │
│   │ 📄 오픈소스 라이선스           >│   │
│                                        │
│   ─────────── 정보 ───────────         │
│   │ 버전                    25.1.1  │   │
│                                        │
└────────────────────────────────────────┘
```

**Store**: `SettingsStore`
**Actions**: `loadGoal`, `updateGoal(Int)`, `loadCustomButtons`, `updateCustomButtons([Int])`

### 4.4 Bottom Sheets

| Sheet | Purpose | Trigger |
|-------|---------|---------|
| GoalSettingVC | 목표량 설정 (1,500-4,500ml) | Home 🎯 / Settings |
| DrinkInputVC | 직접 입력 (30-500ml) | Home 직접입력 버튼 |
| QuickButtonSettingVC | 퀵버튼 커스텀 | Settings |

---

## 5. Dependencies

### 5.1 Tuist SPM

```swift
// Tuist/Package.swift
let package = Package(
    name: "DrinkSomeWater",
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.7.0"),
        .package(url: "https://github.com/devxoul/Then", from: "3.0.0"),
        .package(url: "https://github.com/WenchaoD/FSCalendar", from: "2.8.0"),
    ]
)
```

### 5.2 Local Vendor

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

### 10.1 Random Message Pool

```swift
enum NotificationMessages {
    static let messages: [String] = [
        "물 마실 시간이에요! 💧",
        "수분 보충 잊지 마세요~ 🌊",
        "건강한 하루의 시작, 물 한잔! ☀️",
        "목이 마르기 전에 마셔요 🥤",
        "오늘도 벌컥벌컥! 💪",
        "물 한 잔이 피로를 씻어줘요 🧘",
        "촉촉한 피부의 비결, 물! ✨",
        "집중력 UP! 물 한 잔 어때요? 🧠",
        "잠깐! 물 마시고 하세요 🚰",
        "당신의 몸이 물을 기다려요 🌿"
    ]
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
        case loadProfile
        case requestHealthKitPermission
        case syncWeight
        case updateWeight(Double)
        case applyRecommendedGoal
    }
    
    var weight: Double = 0           // kg
    var isHealthKitEnabled: Bool = false
    var recommendedIntake: Int {     // ml
        Int(weight * 33)
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

### 12.2 Ad Types & Placement

| 광고 유형 | 위치 | 빈도 | UX 영향 |
|----------|------|------|--------|
| **Banner** | 홈 탭 하단 | 상시 | 낮음 |
| **Interstitial** | 물 기록 완료 후 | N회마다 1회 | 중간 |
| **Rewarded** | 추가 기능 해금 (선택) | 사용자 선택 | 없음 |

### 12.3 Recommended Placement

```
┌────────────────────────────────────────┐
│   오늘의 물 섭취           🎯          │
│                                        │
│         ┌──────────────┐               │
│         │    물병      │               │
│         │  Wave 애니   │               │
│         └──────────────┘               │
│                                        │
│      1,200ml / 2,000ml                 │
│                                        │
│   ┌────────┐ ┌────────┐ ┌────────┐     │
│   │  +150  │ │  +300  │ │  +500  │     │
│   └────────┘ └────────┘ └────────┘     │
│                                        │
│   ┌────────┐ ┌────────┐ ┌──────────┐   │
│   │  +250  │ │  +400  │ │ 직접입력 │   │
│   └────────┘ └────────┘ └──────────┘   │
│                                        │
│  ┌──────────────────────────────────┐  │
│  │         🔲 Banner Ad              │  │  ← AdMob Banner
│  └──────────────────────────────────┘  │
│                                        │
└────────────────────────────────────────┘
```

### 12.4 Interstitial Strategy

```
물 기록 카운터 (UserDefaults)
         │
         ▼
    N회째 기록?
    (예: 5회마다)
         │
    ├── Yes → Interstitial 광고 표시 → 카운터 리셋
    │
    └── No → 그냥 진행
```

**권장 빈도**: 5~10회 기록마다 1회 (너무 잦으면 이탈)

### 12.5 Required Configuration

**Tuist/Package.swift**
```swift
.package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads", from: "11.0.0")
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

## 13. Version History

| Version | Date | Changes |
|---------|------|---------|
| 25.1.x | 2025-01 | 3탭 구조 리팩토링, @Observable 마이그레이션 |
| 1.x | 2021 | 초기 ReactorKit + RxSwift 버전 |
