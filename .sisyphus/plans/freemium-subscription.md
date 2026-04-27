# Freemium/Subscription Model Introduction - StoreKit 2 Infrastructure Setup

## Context

### Original Request
Diversify monetization for the Gulp (벌컥벌컥) water intake tracking app by introducing a freemium/subscription model.

### Interview Summary
**Key Discussions**:
- Subscription model: 3 options - Monthly (₩2,900) + Annual (₩19,000) + Lifetime (₩49,000)
- Premium benefits: Ad removal (themes/statistics planned separately)
- Technology choice: Native StoreKit 2
- Lifetime product: Implemented as Non-Consumable
- Paywall UI: SubscriptionStoreView (built into iOS 17+)
- Free trial: 7 days (applies to monthly/annual subscriptions)
- iCloud sync: Remains free (not premium-gated)
- Testing: TDD approach

**Research Findings**:
- Project: iOS 18+, Swift 6, @Observable Store pattern
- Analytics premium events already defined (`premiumPromptShown`, `purchaseStarted/Completed/Failed`)
- PremiumStatus enum exists (`free`/`premium`)
- AdMobService implemented (banner, rewarded, native)
- Test infrastructure exists (Swift Testing + MockServices)

### Metis Review
**Identified Gaps** (addressed):
- Lifetime product type → decided: Non-Consumable
- iCloud gating scope → decided: remains free
- Paywall UI choice → decided: SubscriptionStoreView
- Transaction.updates listener → set up in AppDelegate (included in plan)
- watchOS sync → out of scope for this plan (separate plan)

---

## Work Objectives

### Core Objective
Build a StoreKit 2-based subscription infrastructure to provide premium subscription purchases and ad removal.

### Concrete Deliverables
- `StoreKitService.swift` - StoreKit 2 integration service
- `PremiumStore.swift` - Premium state management store
- `PaywallView.swift` - Paywall UI (wrapping SubscriptionStoreView)
- `StoreKit Configuration File` - For local testing
- AdMobService premium gating logic
- Subscription management section in settings screen

### Definition of Done
- [x] `tuist test` → all tests pass
- [x] Purchase flow works correctly in StoreKit Sandbox
- [x] Premium users don't see ads
- [x] Purchase restoration works correctly
- [x] Analytics events recorded correctly

### Must Have
- StoreKit 2 product loading and purchasing
- Transaction verification and state management
- Purchase restoration
- Premium state persistence (restored on app restart)
- Conditional ad removal logic
- Paywall UI

### Must NOT Have (Guardrails)
- ❌ Theme/customization feature development (separate plan)
- ❌ Advanced statistics feature development (separate plan)
- ❌ RevenueCat or external SDK integration
- ❌ Server-side receipt validation
- ❌ Code supporting iOS below 17
- ❌ watchOS premium sync (separate plan)
- ❌ AdMobService structural changes (only add premium check)
- ❌ New Analytics event definitions (use existing ones)

---

## Verification Strategy (MANDATORY)

### Test Decision
- **Infrastructure exists**: YES (Swift Testing based)
- **User wants tests**: TDD
- **Framework**: Swift Testing (`@Test`, `#expect`)

### TDD Workflow
Each TODO follows RED-GREEN-REFACTOR pattern:
1. **RED**: Write failing tests first
2. **GREEN**: Minimum implementation to pass tests
3. **REFACTOR**: Clean up code (keep tests green)

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
3. StoreKitService (actual implementation)
       ↓
4. PremiumStore
       ↓
5. ServiceProvider extension
       ↓
6. AppDelegate Transaction Listener
       ↓
7. PaywallView
       ↓
8. AdMobService premium gating
       ↓
9. Settings screen subscription management section
       ↓
