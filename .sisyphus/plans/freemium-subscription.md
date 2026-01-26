# 무료/구독제 모델 도입 - StoreKit 2 인프라 구축

## Context

### Original Request
벌컥벌컥 (Gulp) 물 섭취 기록 앱에 무료/구독제 모델을 도입하여 수익화 다변화

### Interview Summary
**Key Discussions**:
- 구독 모델: 월간(₩2,900) + 연간(₩19,000) + 평생(₩49,000) 3가지 옵션
- 프리미엄 혜택: 광고 제거 (테마/통계는 별도 계획)
- 기술 선택: 네이티브 StoreKit 2
- 평생 상품: Non-Consumable로 구현
- 페이월 UI: SubscriptionStoreView (iOS 17+ 내장)
- 무료 체험: 7일 (월간/연간 구독에 적용)
- iCloud 동기화: 무료 유지 (프리미엄 게이팅 안함)
- 테스트: TDD 방식

**Research Findings**:
- 프로젝트: iOS 18+, Swift 6, @Observable Store 패턴
- Analytics premium 이벤트 이미 정의됨 (`premiumPromptShown`, `purchaseStarted/Completed/Failed`)
- PremiumStatus enum 존재 (`free`/`premium`)
- AdMobService 구현됨 (배너, 리워드, 네이티브)
- 테스트 인프라 존재 (Swift Testing + MockServices)

### Metis Review
**Identified Gaps** (addressed):
- 평생 상품 타입 → Non-Consumable로 결정
- iCloud 게이팅 범위 → 무료 유지로 결정
- 페이월 UI 선택 → SubscriptionStoreView로 결정
- Transaction.updates 리스너 → AppDelegate에서 설정 (계획 포함)
- watchOS 동기화 → 이번 범위 제외 (별도 계획)

---

## Work Objectives

### Core Objective
StoreKit 2 기반 구독 인프라를 구축하여 프리미엄 구독 결제 및 광고 제거 기능을 제공한다.

### Concrete Deliverables
- `StoreKitService.swift` - StoreKit 2 연동 서비스
- `PremiumStore.swift` - 프리미엄 상태 관리 Store
- `PaywallView.swift` - 페이월 UI (SubscriptionStoreView 래핑)
- `StoreKit Configuration File` - 로컬 테스트용
- AdMobService 프리미엄 게이팅 로직 추가
- 설정 화면에 구독 관리 섹션 추가

### Definition of Done
- [ ] `tuist test` → 모든 테스트 통과
- [ ] StoreKit Sandbox에서 구매 플로우 정상 동작
- [ ] 프리미엄 사용자 광고 미표시 확인
- [ ] 구매 복원 기능 정상 동작
- [ ] Analytics 이벤트 정상 기록

### Must Have
- StoreKit 2 Product 로드 및 구매
- Transaction 검증 및 상태 관리
- 구매 복원 기능
- 프리미엄 상태 지속성 (앱 재시작 시 복원)
- 광고 제거 조건부 로직
- 페이월 UI

### Must NOT Have (Guardrails)
- ❌ 테마/커스터마이징 기능 개발 (별도 계획)
- ❌ 고급 통계 기능 개발 (별도 계획)
- ❌ RevenueCat 또는 외부 SDK 도입
- ❌ 서버사이드 영수증 검증
- ❌ iOS 17 미만 지원 코드
- ❌ watchOS 프리미엄 동기화 (별도 계획)
- ❌ AdMobService 구조 변경 (프리미엄 체크만 추가)
- ❌ 새로운 Analytics 이벤트 정의 (기존 것 사용)

---

## Verification Strategy (MANDATORY)

### Test Decision
- **Infrastructure exists**: YES (Swift Testing 기반)
- **User wants tests**: TDD
- **Framework**: Swift Testing (`@Test`, `#expect`)

### TDD Workflow
각 TODO는 RED-GREEN-REFACTOR 패턴:
1. **RED**: 실패하는 테스트 먼저 작성
2. **GREEN**: 테스트 통과하는 최소 구현
3. **REFACTOR**: 코드 정리 (테스트 유지)

