# QUALITY_SCORE.md – DrinkSomeWater
> 코드 품질 채점 기준 (Quality Rubric)

이 문서는 DrinkSomeWater iOS 프로젝트의 코드 품질을 평가하기 위한 기준이다. AI 에이전트와 개발자 모두 이 기준을 사용해 PR 리뷰, 리팩터링 우선순위 결정, 신규 코드 작성 시 자가 점검을 수행할 수 있다.

---

## 채점 척도

| 점수 | 의미 |
|------|------|
| 5 | 모범 사례를 완전히 준수, 개선 여지 없음 |
| 4 | 양호, 사소한 개선 가능 |
| 3 | 기본 요구사항 충족, 주요 개선 필요 |
| 2 | 부분적 준수, 문제 다수 존재 |
| 1 | 기준 미달, 즉각 수정 필요 |

---

## 1. 코드 구조 (Code Structure)

**대상 경로**: `DrinkSomeWater/App/`, `DrinkSomeWater/Features/`, `DrinkSomeWater/Core/`

### 채점 기준

| 점수 | 기준 |
|------|------|
| 5 | Presentation → Domain → Data 레이어가 명확히 분리됨. Features/ 내 각 기능이 독립 모듈로 구성됨. ViewModel이 View에 직접 의존하지 않음. Core/ 공유 서비스가 인터페이스로 추상화됨 |
| 4 | 레이어 분리가 대부분 준수됨. 한두 곳에서 경계 모호 |
| 3 | MVVM 패턴 사용하나 레이어 경계 혼재. Domain 로직이 일부 View에 노출됨 |
| 2 | ViewModel과 Model이 혼합됨. 레이어 구분 없이 기능 코드가 분산됨 |
| 1 | 아키텍처 패턴 없음. 모든 로직이 View에 혼재 |

### 주요 체크포인트

- `DrinkSomeWater/App/DrinkSomeWaterApp.swift` 진입점이 최소한의 부트스트랩 코드만 포함하는가
- `Features/` 내 각 폴더가 View, ViewModel, Model 서브폴더로 분리되는가
- `Core/` 서비스가 Features/ 전체에서 재사용 가능한 형태로 설계되었는가
- ViewModel이 SwiftUI 프레임워크를 직접 임포트하지 않는가 (순수 Domain 로직 기준)

---

## 2. Swift 6 동시성 (Swift 6 Concurrency)

**대상**: 전체 Swift 소스 파일

### 채점 기준

| 점수 | 기준 |
|------|------|
| 5 | 모든 타입이 Sendable 적합성 명시. @MainActor가 UI 업데이트에만 사용됨. async/await 기반 구조적 동시성 사용. Data race 컴파일러 경고 없음 |
| 4 | Sendable 대부분 준수. @MainActor 사용 적절. 경미한 nonisolated 누락 |
| 3 | 기본 async/await 사용하나 @unchecked Sendable 남용 또는 MainActor.run 과도 사용 |
| 2 | 구조적 동시성 부재. DispatchQueue 혼용. Sendable 미표시 타입 다수 |
| 1 | Data race 발생. Swift 6 strict concurrency 비활성화로 우회 |

### 주요 체크포인트

- `@MainActor`가 ViewModel 클래스 또는 UI 업데이트 함수에 올바르게 붙어 있는가
- `actor`를 사용하는 공유 가변 상태가 있다면 올바른 격리 도메인을 갖는가
- `Task { }` 생성이 맥락 상속을 고려하고, `Task.detached`가 필요한 곳에만 쓰이는가
- `async let`으로 병렬 작업을 처리하는가 (`Task { }` 중복 생성 대신)
- `DispatchSemaphore`, `DispatchGroup.wait()` 등 블로킹 API가 async 컨텍스트에서 사용되지 않는가

---

## 3. SwiftUI / SwiftData

**대상**: `Features/` View 파일, `App/` 설정 파일

### 채점 기준