10. App Store Connect guide
```

## Parallelization

| Group | Tasks | Reason |
|-------|-------|--------|
| A | 2, 3 | Protocol and implementation can be separated |
| B | 7, 8, 9 | UI tasks (after Store is complete) |

| Task | Depends On | Reason |
|------|------------|--------|
| 3 | 2 | Needs Protocol |
| 4 | 2, 3 | Needs Service |
| 5 | 4 | Needs Store |
| 6 | 4 | Needs Store |
| 7 | 4 | Needs Store |
| 8 | 4 | Needs Store |
| 9 | 7 | Needs Paywall |

---

## TODOs

- [x] **TODO 1: Create StoreKit Configuration File**

**What to do**:
- Create StoreKit Configuration File in Xcode (`DrinkSomeWater.storekit`)
- Define 3 products:
  - `com.onceagain.drinksomewater.premium.monthly` (Auto-Renewable, ₩2,900/month, 7-day trial)
  - `com.onceagain.drinksomewater.premium.yearly` (Auto-Renewable, ₩19,000/year, 7-day trial)
  - `com.onceagain.drinksomewater.premium.lifetime` (Non-Consumable, ₩49,000)
- Subscription Group: `premium`
- Link StoreKit Configuration in Scheme

**Must NOT do**:
- Create actual App Store Connect products (guide provided in last TODO)

**Parallelizable**: NO (first task)

**References**:
- **Pattern References**: None (new file)
- **Documentation**: [StoreKit Configuration File](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)

**Acceptance Criteria**:

**Manual Verification**:
- [ ] `ios/DrinkSomeWater/DrinkSomeWater.storekit` file created
- [ ] Open in Xcode and verify 3 products
- [ ] Scheme → Run → Options → StoreKit Configuration linked

**Commit**: YES
- Message: `feat(storekit): add StoreKit configuration file for local testing`
- Files: `DrinkSomeWater.storekit`, Scheme file
- Pre-commit: N/A

---

- [x] **TODO 2: Create StoreKitServiceProtocol and MockStoreKitService**

**What to do**:
- Define `StoreKitServiceProtocol`:
  - `func loadProducts() async throws -> [Product]`
  - `func purchase(_ product: Product) async throws -> Transaction`
  - `func restorePurchases() async throws`
  - `var currentEntitlements: AsyncStream<EntitlementState> { get }`
  - `var isPremium: Bool { get }`
- Define `EntitlementState` enum: `.free`, `.premium(expirationDate: Date?)`
- Create `MockStoreKitService` (for testing)

**Must NOT do**:
- Actual StoreKit API calls (next TODO)

**Parallelizable**: YES (with TODO 3)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/Services/CloudSyncServiceProtocol` - Protocol definition pattern
  - `ios/DrinkSomeWaterTests/Mocks/MockServices.swift` - Mock service pattern

**Acceptance Criteria**:

**TDD (tests enabled)**:
- [ ] Test file: `ios/DrinkSomeWaterTests/StoreKitServiceTests.swift`
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

- [x] **TODO 3: Implement StoreKitService**

**What to do**:
- Implement `StoreKitService` class (using StoreKit 2 API):
  - Load products with `Product.products(for:)`
  - Purchase with `product.purchase()`
  - Check current purchase state with `Transaction.currentEntitlements`
  - Restore purchases with `AppStore.sync()`
- Transaction verification logic (`verificationResult.payloadValue`)
- Entitlement state management:
  - `.subscribed`, `.inGracePeriod`, `.inBillingRetryPeriod` → premium
  - `.revoked`, `.expired` → free
- Non-Consumable (lifetime) handling

**Must NOT do**:
- Server-side validation

