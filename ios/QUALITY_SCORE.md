# QUALITY_SCORE.md – 벌컥벌컥 iOS
> iOS/watchOS 코드 품질 채점 기준

---

## 채점 체계

| 등급 | 점수 | 의미 |
|------|------|------|
| S | 90~100 | 프로덕션 레디, 모범 사례 |
| A | 75~89 | 양호, 소소한 개선 여지 |
| B | 60~74 | 기능 동작하나 리팩터링 필요 |
| C | 40~59 | 기술 부채 상당, 즉각 개선 요 |
| D | 0~39 | 구조적 문제, 재설계 검토 |

---

## 1. 코드 구조 (가중치 20점)

**기준 경로**: `Sources/Stores/`, `Sources/Services/`, `Sources/Views/`, `Sources/Data/`

| 점수 | 기준 |
|------|------|
| 5 | @Observable Store Pattern 완전 준수. View는 Store만 참조하고, Store는 Service를 호출하며, Service는 Data 레이어와만 통신한다. Sources/ 하위 폴더 규칙 100% 준수. |
| 4 | 레이어 분리가 거의 되어 있으나 1~2곳에서 View가 Service를 직접 참조하거나 Store에 Data 접근 코드가 섞여 있다. |
| 3 | 레이어 개념은 있으나 책임 경계가 불분명하다. Store에 UI 로직이 혼재하거나 Service에 비즈니스 규칙이 누락된다. |
| 2 | 폴더 구조만 존재하고 실질적 레이어 분리가 없다. God Object 패턴이 관찰된다. |
| 1 | 단일 파일 또는 단일 타입에 모든 로직이 집중되어 있다. |

**세부 체크**
- `@Observable` 또는 `ObservationIgnored`를 올바르게 사용하는가
- Store가 `@Observable class`로 선언되어 있는가
- View에서 직접 URLSession/HKHealthStore를 호출하지 않는가
- `Sources/` 하위 폴더가 `Stores/`, `Services/`, `Views/`, `Data/`, `Models/` 로 분류되어 있는가

---

## 2. Swift 6 동시성 (가중치 20점)

| 점수 | 기준 |
|------|------|
| 5 | 모든 공유 가변 상태에 `@MainActor` 또는 `actor`가 명시되어 있다. `Sendable` 준수가 완전하며 data race 컴파일러 경고가 0개다. `@unchecked Sendable` 사용이 없거나 피할 수 없는 경우에 한해 주석으로 근거가 명시되어 있다. |
| 4 | 컴파일러 경고가 1~3개 있으나 런타임 data race 위험이 없다. `@unchecked Sendable` 1~2개 사용하나 이유가 명확하다. |
| 3 | `async/await`를 사용하나 `DispatchQueue` 혼용이 남아 있다. `Sendable` 준수가 부분적이다. |
| 2 | Swift Concurrency를 도입했으나 `Task.detached` 남용 또는 `MainActor.run` 불필요 중첩이 발생한다. |
| 1 | GCD/콜백 기반 코드가 주를 이루고 Swift Concurrency가 거의 적용되지 않았다. |

**세부 체크**
- Store 프로퍼티 변경이 `@MainActor` 컨텍스트에서 일어나는가
- `async let` 또는 `TaskGroup`으로 병렬 작업을 구성하는가
- `actor`를 사용하는 경우 외부에서 `await` 없이 접근하지 않는가
- `@unchecked Sendable` 개수가 3개 이하인가

---

## 3. SwiftUI / UIKit 혼용 (가중치 15점)

| 점수 | 기준 |
|------|------|
| 5 | SwiftUI가 기본 UI 레이어다. UIKit은 Settings/Onboarding 화면에만 국한되며 `UIViewControllerRepresentable` / `UIViewRepresentable` 구현이 올바르다. Coordinator 패턴을 통해 델리게이트를 처리한다. |
| 4 | SwiftUI 우선이나 UIKit 사용 범위가 지침보다 약간 넓다. Representable 구현에 메모리 누수 위험이 없다. |
| 3 | SwiftUI와 UIKit이 불명확한 기준으로 혼용된다. `updateUIViewController` 구현이 불완전하다. |
| 2 | UIKit 비중이 SwiftUI보다 높다. Representable 없이 `UIHostingController`를 직접 남용한다. |
| 1 | 전체가 UIKit 기반이거나 SwiftUI와 UIKit 경계가 없다. |

**세부 체크**
- Settings 화면이 `UIViewControllerRepresentable`로 래핑되어 있는가 (또는 SwiftUI로 재작성 계획이 있는가)
- `UIViewControllerRepresentable.makeCoordinator()`를 통해 델리게이트를 처리하는가
- `@State`/`@Binding`과 UIKit 상태 동기화가 `updateUIViewController`에서 올바르게 이루어지는가

