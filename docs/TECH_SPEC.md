# DrinkSomeWater Technical Specification

> ReactorKit/RxSwift → @Observable/async-await 마이그레이션 기술 문서

## 1. Overview

### 1.1 Project Summary
- **App Name**: 벌컥벌컥 (Gulp) - 물 섭취 추적 iOS 앱
- **Current State**: ReactorKit + RxSwift (archive/250617 브랜치)
- **Target State**: UIKit + @Observable + async/await

### 1.2 Migration Goals
| Goal | Description |
|------|-------------|
| Remove ReactorKit | Reactor → @Observable Store 패턴 전환 |
| Remove RxSwift ecosystem | RxSwift, RxCocoa, RxDataSources, RxGesture, RxOptional, RxViewController 제거 |
| Modern Swift | async/await, @Observable (iOS 17+) |
| iOS 26+ | 최소 지원 버전 iOS 26 |
| Tuist | 프로젝트 관리 (이미 설정됨) |

---

## 2. Architecture

### 2.1 Before (ReactorKit)
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  ViewController │────▶│     Reactor     │────▶│    Service      │
│                 │◀────│                 │◀────│                 │
│  - bind()       │     │  - Action       │     │  - RxSwift      │
│  - disposeBag   │     │  - Mutation     │     │  - PublishSubject│
│                 │     │  - State        │     │                 │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                      │
         └──────────────────────┘
              RxSwift Binding
```

### 2.2 After (@Observable Store)
```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  ViewController │────▶│      Store      │────▶│    Service      │
│                 │◀────│   @Observable   │◀────│                 │
│  - render()     │     │  - send(Action) │     │  - async/await  │
│  - observation  │     │  - @MainActor   │     │  - Actor        │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                      │
         └──────────────────────┘
         withObservationTracking
```

### 2.3 Key Pattern Changes

#### Reactor → Store
```swift
// BEFORE: ReactorKit
final class MainViewReactor: Reactor {
    enum Action { case refresh }
    enum Mutation { case updateWater([WaterRecord]) }
    struct State { var ml: Float = 0 }
    
    func mutate(action: Action) -> Observable<Mutation> { ... }
    func reduce(state: State, mutation: Mutation) -> State { ... }
}

// AFTER: @Observable Store
@MainActor
@Observable
final class MainStore {
    enum Action { case refresh }
    
    private let provider: ServiceProviderProtocol
    var ml: Float = 0
    
    func send(_ action: Action) async {
        switch action {
        case .refresh:
            let records = await provider.waterService.fetchWater()
            ml = Float(records.first(where: { $0.date.checkToday })?.value ?? 0)
        }
    }
}
```

#### ViewController Binding
```swift
// BEFORE: RxSwift binding
func bind(reactor: MainViewReactor) {
    reactor.state.asObservable()
        .map { $0.ml }
        .bind(to: label.rx.text)
        .disposed(by: disposeBag)
}

// AFTER: Observation render loop
private var observation: ObservationToken?

override func viewDidLoad() {
    super.viewDidLoad()
    observation = observe { [weak self] in self?.render() }
}