**Parallelizable**: YES (with TODO 2)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/Services/CloudSyncService.swift:50-80` - Service implementation pattern
- **External References**:
  - [StoreKit 2 Tutorial](https://developer.apple.com/documentation/storekit/in-app_purchase/implementing_a_store_in_your_app_using_the_storekit_api)
  - [GitHub Demo](https://github.com/aisultanios/storekit-2-demo-app)

**Acceptance Criteria**:

**TDD (tests enabled)**:
- [ ] `tuist test` → PASS (using Mock)

**Manual Execution Verification**:
- [ ] Products load successfully in StoreKit Sandbox
- [ ] Purchase flow simulation (using Configuration File)

**Commit**: YES
- Message: `feat(storekit): implement StoreKitService with StoreKit 2 API`
- Files: `Services/StoreKitService.swift`
- Pre-commit: `tuist test`

---

- [x] **TODO 4: Create PremiumStore**

**What to do**:
- Create `PremiumStore` class (@Observable Store pattern):
  - `enum Action`: `.loadProducts`, `.purchase(Product)`, `.restore`, `.refreshEntitlements`
  - State: `products: [Product]`, `isPremium: Bool`, `isLoading: Bool`, `error: Error?`
  - `send(_ action: Action) async` method
- Analytics event integration:
  - `Analytics.shared.log(.purchaseStarted(...))` on purchase start
  - `Analytics.shared.log(.purchaseCompleted(...))` on purchase complete
  - `Analytics.shared.log(.purchaseFailed(...))` on purchase failure
  - `Analytics.shared.setPremiumStatus(...)` on state change

**Must NOT do**:
- Define new Analytics events

**Parallelizable**: NO (depends on TODO 2, 3)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/Stores/HomeStore.swift` - Store pattern (Action enum, send method)
  - `ios/DrinkSomeWater/Sources/Stores/HomeStore.swift:57-62` - Analytics logging pattern
- **API/Type References**:
  - `ios/Analytics/Sources/AnalyticsEvent.swift:73-77` - Premium event definitions
  - `ios/Analytics/Sources/Analytics.swift:97-99` - setPremiumStatus method

**Acceptance Criteria**:

**TDD (tests enabled)**:
- [ ] Test file: `ios/DrinkSomeWaterTests/PremiumStoreTests.swift`
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

- [x] **TODO 5: Extend ServiceProvider**

**What to do**:
- Add `storeKitService: StoreKitServiceProtocol` to `ServiceProviderProtocol`
- Update `ServiceProvider` implementation
- Update `MockServiceProvider`

**Must NOT do**:
- Change existing service structure

