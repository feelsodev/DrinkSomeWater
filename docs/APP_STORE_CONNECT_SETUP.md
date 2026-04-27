# App Store Connect Setup Guide - Premium Subscriptions

> A guide for setting up premium subscription products in App Store Connect for the 벌컥벌컥 (Gulp) app

## Overview

This guide covers how to set up the following 3 premium products in App Store Connect for the 벌컥벌컥 app:

- **Monthly Subscription** (₩990/month, 7-day free trial)
- **Annual Subscription** (₩9,900/year, 7-day free trial)
- **Lifetime Access** (₩49,000, one-time purchase)

## Prerequisites

### 1. App Store Connect Access
- Active Apple Developer Program membership
- "Admin" or "App Manager" role in App Store Connect

### 2. Required Agreements
1. Go to App Store Connect → **Agreements, Tax, and Banking**
2. Accept the **Paid Applications Agreement** (if not already done)
3. Complete tax information
4. Complete bank account information

⚠️ **Important**: All agreements above must be completed before you can create subscription products.

### 3. App Information
- **App Name**: 벌컥벌컥 (Gulp)
- **Bundle ID**: `com.onceagain.drinksomewater`
- **Platform**: iOS 18+
- **Status**: App already published on the App Store (update)

---

## Step 1: Create a Subscription Group

### 1.1 Create the Subscription Group

1. App Store Connect → **My Apps** → select **벌컥벌컥**
2. Click **Subscriptions** in the left menu
3. Click **Create Subscription Group**
4. Enter the following:
   - **Reference Name**: `premium`
   - **App Name**: `벌컥벌컥` (auto-filled)

### 1.2 Subscription Group Localization

**Korean (ko)**:
- **Subscription Group Display Name**: `프리미엄 구독`
- **Custom App Name** (optional): leave blank
- **Description**: `프리미엄 구독으로 광고 없이 모든 기능을 이용하세요`

**English (en_US)**:
- **Subscription Group Display Name**: `Premium Subscription`
- **Custom App Name** (optional): leave blank
- **Description**: `Access all premium features without ads`

5. Click **Save**

---

## Step 2: Create the Monthly Subscription Product

### 2.1 Basic Information

1. Select the `premium` Subscription Group you just created
2. Click **Create Subscription**
3. Enter the following:

| Field | Value |
|-------|-------|
| **Reference Name** | `Subscription Monthly` |
| **Product ID** | `com.onceagain.drinksomewater.subscription.monthly` |
| **Subscription Duration** | `1 Month` |

⚠️ **Important**: The Product ID must be entered exactly. This ID is used in the code.

### 2.2 Subscription Pricing

1. In the **Subscription Prices** section, click **Add Subscription Price**
2. Enter the following:
   - **Price**: `₩990` (or select the appropriate tier)
   - **Start Date**: immediate
   - **End Date**: none (ongoing)

### 2.3 Free Trial (7-day free trial)

1. In the **Introductory Offers** section, click **Create Introductory Offer**
2. Enter the following:
   - **Offer Type**: `Free Trial`
   - **Duration**: `7 Days`
   - **Eligibility**: `New Subscribers`
   - **Start Date**: immediate

### 2.4 Localization

**Korean (ko)**:
- **Subscription Display Name**: `월간 구독`
- **Description**: `월간 프리미엄 구독 (7일 무료 체험)`

**English (en_US)**:
- **Subscription Display Name**: `Monthly`
- **Description**: `Monthly Premium Subscription (7-day free trial)`

### 2.5 App Store Information

- **App Store Promotion** (optional): enable to allow subscription promotion on the App Store
- **Promotional Image** (optional): upload a 1600x1200px image

3. Click **Save**

---

## Step 3: Create the Annual Subscription Product

### 3.1 Basic Information

1. Click **Create Subscription** in the `premium` Subscription Group
2. Enter the following:

| Field | Value |
|-------|-------|
| **Reference Name** | `Subscription Yearly` |
| **Product ID** | `com.onceagain.drinksomewater.subscription.yearly` |
| **Subscription Duration** | `1 Year` |

### 3.2 Subscription Pricing

1. In the **Subscription Prices** section, click **Add Subscription Price**
2. Enter the following:
   - **Price**: `₩9,900`
   - **Start Date**: immediate
   - **End Date**: none

💡 **Tip**: The annual subscription is about 17% cheaper than paying monthly for 12 months (₩11,880 → ₩9,900)

### 3.3 Free Trial (7-day free trial)

1. In the **Introductory Offers** section, click **Create Introductory Offer**
2. Enter the following:
   - **Offer Type**: `Free Trial`
   - **Duration**: `7 Days`
   - **Eligibility**: `New Subscribers`
   - **Start Date**: immediate

### 3.4 Localization

**Korean (ko)**:
- **Subscription Display Name**: `연간 구독`
- **Description**: `연간 프리미엄 구독 (7일 무료 체험, 월 결제 대비 약 17% 절약)`

**English (en_US)**:
- **Subscription Display Name**: `Yearly`
- **Description**: `Yearly Premium Subscription (7-day free trial, about 17% savings vs monthly)`

3. Click **Save**

---

## Step 4: Create the Lifetime Access (Non-Consumable) Product

### 4.1 Navigate to In-App Purchases

1. App Store Connect → **My Apps** → select **벌컥벌컥**
2. Click **In-App Purchases** in the left menu
3. Click **Create**
4. Select **Non-Consumable**

### 4.2 Basic Information

| Field | Value |
|-------|-------|
| **Reference Name** | `Premium Lifetime` |
| **Product ID** | `com.onceagain.drinksomewater.premium.lifetime` |

⚠️ **Important**: The Product ID must be entered exactly.

### 4.3 Pricing

1. In the **Price** section, click **Add Pricing**
2. Enter the following:
   - **Price**: `₩49,000`
   - **Availability**: all regions

### 4.4 Localization

**Korean (ko)**:
- **Display Name**: `평생 이용권`
- **Description**: `평생 프리미엄 이용권`

**English (en_US)**:
- **Display Name**: `Lifetime`
- **Description**: `Lifetime Premium Access`

### 4.5 Family Sharing

- **Family Sharing**: ✅ **Enabled** (allow family sharing)

💡 **Tip**: It's recommended to enable Family Sharing for Non-Consumable products.

### 4.6 Review Information

- **Screenshot**: upload a screenshot of the lifetime access purchase screen
- **Review Notes**: "Lifetime premium access removes all ads"

3. Click **Save**

---

## Step 5: Submit Products for Review

### 5.1 Check Product Status

All products must be in one of these states:
- ✅ **Ready to Submit** or **Waiting for Review**

### 5.2 Link Products to the App Version

1. **App Store** → **iOS App** → select the latest version
2. In the **In-App Purchases and Subscriptions** section, click **Add**
3. Select all 3 products:
   - Subscription Monthly
   - Subscription Yearly
   - Premium Lifetime
4. Click **Done**

### 5.3 Submit the App Version

1. Complete all required fields for the app version
2. Click **Submit for Review**

⚠️ **Important**: Products are reviewed alongside the app version. When the app is approved, the products are approved too.

---

## Step 6: Testing

### 6.1 Sandbox Testing (Local Testing)

#### Xcode StoreKit Configuration File
- The `ios/DrinkSomeWater/DrinkSomeWater.storekit` file is already created
- It's linked to the Xcode Scheme, so you can test directly in the simulator

#### How to Test
1. Run the app in Xcode (simulator or real device)
2. Settings screen → "Premium Upgrade" tab
3. Select a subscription product → proceed with purchase
4. Click "Subscribe" in the StoreKit test dialog
5. Verify premium status (confirm ads are removed)