| 점수 | 기준 |
|------|------|
| 5 | `@Query`로 데이터 fetch 처리. `ModelContainer`가 앱 진입점에서 단일 설정. `@Observable` ViewModel에 `@State`로 View가 바인딩. SwiftData 마이그레이션 플랜 고려됨 |
| 4 | @Query 및 @Observable 올바른 사용. ModelContainer 설정 정상. 경미한 중복 상태 관리 |
| 3 | SwiftData 사용하나 @Query 대신 수동 fetch 혼용. @StateObject/@ObservedObject 레거시 혼용 |
| 2 | ModelContainer 중복 생성 또는 잘못된 위치 설정. @State 남용으로 단방향 데이터 흐름 파괴 |
| 1 | SwiftData 사용 없이 UserDefaults로 모델 데이터 처리. View가 직접 영속성 접근 |

### 주요 체크포인트

- `DrinkSomeWaterApp.swift`에서 `.modelContainer(for:)` 한 곳에서만 설정되는가
- `@Model` 클래스가 Domain 레이어에 위치하는가 (View 파일 내 혼재 금지)
- `@Query` 필터/정렬이 View에서 직접 처리되지 않고 ViewModel 또는 Use Case로 위임되는가
- `@Observable`과 `@State`가 Swift 5.9+ 최신 패턴으로 사용되는가

---

## 4. WidgetKit 통합 (WidgetKit Integration)

**대상**: Widget Extension 타겟, App Group 데이터 공유 코드

### 채점 기준

| 점수 | 기준 |
|------|------|
| 5 | `TimelineProvider`가 getTimeline에서 적절한 갱신 정책(`.atEnd`, `.after`) 반환. App Group `group.com.feelso.DrinkSomeWater`를 통해 메인 앱과 데이터 공유. 위젯 프리뷰가 `PreviewProvider`로 구성됨 |
| 4 | TimelineProvider 정상 구현. App Group 연결됨. 갱신 정책이 약간 최적화 여지 있음 |
| 3 | TimelineProvider 기본 구현. App Group 일부 사용. `.never` 갱신 정책 사용 |
| 2 | 위젯이 메인 앱 데이터를 읽지 못함. App Group 미설정 또는 Bundle ID 불일치 |
| 1 | TimelineProvider 미구현 또는 하드코딩 데이터 반환 |

### 주요 체크포인트

- Widget Extension의 Bundle ID가 `com.feelso.DrinkSomeWater.widget` 형태로 메인 앱과 연관되는가
- App Group `group.com.feelso.DrinkSomeWater`가 메인 앱과 위젯 Extension 양쪽 Capability에 추가되었는가
- `UserDefaults(suiteName:)` 또는 공유 파일 컨테이너로 음수량 데이터를 공유하는가
- 타임라인 엔트리가 의미 있는 시간 간격(예: 1시간)으로 생성되는가

---

## 5. HealthKit 통합 (HealthKit Integration)

**대상**: HealthKit 관련 서비스 파일 (`Core/` 또는 `Features/`)

### 채점 기준

| 점수 | 기준 |
|------|------|
| 5 | 권한 요청 전 `isHealthDataAvailable()` 확인. `HKQuantityType.quantityType(forIdentifier: .dietaryWater)` 올바른 사용. 에러와 권한 거부를 별도 분기 처리. `HKHealthStore` 인스턴스 단일 생성 및 공유 |
| 4 | 권한 흐름 정상. HKQuantityType 올바른 사용. 에러 처리 대부분 구현 |
| 3 | 기본 읽기/쓰기 동작. 권한 거부 처리 미흡. HKHealthStore 중복 생성 |
| 2 | 에러 처리 없이 강제 언래핑. 권한 미확인 상태로 데이터 접근 시도 |
| 1 | HealthKit 권한 요청 없음. `Info.plist`에 사용 목적 설명 누락 |

### 주요 체크포인트

- `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`이 `Info.plist`에 존재하는가
- `HKHealthStore.requestAuthorization` 결과에서 에러와 성공을 모두 처리하는가
- HealthKit 쓰기가 `HKQuantitySample`로 올바른 단위(`HKUnit.literUnit(with: .milli)`)를 사용하는가
- HealthKit 작업이 메인 스레드를 차단하지 않도록 비동기 처리되는가

---

## 6. 에러 처리 (Error Handling)

**대상**: 전체 소스 파일

### 채점 기준