---

## 4. WidgetKit (가중치 10점)

| 점수 | 기준 |
|------|------|
| 5 | `TimelineProvider`가 올바르게 구현되어 있고, `AppIntent`를 통한 인터랙션이 동작한다. `WidgetDataManager`를 통해 앱 데이터를 공유하며, Small/Medium/Large/Accessory 사이즈별 레이아웃이 각각 최적화되어 있다. |
| 4 | 주요 사이즈 대응이 되어 있으나 Accessory(잠금 화면) 위젯이 누락되거나 `TimelineReloadPolicy`가 최적화되지 않았다. |
| 3 | `TimelineProvider` 기본 구현은 있으나 `getSnapshot`과 `getTimeline` 데이터가 동일하지 않거나 오래된 데이터를 표시한다. |
| 2 | 단일 사이즈만 지원하고 AppIntent가 없다. 데이터 공유가 App Group 없이 구현되어 있다. |
| 1 | 위젯이 빌드는 되나 실제 데이터를 표시하지 못하거나 항상 플레이스홀더를 보여준다. |

**세부 체크**
- App Group identifier가 앱과 위젯 익스텐션에서 일치하는가
- `WidgetDataManager`가 `UserDefaults(suiteName:)`을 통해 데이터를 공유하는가
- `TimelineReloadPolicy.atEnd` 또는 `.after(_:)`가 적절히 설정되어 있는가
- `.systemSmall`에서 텍스트 잘림이 없는가

---

## 5. HealthKit (가중치 10점)

| 점수 | 기준 |
|------|------|
| 5 | 권한 요청이 기능 첫 사용 시점에 이루어진다. `HKQuantityType.quantityType(forIdentifier: .dietaryWater)`를 정확히 사용하며, 권한 거부 시 graceful degradation이 구현되어 있다. 백그라운드 딜리버리가 필요한 경우 올바르게 설정되어 있다. |
| 4 | 권한 흐름이 올바르나 거부 상태에서 사용자 안내 메시지가 부족하다. |
| 3 | 권한 확인 없이 HKHealthStore에 접근하는 경우가 있다. 시뮬레이터/HealthKit 미지원 기기 예외 처리가 없다. |
| 2 | `HKHealthStore.isHealthDataAvailable()` 확인이 없다. 오류를 무시하거나 크래시가 발생한다. |
| 1 | HealthKit 통합이 동작하지 않거나 권한 없이 데이터에 접근한다. |

**세부 체크**
- `HKHealthStore.isHealthDataAvailable()` 호출 후 접근하는가
- `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`이 Info.plist(또는 Project.swift)에 있는가
- 권한 거부 시 앱이 크래시 없이 동작하는가
- `HKObserverQuery` 사용 시 백그라운드 딜리버리 등록이 쌍으로 있는가

---

## 6. watchOS (가중치 10점)

| 점수 | 기준 |
|------|------|
| 5 | WatchConnectivity가 안정적으로 동작하고 iPhone 없이도 독립적으로 사용 가능하다. 컴플리케이션이 구현되어 있으며 `CLKComplicationDataSource` 또는 WidgetKit 기반 컴플리케이션이 올바르다. 작은 화면에 최적화된 UI가 있다. |
| 4 | WatchConnectivity 기본 동작은 하나 오프라인 시나리오 처리가 부족하다. 컴플리케이션이 1~2가지 패밀리만 지원한다. |
| 3 | Watch 앱이 iPhone 연결 없이 동작하지 않는다. WCSession 활성화 오류 처리가 없다. |
| 2 | Watch 앱이 iOS 앱의 UI를 단순 복사한 수준이다. WatchConnectivity가 없거나 단방향이다. |
| 1 | Watch 앱이 빌드는 되나 핵심 기능이 동작하지 않는다. |

**세부 체크**
- `WCSession.default.activateSession()`이 앱 시작 시 호출되는가
- `session(_:didReceiveMessage:)` 델리게이트가 구현되어 있는가
- Watch 앱이 로컬 저장소(`UserDefaults` 또는 CoreData)를 독립적으로 갖는가
- 컴플리케이션 타임라인이 하루치 이상 제공되는가

---

## 7. 테스트 (가중치 10점)

| 점수 | 기준 |
|------|------|
| 5 | Store/Service 유닛 테스트 커버리지 80% 이상. 스냅샷 테스트가 주요 뷰를 커버한다. CI에서 테스트가 자동 실행된다. |
| 4 | 커버리지 60~79%. 스냅샷 테스트가 존재하나 일부 뷰만 커버한다. |
| 3 | 커버리지 40~59%. Store 테스트만 있고 Service/View 테스트가 없다. |
| 2 | 커버리지 20~39% 또는 테스트가 컴파일만 되고 실제 검증이 없다. |
| 1 | 테스트가 거의 없거나 전혀 없다. |