### Test Commands
```bash
tuist test --target DrinkSomeWaterTests
```

---

## Task Flow

```
1. StoreKit Config File
       ↓
2. StoreKitServiceProtocol + MockStoreKitService
       ↓
3. StoreKitService (실제 구현)
       ↓
4. PremiumStore
       ↓
5. ServiceProvider 확장
       ↓
6. AppDelegate Transaction Listener
       ↓
7. PaywallView
       ↓
8. AdMobService 프리미엄 게이팅
       ↓
9. 설정 화면 구독 관리 섹션
       ↓
10. App Store Connect 가이드
```

## Parallelization

| Group | Tasks | Reason |
|-------|-------|--------|
| A | 2, 3 | Protocol과 구현 분리 가능 |
| B | 7, 8, 9 | UI 작업들 (Store 완성 후) |

| Task | Depends On | Reason |
|------|------------|--------|
| 3 | 2 | Protocol 필요 |
| 4 | 2, 3 | Service 필요 |
| 5 | 4 | Store 필요 |
| 6 | 4 | Store 필요 |
| 7 | 4 | Store 필요 |
| 8 | 4 | Store 필요 |
| 9 | 7 | Paywall 필요 |

---

## TODOs

### TODO 1: StoreKit Configuration File 생성

**What to do**:
- Xcode에서 StoreKit Configuration File 생성 (`DrinkSomeWater.storekit`)
- 3개 상품 정의:
  - `com.onceagain.drinksomewater.premium.monthly` (Auto-Renewable, ₩2,900/월, 7일 체험)
  - `com.onceagain.drinksomewater.premium.yearly` (Auto-Renewable, ₩19,000/년, 7일 체험)
  - `com.onceagain.drinksomewater.premium.lifetime` (Non-Consumable, ₩49,000)
- Subscription Group: `premium`
- Scheme에서 StoreKit Configuration 연결

**Must NOT do**:
- 실제 App Store Connect 상품 생성 (마지막 TODO에서 가이드)

**Parallelizable**: NO (첫 번째 작업)

**References**:
- **Pattern References**: 없음 (신규 파일)
- **Documentation**: [StoreKit Configuration File](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)

**Acceptance Criteria**:

**Manual Verification**:
- [ ] `ios/DrinkSomeWater/DrinkSomeWater.storekit` 파일 생성됨
- [ ] Xcode에서 열어서 3개 상품 확인
- [ ] Scheme → Run → Options → StoreKit Configuration 연결 확인

**Commit**: YES
- Message: `feat(storekit): add StoreKit configuration file for local testing`
- Files: `DrinkSomeWater.storekit`, Scheme 파일
- Pre-commit: N/A

---

### TODO 2: StoreKitServiceProtocol 및 MockStoreKitService 생성

**What to do**:
- `StoreKitServiceProtocol` 정의:
  - `func loadProducts() async throws -> [Product]`
  - `func purchase(_ product: Product) async throws -> Transaction`
  - `func restorePurchases() async throws`
  - `var currentEntitlements: AsyncStream<EntitlementState> { get }`
  - `var isPremium: Bool { get }`
- `EntitlementState` enum 정의: `.free`, `.premium(expirationDate: Date?)`
- `MockStoreKitService` 생성 (테스트용)

**Must NOT do**:
- 실제 StoreKit API 호출 (다음 TODO)