| 점수 | 기준 |
|------|------|
| 5 | 커스텀 `Error` 타입으로 도메인별 에러 정의. 복구 가능 에러에 대한 재시도 또는 폴백 로직 존재. 사용자에게 의미 있는 메시지 표시. `try?` 남용 없음 |
| 4 | do-catch 패턴 대부분 적용. 에러 메시지 사용자 친화적. 경미한 `try?` 사용 |
| 3 | 기본 do-catch 사용. 에러가 콘솔에만 출력되고 사용자 피드백 없음 |
| 2 | `try!` 강제 시도 다수. 에러 무시(`try?` 전체) |
| 1 | 에러 처리 없음. 크래시 발생 시 원인 추적 불가 |

### 주요 체크포인트

- `try!`가 코드베이스에 없는가 (테스트 코드 제외)
- 네트워크나 디스크 I/O 에러가 사용자 알림 또는 로깅으로 연결되는가
- SwiftData 컨텍스트 `save()` 호출이 `try-catch`로 보호되는가
- HealthKit 인증 실패 시 설정 화면 안내 등 복구 흐름이 존재하는가

---

## 7. 테스트 (Testing)

**대상**: `DrinkSomeWaterTests/`, `DrinkSomeWaterUITests/`, Widget 프리뷰

### 채점 기준

| 점수 | 기준 |
|------|------|
| 5 | Domain 로직 유닛 테스트 커버리지 80% 이상. UI 테스트가 핵심 사용자 플로우(물 추가, 기록 확인) 커버. 위젯 `#Preview` 매크로로 모든 사이즈 프리뷰 제공 |
| 4 | 유닛 테스트 대부분 존재. 핵심 UI 테스트 일부 구현. 위젯 프리뷰 일부 |
| 3 | 기본 유닛 테스트 존재하나 커버리지 낮음. UI 테스트 없음 |
| 2 | 테스트 파일은 있으나 실질적 검증 없는 더미 테스트 |
| 1 | 테스트 없음 |

### 주요 체크포인트

- ViewModel의 핵심 계산 로직(일일 목표량 달성률 등)에 유닛 테스트가 있는가
- In-memory SwiftData `ModelContainer`를 사용하는 테스트 환경이 구성되었는가
- UI 테스트가 실제 디바이스/시뮬레이터 시나리오를 재현하는가
- Widget Entry에 `#Preview` 매크로로 small, medium 사이즈가 모두 제공되는가

---

## 8. 네이밍 & 문서화 (Naming & Documentation)

**대상**: 전체 소스 파일

### 채점 기준

| 점수 | 기준 |
|------|------|
| 5 | Swift API Design Guidelines 완전 준수. Public API에 `///` 문서 주석 존재. 함수명이 사용 지점에서 자연스러운 영어 문장 형성. 줄임말 없는 명확한 이름 |
| 4 | 대부분 가이드라인 준수. 문서 주석 일부 누락 |
| 3 | 이름이 대체로 명확하나 일관성 부족. 주석이 코드 설명 위주 (이유 설명 없음) |
| 2 | 줄임말 남용(`tmp`, `mgr`). 단일 문자 변수 사용. 의미 불명확한 이름 다수 |
| 1 | 네이밍 기준 없음. 헝가리안 표기법 또는 무의미한 이름 |

### 주요 체크포인트

- 함수가 동사로 시작하는가 (`fetch`, `calculate`, `update`)
- Bool 프로퍼티가 `is`, `has`, `should` 접두사를 사용하는가
- `typealias`나 중첩 타입이 가독성을 높이는 데 쓰이는가
- `MARK: -` 주석으로 코드 섹션이 구분되는가

---

## 총점 계산 (Overall Score)

| 항목 | 가중치 | 점수 (1-5) | 가중 점수 |
|------|--------|-----------|---------|
| 코드 구조 | 20% | | |
| Swift 6 동시성 | 20% | | |
| SwiftUI / SwiftData | 15% | | |
| WidgetKit 통합 | 10% | | |
| HealthKit 통합 | 10% | | |
| 에러 처리 | 10% | | |
| 테스트 | 10% | | |
| 네이밍 & 문서화 | 5% | | |
| **합계** | **100%** | | **/5.0** |

### 등급 기준