#### Purchase Restore Testing
1. Delete and reinstall the app
2. Settings screen → tap "Restore Purchases"
3. Confirm premium status is restored

### 6.2 Sandbox Account Testing (Live Server Testing)

#### Create a Sandbox Account
1. App Store Connect → **Users and Access** → **Sandbox Testers**
2. Click **Add Tester**
3. Create a test Apple ID (e.g., `test@example.com`)

#### How to Test
1. On a real device: **Settings** → **App Store** → sign in with **Sandbox Account**
2. Open the app and proceed with a subscription purchase
3. Purchase with the Sandbox account (no real charge)
4. Verify subscription status

💡 **Tip**: Subscription periods are accelerated in the Sandbox environment:
- 1-month subscription → 5 minutes
- 1-year subscription → 1 hour
- 7-day free trial → 3 minutes

### 6.3 TestFlight Testing

#### Upload a TestFlight Build
1. In Xcode: **Product** → **Archive**
2. **Distribute App** → **App Store Connect**
3. Upload the build to TestFlight

#### Invite Testers
1. App Store Connect → **TestFlight** → **Internal Testing** or **External Testing**
2. Add tester email addresses
3. Testers install the app from the TestFlight app

#### How to Test
- TestFlight builds use **actual App Store Connect products**
- Sign in with a Sandbox account to test
- Test purchases, restores, and subscription renewals

---

## Step 7: Production Submission Checklist

### 7.1 Product Configuration

- [ ] All 3 products created (monthly, annual, lifetime)
- [ ] Product IDs match the code exactly
- [ ] Pricing configured (₩990, ₩9,900, ₩49,000)
- [ ] Free trial configured (7 days for monthly/annual)
- [ ] Localization complete (Korean + English)
- [ ] Family Sharing configured (enabled for lifetime only)

### 7.2 App Code

- [ ] StoreKit 2 implementation complete
- [ ] Product IDs entered correctly in code
- [ ] Purchase flow tested
- [ ] Purchase restore tested
- [ ] Premium status persistence confirmed (on app restart)
- [ ] Ad removal logic confirmed working

### 7.3 Testing Complete

- [ ] Xcode StoreKit Configuration File testing done
- [ ] Sandbox Account testing done
- [ ] TestFlight testing done
- [ ] Subscription renewal testing done
- [ ] Subscription cancellation testing done

### 7.4 App Store Submission

- [ ] Products linked to app version
- [ ] Screenshots updated (including premium features)
- [ ] App description updated (including subscription info)
- [ ] Privacy Policy updated (including subscription info)
- [ ] Review Notes written (provide test account for reviewers)

### 7.5 After Review

- [ ] App approval confirmed
- [ ] Product approval confirmed ("Ready for Sale" status in App Store Connect)
- [ ] Real purchase tested (with a real Apple ID)
- [ ] Analytics events confirmed (Firebase)

### 7.6 Country-Specific Price Audit

Before submitting a build, verify country pricing from App Store Connect rather than relying on hardcoded app strings:

- [ ] Monthly subscription (`com.onceagain.drinksomewater.subscription.monthly`) Korean base price is ₩990.
- [ ] Yearly subscription (`com.onceagain.drinksomewater.subscription.yearly`) Korean base price is ₩9,900.
- [ ] Lifetime product (`com.onceagain.drinksomewater.premium.lifetime`) Korean base price is ₩49,000.
- [ ] All products are available in every intended country/region.
- [ ] Each storefront shows an App Store generated local price and currency; do not copy the Korean KRW value into other storefronts manually unless that is the intended local tier.
- [ ] The monthly/yearly products remain in the `premium` subscription group.
- [ ] Monthly and yearly introductory offers are both 7-day free trials for new subscribers.
- [ ] Korean and English product display names/descriptions are present, and any additional localized metadata is reviewed before release.
- [ ] Paywall displays renewal/cancellation disclosure, restore access, Terms of Use, and Privacy Policy links.
- [ ] TestFlight paywall screenshots show three distinct cards: monthly, yearly, and unlimited lifetime.
- [ ] If a storefront price is changed in App Store Connect, capture the effective start date and re-test the paywall with that storefront before release.