**Parallelizable**: YES (with TODO 3)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/Services/CloudSyncServiceProtocol` - Protocol 정의 패턴
  - `ios/DrinkSomeWaterTests/Mocks/MockServices.swift` - Mock 서비스 패턴

**Acceptance Criteria**:

**TDD (tests enabled)**:
- [ ] 테스트 파일: `ios/DrinkSomeWaterTests/StoreKitServiceTests.swift`
- [ ] `tuist test` → PASS

**Test Cases**:
```swift
@Test func mockService_loadProducts_returnsProducts()
@Test func mockService_purchase_updatesEntitlements()
@Test func mockService_isPremium_reflectsEntitlementState()
```

**Commit**: YES
- Message: `feat(storekit): add StoreKitServiceProtocol and MockStoreKitService`
- Files: `Services/StoreKitService.swift` (protocol only), `Mocks/MockStoreKitService.swift`, `Tests/StoreKitServiceTests.swift`
- Pre-commit: `tuist test`

---

### TODO 3: StoreKitService 실제 구현

**What to do**:
- `StoreKitService` 클래스 구현 (StoreKit 2 API 사용):
  - `Product.products(for:)` 로 상품 로드
  - `product.purchase()` 로 구매
  - `Transaction.currentEntitlements` 로 현재 구매 상태 확인
  - `AppStore.sync()` 로 구매 복원
- Transaction 검증 로직 (`verificationResult.payloadValue`)
- Entitlement 상태 관리:
  - `.subscribed`, `.inGracePeriod`, `.inBillingRetryPeriod` → premium
  - `.revoked`, `.expired` → free
- Non-Consumable (평생) 처리

**Must NOT do**:
- 서버사이드 검증

**Parallelizable**: YES (with TODO 2)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/Services/CloudSyncService.swift:50-80` - Service 구현 패턴
- **External References**:
  - [StoreKit 2 Tutorial](https://developer.apple.com/documentation/storekit/in-app_purchase/implementing_a_store_in_your_app_using_the_storekit_api)
  - [GitHub Demo](https://github.com/aisultanios/storekit-2-demo-app)

**Acceptance Criteria**:

**TDD (tests enabled)**:
- [ ] `tuist test` → PASS (Mock 사용)

**Manual Execution Verification**:
- [ ] StoreKit Sandbox에서 상품 로드 확인
- [ ] 구매 플로우 시뮬레이션 (Configuration File 사용)

**Commit**: YES
- Message: `feat(storekit): implement StoreKitService with StoreKit 2 API`
- Files: `Services/StoreKitService.swift`
- Pre-commit: `tuist test`

---

### TODO 4: PremiumStore 생성

**What to do**:
- `PremiumStore` 클래스 생성 (@Observable Store 패턴):
  - `enum Action`: `.loadProducts`, `.purchase(Product)`, `.restore`, `.refreshEntitlements`
  - State: `products: [Product]`, `isPremium: Bool`, `isLoading: Bool`, `error: Error?`
  - `send(_ action: Action) async` 메서드
- Analytics 이벤트 연동:
  - `Analytics.shared.log(.purchaseStarted(...))` 구매 시작 시
  - `Analytics.shared.log(.purchaseCompleted(...))` 구매 완료 시
  - `Analytics.shared.log(.purchaseFailed(...))` 구매 실패 시
  - `Analytics.shared.setPremiumStatus(...)` 상태 변경 시

**Must NOT do**:
- 새로운 Analytics 이벤트 정의

**Parallelizable**: NO (TODO 2, 3 의존)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/Stores/HomeStore.swift` - Store 패턴 (Action enum, send 메서드)
  - `ios/DrinkSomeWater/Sources/Stores/HomeStore.swift:57-62` - Analytics 로깅 패턴
- **API/Type References**:
  - `ios/Analytics/Sources/AnalyticsEvent.swift:73-77` - Premium 이벤트 정의
  - `ios/Analytics/Sources/Analytics.swift:97-99` - setPremiumStatus 메서드

**Acceptance Criteria**:

**TDD (tests enabled)**:
- [ ] 테스트 파일: `ios/DrinkSomeWaterTests/PremiumStoreTests.swift`
- [ ] `tuist test` → PASS

**Test Cases**:
```swift
@Test func store_loadProducts_updatesProducts()
@Test func store_purchase_updatesIsPremium()
@Test func store_restore_refreshesEntitlements()
@Test func store_purchaseCompleted_logsAnalytics()
```

**Commit**: YES
- Message: `feat(premium): add PremiumStore with @Observable pattern`
- Files: `Stores/PremiumStore.swift`, `Tests/PremiumStoreTests.swift`
- Pre-commit: `tuist test`

---

### TODO 5: ServiceProvider 확장

**What to do**:
- `ServiceProviderProtocol`에 `storeKitService: StoreKitServiceProtocol` 추가
- `ServiceProvider` 구현 업데이트
- `MockServiceProvider` 업데이트

**Must NOT do**:
- 기존 서비스 구조 변경

**Parallelizable**: NO (TODO 4 의존)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/Services/ServiceProvider.swift` - Provider 패턴
  - `ios/DrinkSomeWaterTests/Mocks/MockServices.swift` - MockServiceProvider

**Acceptance Criteria**:

**TDD (tests enabled)**:
- [ ] 기존 테스트 모두 통과 (`tuist test`)
- [ ] `MockServiceProvider`에 `MockStoreKitService` 포함 확인

**Commit**: YES
- Message: `feat(di): add StoreKitService to ServiceProvider`
- Files: `Services/ServiceProvider.swift`, `Mocks/MockServices.swift`
- Pre-commit: `tuist test`

---

### TODO 6: AppDelegate Transaction Listener 설정

**What to do**:
- `AppDelegate.swift`에서 앱 시작 시 `Transaction.updates` 리스너 설정
- 외부 구매/갱신/취소 감지
- `PremiumStore` 업데이트 트리거

**Must NOT do**:
- SceneDelegate 수정

**Parallelizable**: NO (TODO 4 의존)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/AppDelegate.swift` - 현재 AppDelegate 구조
- **External References**:
  - [Transaction.updates](https://developer.apple.com/documentation/storekit/transaction/3851206-updates)

**Acceptance Criteria**:

**Manual Execution Verification**:
- [ ] 앱 시작 시 로그 확인: `[StoreKit] Transaction listener started`
- [ ] Sandbox에서 구독 갱신 시 상태 자동 업데이트 확인

**Commit**: YES
- Message: `feat(storekit): add Transaction.updates listener in AppDelegate`
- Files: `AppDelegate.swift`
- Pre-commit: `tuist test`

---

### TODO 7: PaywallView 생성

**What to do**:
- `PaywallView.swift` 생성 (SwiftUI)
- `SubscriptionStoreView` 래핑 (iOS 17+ 내장 UI)
- Non-Consumable (평생) 상품은 `ProductView`로 별도 표시
- "구매 복원" 버튼 추가
- Analytics 이벤트: `premiumPromptShown(triggerPoint:, variant:)` 호출

**Must NOT do**:
- 완전 커스텀 UI 구현 (SubscriptionStoreView 사용)

**Parallelizable**: YES (with TODO 8, 9)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/Views/HomeView.swift` - SwiftUI View 패턴
- **External References**:
  - [SubscriptionStoreView Guide](https://revenuecat.com/blog/engineering/storekit-views-guide-paywall-swift-ui)

**Acceptance Criteria**:

**Manual Execution Verification**:
- [ ] 페이월 표시 시 3개 상품 (월간, 연간, 평생) 모두 표시
- [ ] 구매 버튼 탭 시 StoreKit 구매 시트 표시
- [ ] "구매 복원" 버튼 동작 확인

**Commit**: YES
- Message: `feat(ui): add PaywallView with SubscriptionStoreView`
- Files: `Views/PaywallView.swift`
- Pre-commit: `tuist test`

---

### TODO 8: AdMobService 프리미엄 게이팅 추가

**What to do**:
- `AdMobService`에 프리미엄 체크 로직 추가:
  - `isPremium` 플래그 주입 (또는 `PremiumStore` 참조)
  - 광고 표시 전 `isPremium` 확인
  - `isPremium == true`면 광고 미표시
- 기존 광고 호출 위치 수정 없이, 내부에서 게이팅

**Must NOT do**:
- AdMobService 구조 변경 (게이팅 로직만 추가)
- 광고 호출 위치 변경

**Parallelizable**: YES (with TODO 7, 9)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/Services/AdMobService.swift` - 현재 구현
- **Tool Usage**:
  - `lsp_find_references` - AdMobService 사용처 파악

**Acceptance Criteria**:

**TDD (tests enabled)**:
- [ ] 테스트: 프리미엄 시 광고 미표시 확인
- [ ] `tuist test` → PASS

**Test Cases**:
```swift
@Test func adService_whenPremium_doesNotShowBanner()
@Test func adService_whenFree_showsBanner()
```

**Commit**: YES
- Message: `feat(ads): add premium gating to AdMobService`
- Files: `Services/AdMobService.swift`, 테스트 파일
- Pre-commit: `tuist test`

---

### TODO 9: 설정 화면에 구독 관리 섹션 추가

**What to do**:
- `SettingsViewController`에 "프리미엄" 섹션 추가:
  - 프리미엄 상태 표시 (무료/프리미엄)
  - 프리미엄이면: 구독 관리 (App Store 설정으로 이동)
  - 무료면: "프리미엄 업그레이드" 버튼 → PaywallView 표시
- Analytics: `premiumPromptShown(triggerPoint: "settings", variant: nil)`

**Must NOT do**:
- 설정 화면 전체 구조 변경

**Parallelizable**: NO (TODO 7 의존)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/ViewController/Settings/SettingsViewController.swift:73-95` - 섹션 구조

**Acceptance Criteria**:

**Manual Execution Verification**:
- [ ] 설정 화면에 "프리미엄" 섹션 표시
- [ ] 무료 사용자: "프리미엄 업그레이드" 탭 → 페이월 표시
- [ ] 프리미엄 사용자: 구독 상태 + 관리 링크 표시

**Commit**: YES
- Message: `feat(settings): add premium subscription section`
- Files: `ViewController/Settings/SettingsViewController.swift`
- Pre-commit: `tuist test`

---

### TODO 10: App Store Connect 상품 설정 가이드 작성

**What to do**:
- `docs/APP_STORE_CONNECT_SETUP.md` 문서 작성:
  - In-App Purchase 상품 생성 가이드
  - Product ID, 가격, 무료 체험 설정
  - Subscription Group 설정
  - 스크린샷 포함 (선택)
  - 심사 제출 전 체크리스트

**Must NOT do**:
- 실제 App Store Connect 작업 (문서만 작성)

**Parallelizable**: YES (독립 작업)

**References**:
- **Documentation**:
  - [App Store Connect Help](https://help.apple.com/app-store-connect/)

**Acceptance Criteria**:

**Manual Verification**:
- [ ] `docs/APP_STORE_CONNECT_SETUP.md` 파일 존재
- [ ] 3개 상품 설정 방법 명시
- [ ] 무료 체험 설정 방법 명시

**Commit**: YES
- Message: `docs: add App Store Connect setup guide for subscriptions`
- Files: `docs/APP_STORE_CONNECT_SETUP.md`
- Pre-commit: N/A

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `feat(storekit): add StoreKit configuration file` | .storekit, scheme | Manual |
| 2 | `feat(storekit): add StoreKitServiceProtocol and Mock` | Protocol, Mock, Tests | `tuist test` |
| 3 | `feat(storekit): implement StoreKitService` | Service | `tuist test` |
| 4 | `feat(premium): add PremiumStore` | Store, Tests | `tuist test` |
| 5 | `feat(di): add StoreKitService to ServiceProvider` | Provider, Mock | `tuist test` |
| 6 | `feat(storekit): add Transaction listener` | AppDelegate | `tuist test` |
| 7 | `feat(ui): add PaywallView` | View | `tuist test` |
| 8 | `feat(ads): add premium gating` | AdMobService, Tests | `tuist test` |
| 9 | `feat(settings): add premium section` | SettingsVC | `tuist test` |
| 10 | `docs: add App Store Connect guide` | docs/ | Manual |

---

## Success Criteria

### Verification Commands
```bash
tuist test  # Expected: All tests pass
```

### Final Checklist
- [ ] `PremiumStore.isPremium` 상태 정확히 반영
- [ ] 프리미엄 사용자 광고 미표시
- [ ] 구매 복원 정상 동작
- [ ] 앱 재시작 시 프리미엄 상태 유지
- [ ] Analytics 이벤트 정상 기록
- [ ] StoreKit Sandbox 테스트 통과