@MainActor private func render() {
    label.text = "\(Int(store.ml))ml"
}
```

---

## 3. File Structure

### 3.1 Source Files (from archive/250617)
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
│   ├── UIView+Ext.swift
│   └── WaveAnimationView+Reactive.swift  # DELETE (Rx extension)
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
│   └── WaterService.swift               # REFACTOR (Rx → async/await)
│
├── StaticComponent/
│   ├── Licenses.swift
│   └── WaterImage.swift
│
├── Types/
│   └── UserDefaultsKey.swift
│
├── ViewComponent/
│   ├── Beaker.swift
│   ├── CalendarDescriptView.swift
│   ├── IntrinsicTableView.swift
│   └── WaterRecordResultView.swift
│
├── ViewController/
│   ├── BaseComponent/
│   │   ├── BaseTableViewCell.swift
│   │   └── BaseViewController.swift     # REFACTOR (remove disposeBag)
│   │
│   ├── Main/
│   │   ├── MainViewController.swift     # REFACTOR
│   │   └── MainViewReactor.swift        # → MainStore.swift
│   │
│   ├── Drink/
│   │   ├── DrinkViewController.swift    # REFACTOR
│   │   └── DrinkViewReactor.swift       # → DrinkStore.swift
│   │
│   ├── Calendar/
│   │   ├── CalendarViewController.swift # REFACTOR
│   │   └── CalendarViewReactor.swift    # → CalendarStore.swift
│   │
│   ├── Setting/
│   │   ├── SettingViewController.swift  # REFACTOR
│   │   └── SettingViewReactor.swift     # → SettingStore.swift
│   │
│   ├── Information/
│   │   ├── InformationViewController.swift # REFACTOR
│   │   ├── InformationViewReactor.swift    # → InformationStore.swift
│   │   ├── InfoCell.swift                  # REFACTOR
│   │   └── InfoCellReactor.swift           # DELETE (inline)
│   │
│   └── Licenses/
│       ├── LicenseCell.swift
│       ├── LicenseDetailViewController.swift
│       └── LicensesViewController.swift
│
└── Stores/                              # NEW directory
    ├── ObservationToken.swift           # NEW (UIKit observation helper)
    ├── MainStore.swift
    ├── DrinkStore.swift
    ├── CalendarStore.swift
    ├── SettingStore.swift
    └── InformationStore.swift
```

### 3.2 Tuist Structure
```
DrinkSomeWater/
├── Project.swift                        # UPDATE (iOS 26+)
├── Tuist.swift
├── Tuist/
│   └── Package.swift                    # UPDATE (dependencies)
└── DrinkSomeWater/
    ├── Sources/
    ├── Resources/
    └── Tests/
```

---

## 4. Dependencies

### 4.1 Before (CocoaPods)
```ruby
# Podfile (to be removed)
pod 'FSCalendar'
pod 'SnapKit'
pod 'WaveAnimationView'
pod 'RxSwift'           # REMOVE
pod 'RxCocoa'           # REMOVE
pod 'RxDataSources'     # REMOVE
pod 'RxGesture'         # REMOVE
pod 'RxOptional'        # REMOVE
pod 'RxViewController'  # REMOVE
pod 'SwiftLint'
pod 'Then'
pod 'ReactorKit'        # REMOVE
pod 'URLNavigator'      # REMOVE (unused)
pod 'Firebase/Analytics'
pod 'Firebase/Crashlytics'
```

### 4.2 After (Tuist SPM)
```swift
// Tuist/Package.swift
let package = Package(
    name: "DrinkSomeWater",
    dependencies: [
        // UI
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.7.0"),
        .package(url: "https://github.com/nicklockwood/WaveAnimationView", from: "1.0.0"), // TODO: verify SPM support
        
        // Calendar - evaluate alternatives for iOS 26+
        // FSCalendar may not be needed (native calendar improvements)
        
        // Utilities
        .package(url: "https://github.com/devxoul/Then", from: "3.0.0"),
        
        // Firebase (optional)
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.0.0"),
    ]
)
```

---

## 5. Core Components

### 5.1 ObservationToken (UIKit Helper)
```swift
// Sources/Stores/ObservationToken.swift
import Observation

@MainActor
final class ObservationToken {
    private var cancelled = false
    
    func cancel() { cancelled = true }
    var isCancelled: Bool { cancelled }
}

@MainActor
func observe(_ render: @escaping @MainActor () -> Void) -> ObservationToken {
    let token = ObservationToken()
    
    func run() {
        guard !token.isCancelled else { return }
        withObservationTracking {
            render()
        } onChange: {
            Task { @MainActor in run() }
        }
    }
    
    run()
    return token
}
```

### 5.2 Service Protocol (async/await)
```swift
// Sources/Services/WaterService.swift
protocol WaterServiceProtocol: Sendable {
    func fetchWater() async -> [WaterRecord]
    func fetchGoal() async -> Int
    func updateWater(by ml: Float) async -> [WaterRecord]
    func updateGoal(to ml: Int) async -> Int
}
```

