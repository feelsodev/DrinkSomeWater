# Learnings - Freemium Subscription Feature

## Conventions
(To be filled as we discover patterns)

## Patterns
(To be filled with reusable patterns)

## Gotchas
(To be filled with discovered issues)

## StoreKit Configuration File Created (Task 1)

### File Structure
- Location: `ios/DrinkSomeWater/DrinkSomeWater.storekit`
- Format: JSON (StoreKit Configuration File format v3.0)
- Locale: Korean (ko) as primary, English (en_US) as secondary

### Products Defined
1. **Monthly Subscription** (com.onceagain.drinksomewater.premium.monthly)
   - Price: ₩2,900/month
   - 7-day free trial (P1W)
   - Recurring: Monthly (P1M)
   - Family Shareable: No
   - Group: premium (ID: 21527764)

2. **Yearly Subscription** (com.onceagain.drinksomewater.premium.yearly)
   - Price: ₩19,000/year  
   - 7-day free trial (P1W)
   - Recurring: Yearly (P1Y)
   - 45% discount vs monthly (₩34,800)
   - Family Shareable: No
   - Group: premium (ID: 21527764)

3. **Lifetime Purchase** (com.onceagain.drinksomewater.premium.lifetime)
   - Price: ₩49,000 (one-time)
   - Type: NonConsumable
   - Family Shareable: Yes
   - No expiration

### Subscription Group
- Name: "premium"
- Contains 2 auto-renewable subscriptions
- Korean/English localizations

### Settings
- Default locale: Korean (ko)
- Default storefront: Korea (KOR)
- Transaction failures: Disabled (for testing)

### Next Steps
- Scheme configuration needed to link this file
- Products must be created in App Store Connect for production

## [2026-01-27 11:30] Task 1: StoreKit Configuration File - COMPLETED

### What Was Done
- ✅ Created `ios/DrinkSomeWater/DrinkSomeWater.storekit` with 3 products
- ✅ Configured scheme to link StoreKit configuration file
- ✅ Committed changes (commit: b8fdd3f)

### Scheme Configuration
- Added `storeKitConfigurationFileReference = "../DrinkSomeWater.storekit"` to LaunchAction
- Relative path from scheme file to .storekit file

### Verification
- File exists at correct location
- Scheme properly references the configuration
- Ready for local StoreKit testing

### Next Steps
- Task 2: Create StoreKitServiceProtocol and MockStoreKitService
- Task 3: Implement actual StoreKitService

## [2026-01-27 11:45] Task 2: StoreKitServiceProtocol and MockStoreKitService - COMPLETED

### What Was Done
- ✅ Created `ios/DrinkSomeWater/Sources/Services/StoreKitService.swift` with protocol definition
- ✅ Defined `EntitlementState` enum: `.free`, `.premium(expirationDate: Date?)`
- ✅ Created `MockStoreKitService.swift` with controllable behavior
- ✅ Created `StoreKitServiceTests.swift` with 10 comprehensive tests
- ✅ All tests pass (10/10 ✔)

### Protocol Definition
```swift
@MainActor
protocol StoreKitServiceProtocol: AnyObject {
    func loadProducts() async throws -> [Product]
    func purchase(_ product: Product) async throws -> Transaction
    func restorePurchases() async throws
    var currentEntitlements: AsyncStream<EntitlementState> { get }
    var isPremium: Bool { get }
}
```

### EntitlementState Enum
```swift
enum EntitlementState: Sendable {
    case free
    case premium(expirationDate: Date?)
}
```

### Mock Service Features
- Controllable state: `mockProducts`, `mockEntitlementState`, `mockIsPremium`
- Call tracking: `loadProductsCalled`, `purchaseCalled`, `restorePurchasesCalled`
- Error simulation: `shouldThrowOnLoadProducts`, `shouldThrowOnPurchase`, `shouldThrowOnRestore`
- Helper methods: `setEntitlementState()`, `reset()`
- AsyncStream support for `currentEntitlements`

### Test Coverage
1. `mockService_loadProducts_callsLoadProducts()` - Verifies load tracking
2. `mockService_loadProducts_throwsWhenConfigured()` - Error handling
3. `mockService_restorePurchases_succeeds()` - Restore functionality
4. `mockService_restorePurchases_throwsWhenConfigured()` - Error handling
5. `mockService_isPremium_reflectsEntitlementState()` - State reflection
6. `mockService_currentEntitlements_streamsState()` - AsyncStream behavior
7. `mockService_reset_clearsAllState()` - Reset functionality
8. `mockService_entitlementState_withExpirationDate()` - Expiration handling
9. `entitlementState_free_isPremiumFalse()` - Enum behavior
10. `entitlementState_premium_withoutExpiration()` - Enum behavior

### Key Learnings
- StoreKit's `Product` and `Transaction` are concrete structs, not protocols
- `Transaction.all` returns `AsyncSequence<VerificationResult<Transaction>>`
- Must unwrap `VerificationResult` with pattern matching: `if case .verified(let transaction)`
- `@MainActor` annotation required for protocol and mock service
- `Sendable` protocol needed for `EntitlementState` enum
- Swift Testing framework uses `@Test` macro instead of `func test`
- AsyncStream can be created inline with continuation pattern

### Next Steps
- Task 3: Implement actual StoreKitService with real StoreKit API calls
- Task 4: Integrate StoreKitService into ServiceProvider
- Task 5: Add premium feature gating to app features