---

## Troubleshooting

### Issue 1: "Cannot create Subscription Group"

**Cause**: Paid Applications Agreement not completed

**Fix**:
1. App Store Connect → **Agreements, Tax, and Banking**
2. Accept the Paid Applications Agreement
3. Enter tax information and bank account details

### Issue 2: "Product ID is already in use"

**Cause**: Another app is using the same Product ID

**Fix**:
- Product IDs must use the Bundle ID as a prefix
- Example: `com.onceagain.drinksomewater.subscription.monthly`
- Make sure it doesn't overlap with another app's Bundle ID

### Issue 3: "Cannot load products" (in code)

**Cause**: Product ID mismatch or product not yet approved

**Fix**:
1. Verify the Product ID in App Store Connect
2. Confirm it matches the Product ID in code exactly
3. Confirm the product status is "Ready for Sale" or "Waiting for Review"
4. Confirm you're signed in with a Sandbox account

### Issue 4: "Purchase does not complete"

**Cause**: Transaction validation failure or network issue

**Fix**:
1. Check network connection
2. Confirm Sandbox account is signed in
3. Check error logs in the Xcode Console
4. Confirm the `Transaction.updates` listener is running

### Issue 5: "Subscription does not renew"

**Cause**: The Sandbox environment auto-renews subscriptions but with limits

**Fix**:
- Sandbox auto-renews up to 6 times maximum
- In production, renewals are unlimited
- Test actual renewal behavior in TestFlight

### Issue 6: "Family Sharing doesn't work"

**Cause**: Only Non-Consumable products support Family Sharing

**Fix**:
- Subscription products (monthly/annual) don't support Family Sharing
- Only the lifetime access product has Family Sharing enabled
- Confirm the setting in App Store Connect

---

## References

### Official Apple Documentation

- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [In-App Purchase Documentation](https://developer.apple.com/in-app-purchase/)
- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)
- [Setting Up StoreKit Testing in Xcode](https://developer.apple.com/documentation/xcode/setting-up-storekit-testing-in-xcode)
- [Testing In-App Purchases with Sandbox](https://developer.apple.com/documentation/storekit/in-app_purchase/testing_in-app_purchases_with_sandbox)
- [Subscription Best Practices](https://developer.apple.com/app-store/subscriptions/)

### Useful Resources

- [WWDC 2023: What's new in StoreKit](https://developer.apple.com/videos/play/wwdc2023/10013/)
- [WWDC 2022: Implement proactive in-app purchase restore](https://developer.apple.com/videos/play/wwdc2022/10039/)
- [App Store Review Guidelines - In-App Purchase](https://developer.apple.com/app-store/review/guidelines/#in-app-purchase)

### Support

- [Apple Developer Forums - StoreKit](https://developer.apple.com/forums/tags/storekit)
- [App Store Connect Support](https://developer.apple.com/contact/app-store/)

---

## Next Steps

### After Approval

1. **Monitor Analytics**
   - Check purchase events in Firebase Analytics
   - Monitor conversion rates (paywall shown → purchase)
   - Track subscription renewal rates

2. **Optimize Pricing**
   - Consider A/B testing (price, free trial duration)
   - Optimize pricing by region

3. **Marketing**
   - Enable App Store subscription promotions
   - Generate promo codes (for marketing campaigns)
   - Social media promotion

4. **Future Enhancements**
   - Add promotional offers (to encourage re-subscription)
   - Winback offers
   - Price increase strategy

---

**Last Updated**: 2026-01-27  
**Version**: 1.0  
**Author**: DrinkSomeWater Team