**세부 체크**
- `DrinkSomeWaterTests/` 하위에 Store, Service별 테스트 파일이 있는가
- `DrinkSomeWaterSnapshotTests/`에 스냅샷 테스트가 있는가
- Mock/Stub을 활용해 외부 의존성(HealthKit, Network)이 격리되어 있는가
- `XCTestExpectation` 또는 `async/await` 테스트로 비동기 코드를 검증하는가

---

## 8. 네이밍 / 문서화 (가중치 5점)

| 점수 | 기준 |
|------|------|
| 5 | Swift API Design Guidelines를 완전히 준수한다. Public API에 `///` 문서 주석이 있다. 복잡한 로직에 인라인 주석이 있다. 줄임말이 없고 의도가 명확한 이름을 사용한다. |
| 4 | 대부분 가이드라인을 준수하나 일부 파라미터 레이블이 어색하거나 주석이 없는 Public API가 있다. |
| 3 | 네이밍이 일관되지 않는다. `data`, `info`, `manager2` 같은 모호한 이름이 보인다. |
| 2 | 줄임말이 많고 의도를 파악하기 어렵다. 주석이 거의 없다. |
| 1 | 네이밍 규칙이 없다. 임시 변수명이 코드베이스에 남아 있다. |

**세부 체크**
- 함수명이 동사로 시작하는가 (예: `fetchWaterIntake()`, `scheduleNotification()`)
- `Bool` 프로퍼티가 `is`, `has`, `should`로 시작하는가
- `class` / `struct` 이름이 명사인가
- `TODO:`, `FIXME:` 주석이 이슈 번호와 함께 작성되어 있는가

---

## 가중치 기반 총점 계산

| 항목 | 가중치 | 만점 | 계산식 |
|------|--------|------|--------|
| 1. 코드 구조 | ×4 | 20 | 점수 × 4 |
| 2. Swift 6 동시성 | ×4 | 20 | 점수 × 4 |
| 3. SwiftUI / UIKit 혼용 | ×3 | 15 | 점수 × 3 |
| 4. WidgetKit | ×2 | 10 | 점수 × 2 |
| 5. HealthKit | ×2 | 10 | 점수 × 2 |
| 6. watchOS | ×2 | 10 | 점수 × 2 |
| 7. 테스트 | ×2 | 10 | 점수 × 2 |
| 8. 네이밍/문서화 | ×1 | 5 | 점수 × 1 |
| **합계** | | **100** | |

---

## 자가 점검 체크리스트

아래 항목을 코드 리뷰 전에 확인한다. 모두 PASS여야 PR을 올린다.

### 구조 / 아키텍처

- [ ] View 파일에서 `URLSession`, `HKHealthStore`, `UserDefaults`를 직접 호출하지 않는다
- [ ] Store가 `@Observable class`로 선언되어 있다
- [ ] `Sources/Stores/`, `Sources/Services/`, `Sources/Views/` 폴더 규칙을 따른다
- [ ] 새 파일을 올바른 폴더에 배치했다

### Swift 6 동시성

- [ ] Swift 6 컴파일러 모드에서 data race 경고가 0개다
- [ ] `@unchecked Sendable` 사용 시 주석으로 근거를 남겼다
- [ ] `DispatchQueue.main.async` 대신 `@MainActor` 또는 `await MainActor.run`을 사용했다
- [ ] `Task.detached` 사용이 없거나 불가피한 경우에만 사용했다

### WidgetKit

- [ ] App Group identifier가 앱/위젯/Watch에서 동일하다
- [ ] `WidgetDataManager`를 통해 데이터를 공유한다
- [ ] 위젯 프리뷰가 모든 지원 사이즈에서 정상 표시된다

### HealthKit

- [ ] `HKHealthStore.isHealthDataAvailable()` 확인 후 접근한다
- [ ] 권한 거부 시 앱이 정상 동작한다
- [ ] HealthKit 데이터를 외부 서버로 전송하지 않는다

### 테스트

- [ ] 변경된 Store/Service에 대응하는 테스트를 작성했다
- [ ] 새 뷰에 스냅샷 테스트를 추가했다
- [ ] 모든 테스트가 로컬에서 통과한다

### 네이밍 / 문서화

- [ ] Public 함수/프로퍼티에 `///` 주석이 있다
- [ ] 모호한 이름(`temp`, `data2`, `flag`)이 없다
- [ ] `TODO:`/`FIXME:`에 이슈 번호가 포함되어 있다

---

*최종 업데이트: 2026-04-27*