## [2026-01-27 02:45] Task 3: StoreKitService Implementation - COMPLETED

### What Was Done
- ✅ Implemented `StoreKitService` class conforming to `StoreKitServiceProtocol`
- ✅ Product loading with `Product.products(for:)` sorted by price
- ✅ Purchase flow with transaction verification via `VerificationResult`
- ✅ Restore purchases using `AppStore.sync()`
- ✅ `currentEntitlements` AsyncStream monitoring `Transaction.updates`
- ✅ Subscription state handling: `.subscribed`, `.inGracePeriod`, `.inBillingRetryPeriod` → premium
- ✅ Non-consumable (lifetime) product handled as premium with nil expiration
- ✅ Build passes with Swift 6 strict concurrency

### Key Implementation Details

**Transaction Listener Pattern:**
```swift
private func listenForTransactions() -> Task<Void, Error> {
    Task.detached { [weak self] in
        for await result in Transaction.updates {
            guard let verifiedTransaction = Self.verifyTransaction(result) else { continue }
            await self?.handleTransactionUpdate()
            await verifiedTransaction.finish()
        }
    }
}
```

**Entitlement Check Pattern:**
```swift
for await result in Transaction.currentEntitlements {
    guard case .verified(let transaction) = result else { continue }
    guard Self.productIDs.contains(transaction.productID) else { continue }
    guard transaction.revocationDate == nil else { continue }
    
    switch transaction.productType {
    case .nonConsumable:
        newState = .premium(expirationDate: nil)
    case .autoRenewable:
        // Check expiration and subscription status
    }
}
```

**Subscription Status Check:**
```swift
let statuses = try await subscription.status
for status in statuses {
    switch status.state {
    case .subscribed, .inGracePeriod, .inBillingRetryPeriod:
        // Premium
    case .expired, .revoked:
        // Free
    }
}
```

### Key Learnings

1. **Swift 6 Concurrency**: Static methods in `@MainActor` classes need `nonisolated` modifier to be called from detached tasks
2. **VerificationResult**: Use pattern matching `case .verified(let transaction)` to unwrap
3. **RenewalInfo vs Transaction**: `RenewalInfo` doesn't have `expirationDate` - get it from the transaction in `status.transaction`
4. **Product.SubscriptionInfo.Status**: Contains both `transaction` and `renewalInfo` as `VerificationResult` types
5. **Transaction.currentEntitlements**: Returns all currently entitled transactions (subscriptions + non-consumables)
6. **Non-consumable handling**: Check `productType == .nonConsumable` for lifetime purchases

### Files Modified
- `ios/DrinkSomeWater/Sources/Services/StoreKitService.swift` - Added implementation class

### Next Steps
- Task 4: Integrate StoreKitService into ServiceProvider
- Task 5: Add premium feature gating to app features

## [2026-01-27 02:55] Task 4: PremiumStore Implementation - COMPLETED

### What Was Done
- ✅ Created `ios/DrinkSomeWater/Sources/Stores/PremiumStore.swift` with @Observable pattern
- ✅ Implemented 4 actions: loadProducts, purchase, restore, refreshEntitlements
- ✅ Integrated Analytics events for purchase flow
- ✅ Created comprehensive test suite (10 tests, all passing)

### PremiumStore Structure
```swift
@MainActor @Observable
final class PremiumStore {
    enum Action {
        case loadProducts
        case purchase(Product)
        case restore
        case refreshEntitlements
    }
    
    var products: [Product] = []
    var isPremium: Bool = false
    var isLoading: Bool = false
    var error: Error?
    
    private let storeKitService: StoreKitServiceProtocol
    
    func send(_ action: Action) async { ... }
}
```

### Analytics Integration
- `purchaseStarted(productId:, price:)` - logged when purchase begins
- `purchaseCompleted(productId:, price:, currency:)` - logged on success
- `purchaseFailed(productId:, errorCode:)` - logged on failure
- `setPremiumStatus(.premium/.free)` - called on state changes

### Key Learnings

1. **StoreKitServiceError Extension**: Added `errorCode` property to convert errors to analytics-friendly strings
2. **Product.priceFormatStyle.currencyCode**: Returns non-optional String, no need for nil coalescing
3. **Testing StoreKit**: Cannot use `Product.products(for:)` in unit tests without StoreKit Configuration - use MockStoreKitService instead
4. **Analytics Pattern**: Follow existing pattern from HomeStore - log events at action boundaries

### Test Coverage
1. `store_loadProducts_updatesProducts()` - Verifies load tracking
2. `store_loadProducts_setsErrorOnFailure()` - Error handling
3. `store_purchase_updatesPremiumOnSuccess()` - Premium state update
4. `store_purchase_remainsFreeOnFailure()` - Error handling
5. `store_restore_callsRestorePurchases()` - Restore functionality
6. `store_restore_setsErrorOnFailure()` - Error handling
7. `store_refreshEntitlements_updatesPremiumStatus()` - State refresh
8. `store_refreshEntitlements_detectsFreeStatus()` - Free state detection
9. `store_isLoadingDuringOperations()` - Loading state
10. `store_initialState_isFree()` - Initial state verification

### Files Created
- `ios/DrinkSomeWater/Sources/Stores/PremiumStore.swift`
- `ios/DrinkSomeWaterTests/PremiumStoreTests.swift`

### Next Steps
- Task 5: Integrate PremiumStore into ServiceProvider
- Task 6: Add premium feature gating
- Task 7: Create PremiumView UI