**Parallelizable**: NO (depends on TODO 4)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/Services/ServiceProvider.swift` - Provider pattern
  - `ios/DrinkSomeWaterTests/Mocks/MockServices.swift` - MockServiceProvider

**Acceptance Criteria**:

**TDD (tests enabled)**:
- [ ] All existing tests pass (`tuist test`)
- [ ] `MockServiceProvider` includes `MockStoreKitService`

**Commit**: YES
- Message: `feat(di): add StoreKitService to ServiceProvider`
- Files: `Services/ServiceProvider.swift`, `Mocks/MockServices.swift`
- Pre-commit: `tuist test`

---

- [x] **TODO 6: Set Up AppDelegate Transaction Listener**

**What to do**:
- Set up `Transaction.updates` listener in `AppDelegate.swift` on app launch
- Detect external purchases/renewals/cancellations
- Trigger `PremiumStore` update

**Must NOT do**:
- Modify SceneDelegate

**Parallelizable**: NO (depends on TODO 4)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/AppDelegate.swift` - Current AppDelegate structure
- **External References**:
  - [Transaction.updates](https://developer.apple.com/documentation/storekit/transaction/3851206-updates)

**Acceptance Criteria**:

**Manual Execution Verification**:
- [ ] Confirm log on app launch: `[StoreKit] Transaction listener started`
- [ ] Confirm status auto-updates on subscription renewal in Sandbox

**Commit**: YES
- Message: `feat(storekit): add Transaction.updates listener in AppDelegate`
- Files: `AppDelegate.swift`
- Pre-commit: `tuist test`

---

- [x] **TODO 7: Create PaywallView**

**What to do**:
- Create `PaywallView.swift` (SwiftUI)
- Wrap `SubscriptionStoreView` (built into iOS 17+)
- Show Non-Consumable (lifetime) product separately with `ProductView`
- Add "Restore Purchases" button
- Fire Analytics event: `premiumPromptShown(triggerPoint:, variant:)` on appear

**Must NOT do**:
- Fully custom UI implementation (use SubscriptionStoreView)

**Parallelizable**: YES (with TODO 8, 9)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/Views/HomeView.swift` - SwiftUI View pattern
- **External References**:
  - [SubscriptionStoreView Guide](https://revenuecat.com/blog/engineering/storekit-views-guide-paywall-swift-ui)

**Acceptance Criteria**:

**Manual Execution Verification**:
- [ ] All 3 products (monthly, annual, lifetime) shown when paywall displays
- [ ] StoreKit purchase sheet shown on tap of purchase button
- [ ] "Restore Purchases" button works

**Commit**: YES
- Message: `feat(ui): add PaywallView with SubscriptionStoreView`
- Files: `Views/PaywallView.swift`
- Pre-commit: `tuist test`

---

- [x] **TODO 8: Add Premium Gating to AdMobService**

**What to do**:
- Add premium check logic to `AdMobService`:
  - Inject `isPremium` flag (or reference `PremiumStore`)
  - Check `isPremium` before showing ads
  - Skip ads when `isPremium == true`
- Gate internally without modifying existing ad call sites

**Must NOT do**:
- Change AdMobService structure (only add gating logic)
- Change ad call sites

**Parallelizable**: YES (with TODO 7, 9)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/Services/AdMobService.swift` - Current implementation
- **Tool Usage**:
  - `lsp_find_references` - Find AdMobService usage

**Acceptance Criteria**:

**TDD (tests enabled)**:
- [ ] Test: confirm ads not shown when premium
- [ ] `tuist test` → PASS

**Test Cases**:
```swift
@Test func adService_whenPremium_doesNotShowBanner()
@Test func adService_whenFree_showsBanner()
```

**Commit**: YES
- Message: `feat(ads): add premium gating to AdMobService`
- Files: `Services/AdMobService.swift`, test file
- Pre-commit: `tuist test`

---

- [x] **TODO 9: Add Subscription Management Section to Settings Screen**

**What to do**:
- Add "Premium" section to `SettingsViewController`:
  - Show premium status (free/premium)
  - If premium: subscription management (link to App Store settings)
  - If free: "Upgrade to Premium" button → show PaywallView
- Analytics: `premiumPromptShown(triggerPoint: "settings", variant: nil)`

**Must NOT do**:
- Change entire settings screen structure

**Parallelizable**: NO (depends on TODO 7)

**References**:
- **Pattern References**:
  - `ios/DrinkSomeWater/Sources/ViewController/Settings/SettingsViewController.swift:73-95` - Section structure

**Acceptance Criteria**:

**Manual Execution Verification**:
- [ ] "Premium" section shown in settings
- [ ] Free user: tap "Upgrade to Premium" → paywall shown
- [ ] Premium user: subscription status + management link shown

**Commit**: YES
- Message: `feat(settings): add premium subscription section`
- Files: `ViewController/Settings/SettingsViewController.swift`
- Pre-commit: `tuist test`

---

- [x] **TODO 10: Write App Store Connect Product Setup Guide**

**What to do**:
- Write `docs/APP_STORE_CONNECT_SETUP.md`:
  - In-App Purchase product creation guide
  - Product ID, pricing, free trial setup
  - Subscription Group setup
  - Screenshots (optional)
  - Pre-submission checklist

**Must NOT do**:
- Actual App Store Connect work (documentation only)

**Parallelizable**: YES (independent task)

**References**:
- **Documentation**:
  - [App Store Connect Help](https://help.apple.com/app-store-connect/)

**Acceptance Criteria**:

**Manual Verification**:
- [ ] `docs/APP_STORE_CONNECT_SETUP.md` file exists
- [ ] Setup instructions for all 3 products documented
- [ ] Free trial setup instructions documented

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
- [x] `PremiumStore.isPremium` state accurately reflected
- [x] Premium users don't see ads
- [x] Purchase restoration works correctly
- [x] Premium status persists on app restart
- [x] Analytics events recorded correctly
- [x] StoreKit Sandbox tests pass
