# iOS Subscription Price & Product Audit

Use this checklist before TestFlight or App Store submission to verify that the paywall and App Store Connect configuration remain aligned.

## Products

| Plan | Product ID | Type | Korean target price | Notes |
|---|---|---|---:|---|
| Monthly | `com.onceagain.drinksomewater.subscription.monthly` | Auto-renewable subscription | ₩990 | In `premium` subscription group; 7-day free trial |
| Yearly | `com.onceagain.drinksomewater.subscription.yearly` | Auto-renewable subscription | ₩9,900 | In `premium` subscription group; 7-day free trial |
| Unlimited Lifetime | `com.onceagain.drinksomewater.premium.lifetime` | Non-consumable | ₩49,000 | One-time purchase; unlocks same premium features |

## App Store Connect Checks

- [ ] Paid Applications Agreement, tax, and banking are complete.
- [ ] Monthly/yearly products are in the same `premium` subscription group.
- [ ] Product IDs exactly match the app and `DrinkSomeWater.storekit`.
- [ ] Korean storefront base prices are ₩990 / ₩9,900 / ₩49,000.
- [ ] All intended countries/regions have a valid App Store generated price and currency.
- [ ] No runtime copy hardcodes KRW prices for non-Korean storefronts; the app displays StoreKit product prices.
- [ ] Product display names/descriptions are localized at least in Korean and English.
- [ ] Paywall includes subscription renewal/cancellation disclosure, restore access, Terms of Use, and Privacy Policy links.
- [ ] Monthly/yearly introductory offers are 7-day free trials for new subscribers.
- [ ] Lifetime product family sharing setting matches the release decision.
- [ ] Products are linked to the submitted app version and are Ready to Submit / Waiting for Review / Ready for Sale.

## App Verification

- [ ] Local StoreKit test paywall shows three distinct cards: monthly, yearly, unlimited lifetime.
- [ ] Korean local StoreKit test shows ₩990 / ₩9,900 / ₩49,000.
- [ ] A non-Korean storefront/sandbox test shows local currency and formatting from StoreKit.
- [ ] Purchase each plan in local StoreKit testing and confirm premium access refreshes.
- [ ] Restore purchases and confirm app/widget/watch entitlement access remains consistent.

## Implementation Rule

Runtime paywall prices must come from StoreKit `Product.displayPrice`. Treat App Store Connect as the source of truth for real country-specific prices; this repo can only verify local StoreKit configuration unless an App Store Connect export or read-only access is provided.

The paywall must only render purchasable product cards when all three configured products are loaded. If any required product is missing, show the retry/error state instead of silently showing a partial product list.
