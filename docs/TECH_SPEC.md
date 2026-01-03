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
│   └── WaterRecord.swift
│
├── Services/
│   ├── AlertService.swift
│   ├── BaseService.swift
│   ├── ServiceProvider.swift
│   ├── UserDefaultsService.swift
│   └── WaterService.swift
│
├── StaticComponent/
│   ├── Licenses.swift
│   └── WaterImage.swift
│
├── Stores/
│   ├── ObservationToken.swift
│   ├── HomeStore.swift
│   ├── HistoryStore.swift
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
    │   └── SettingsCell.swift
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

## 9. Version History

| Version | Date | Changes |
|---------|------|---------|
| 25.1.x | 2025-01 | 3탭 구조 리팩토링, @Observable 마이그레이션 |
| 1.x | 2021 | 초기 ReactorKit + RxSwift 버전 |