| 총점 | 등급 | 의미 |
|------|------|------|
| 4.5 이상 | A | 출시 준비 완료 |
| 3.5 이상 | B | 배포 가능, 개선 권장 |
| 2.5 이상 | C | 핵심 기능 동작하나 리팩터링 필요 |
| 1.5 이상 | D | 주요 결함 존재, 출시 전 수정 필수 |
| 1.5 미만 | F | 구조적 재작성 필요 |

---

## 자가 점검 체크리스트 (Self-Verification Checklist)

PR 제출 또는 리뷰 요청 전 아래 항목을 모두 확인한다. 모든 항목은 통과(O) 또는 실패(X)로 표시한다.

### 아키텍처

- [ ] `DrinkSomeWater/App/DrinkSomeWaterApp.swift`에 비즈니스 로직이 없다
- [ ] `Features/` 내 각 기능 폴더가 View, ViewModel, Model을 분리한다
- [ ] `Core/` 서비스가 프로토콜 또는 명확한 인터페이스로 추상화되었다
- [ ] ViewModel이 SwiftUI를 직접 임포트하지 않는다 (Combine 또는 순수 Swift만)

### Swift 6 동시성

- [ ] `@MainActor`가 UI 업데이트를 처리하는 ViewModel 또는 함수에 붙어 있다
- [ ] 공유 가변 상태가 `actor`로 보호된다
- [ ] `Task { }` 생성 시 컨텍스트 상속을 고려했다
- [ ] `DispatchSemaphore`, `DispatchGroup.wait()`가 async 코드에서 사용되지 않는다
- [ ] Swift 6 strict concurrency 경고가 0개다

### SwiftUI / SwiftData

- [ ] `ModelContainer` 설정이 `DrinkSomeWaterApp.swift`에서만 이뤄진다
- [ ] Bundle ID `com.feelso.DrinkSomeWater`가 타겟 설정과 일치한다
- [ ] `@Query`로 SwiftData 데이터를 fetch한다 (수동 fetch 지양)
- [ ] `@Observable` 패턴을 사용하고 `@ObservableObject`를 새 코드에 쓰지 않는다

### WidgetKit

- [ ] App Group `group.com.feelso.DrinkSomeWater`가 메인 앱과 위젯 Extension 양쪽에 설정되었다
- [ ] `TimelineProvider.getTimeline`이 `.after` 또는 `.atEnd` 정책을 반환한다
- [ ] 위젯이 App Group을 통해 최신 음수량 데이터를 읽는다
- [ ] 위젯 `#Preview`가 최소 1개 이상 존재한다

### HealthKit

- [ ] `Info.plist`에 `NSHealthShareUsageDescription`, `NSHealthUpdateUsageDescription`이 있다
- [ ] `HKHealthStore.isHealthDataAvailable()`을 권한 요청 전에 확인한다
- [ ] HealthKit 권한 거부 시 사용자에게 설정 이동 안내를 제공한다
- [ ] `HKHealthStore` 인스턴스가 싱글턴 또는 공유 서비스로 관리된다

### 에러 처리

- [ ] `try!`가 프로덕션 코드에 없다
- [ ] SwiftData `context.save()`가 `do-catch`로 감싸져 있다
- [ ] 에러가 사용자에게 의미 있는 메시지로 표시된다
- [ ] HealthKit 에러가 콘솔 출력에 그치지 않고 UI에 반영된다

### 테스트 & 문서화

- [ ] 핵심 Domain 로직에 유닛 테스트가 존재한다
- [ ] Public API에 `///` 문서 주석이 있다
- [ ] 함수명이 사용 지점에서 자연스럽게 읽힌다
- [ ] Bool 프로퍼티가 `is`, `has`, `should`로 시작한다

---

## 개선 우선순위 가이드

점수가 낮은 항목부터 순서대로 수정한다. 동점이면 아래 순서로 우선한다.

1. Swift 6 동시성 (앱 안정성에 직접 영향)
2. 에러 처리 (사용자 경험 및 디버깅)
3. 코드 구조 (장기 유지보수)
4. SwiftData / WidgetKit / HealthKit (기능별 품질)
5. 테스트 (회귀 방지)
6. 네이밍 & 문서화 (협업 효율)

---

*이 문서는 프로젝트 구조나 기술 스택이 변경될 때 함께 업데이트한다.*