### 5.3 Store Base Pattern
```swift
@MainActor
@Observable
final class SomeStore {
    enum Action {
        case someAction
    }
    
    // State properties (observable)
    var someValue: Int = 0
    
    // Dependencies
    private let provider: ServiceProviderProtocol
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func send(_ action: Action) async {
        switch action {
        case .someAction:
            // async work
            break
        }
    }
}
```

---

## 6. Screen Specifications

### 6.1 Main Screen
| Component | Current | Target |
|-----------|---------|--------|
| Reactor | MainViewReactor | MainStore |
| State | total, ml, progress | same |
| Actions | refresh, refreshGoal | same |
| UI | WaveAnimationView bottle | same |

### 6.2 Drink Screen
| Component | Current | Target |
|-----------|---------|--------|
| Reactor | DrinkViewReactor | DrinkStore |
| State | ml (slider value) | same |
| Actions | updateMl, drink | same |
| UI | Slider, +/- buttons, cup images | same |

### 6.3 Setting Screen
| Component | Current | Target |
|-----------|---------|--------|
| Reactor | SettingViewReactor | SettingStore |
| State | goal, sections | same |
| Actions | updateGoal, viewDidLoad | same |

### 6.4 Calendar Screen
| Component | Current | Target |
|-----------|---------|--------|
| Reactor | CalendarViewReactor | CalendarStore |
| State | waterRecordList | same |
| Actions | refresh | same |
| UI | FSCalendar → evaluate native | TBD |

### 6.5 Information Screen
| Component | Current | Target |
|-----------|---------|--------|
| Reactor | InformationViewReactor | InformationStore |
| State | list, license, infoData | same |
| Actions | viewDidLoad, goDetail, cancel | same |

---

## 7. Migration Order

### Phase 1: Infrastructure
1. ✅ .gitignore 업데이트
2. ⬜ archive/250617에서 소스 복원
3. ⬜ Project.swift iOS 26+ 설정
4. ⬜ Tuist/Package.swift 의존성 추가
5. ⬜ ObservationToken.swift 생성

### Phase 2: Services
6. ⬜ WaterService async/await 전환
7. ⬜ UserDefaultsService 정리
8. ⬜ ServiceProvider 업데이트
9. ⬜ WaveAnimationView+Reactive.swift 삭제

### Phase 3: Stores (Reactor 대체)
10. ⬜ MainStore 생성
11. ⬜ DrinkStore 생성
12. ⬜ SettingStore 생성
13. ⬜ CalendarStore 생성
14. ⬜ InformationStore 생성
15. ⬜ InfoCellReactor 삭제

### Phase 4: ViewControllers
16. ⬜ BaseViewController 리팩토링
17. ⬜ MainViewController 리팩토링
18. ⬜ DrinkViewController 리팩토링
19. ⬜ SettingViewController 리팩토링
20. ⬜ CalendarViewController 리팩토링
21. ⬜ InformationViewController 리팩토링
22. ⬜ InfoCell 리팩토링

### Phase 5: Cleanup
23. ⬜ RxSwift imports 제거
24. ⬜ 빌드 검증
25. ⬜ 테스트 업데이트

---

## 8. Risk & Considerations

### 8.1 Third-party Dependencies
| Dependency | Risk | Mitigation |
|------------|------|------------|
| WaveAnimationView | SPM 지원 확인 필요 | Fork or inline |
| FSCalendar | iOS 26 native calendar 고려 | Evaluate replacement |
| Firebase | SPM 지원됨 | OK |

### 8.2 Breaking Changes
- iOS 26+ 전용 (이전 버전 미지원)
- CocoaPods → SPM 전환
- API 호환성 없음 (완전 리팩토링)

### 8.3 Testing Strategy
- Store 단위 테스트 (async/await)
- ViewController snapshot 테스트 고려
- 수동 UI 테스트 필수

---

## 9. References

- [Observation Framework](https://developer.apple.com/documentation/observation)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [Tuist Documentation](https://docs.tuist.io)
- [ReactorKit](https://github.com/ReactorKit/ReactorKit) (기존 아키텍처 참조)
