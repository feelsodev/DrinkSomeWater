# App Store Connect Setup Guide - Premium Subscriptions

> 벌컥벌컥 (Gulp) 앱의 프리미엄 구독 기능을 App Store Connect에 설정하는 가이드

## Overview

이 가이드는 벌컥벌컥 앱에 다음 3가지 프리미엄 상품을 App Store Connect에 설정하는 방법을 다룹니다:

- **월간 구독** (₩2,900/월, 7일 무료 체험)
- **연간 구독** (₩19,000/년, 7일 무료 체험)
- **평생 이용권** (₩49,000, 일회성 구매)

## Prerequisites

### 1. App Store Connect 접근 권한
- Apple Developer Program 멤버십 활성화
- App Store Connect에서 "Admin" 또는 "App Manager" 역할

### 2. 필수 계약 동의
1. App Store Connect → **Agreements, Tax, and Banking** 이동
2. **Paid Applications Agreement** 동의 (아직 안 했다면)
3. 세금 정보 입력 완료
4. 은행 계좌 정보 입력 완료

⚠️ **중요**: 구독 상품을 생성하려면 위 계약이 모두 완료되어야 합니다.

### 3. 앱 정보
- **App Name**: 벌컥벌컥 (Gulp)
- **Bundle ID**: `com.onceagain.drinksomewater`
- **Platform**: iOS 18+
- **Status**: 이미 App Store에 출시된 앱 (업데이트)

---

## Step 1: Subscription Group 생성

### 1.1 Subscription Group 만들기

1. App Store Connect → **My Apps** → **벌컥벌컥** 선택
2. 왼쪽 메뉴에서 **Subscriptions** 클릭
3. **Create Subscription Group** 버튼 클릭
4. 다음 정보 입력:
   - **Reference Name**: `premium`
   - **App Name**: `벌컥벌컥` (자동 입력됨)

### 1.2 Subscription Group 로컬라이제이션

**Korean (ko)**:
- **Subscription Group Display Name**: `프리미엄 구독`
- **Custom App Name** (선택): 비워두기
- **Description**: `프리미엄 구독으로 광고 없이 모든 기능을 이용하세요`

**English (en_US)**:
- **Subscription Group Display Name**: `Premium Subscription`
- **Custom App Name** (선택): 비워두기
- **Description**: `Access all premium features without ads`

5. **Save** 클릭

---

## Step 2: 월간 구독 상품 생성

### 2.1 기본 정보

1. 방금 생성한 `premium` Subscription Group 선택
2. **Create Subscription** 버튼 클릭
3. 다음 정보 입력:

| Field | Value |
|-------|-------|
| **Reference Name** | `Premium Monthly` |
| **Product ID** | `com.onceagain.drinksomewater.premium.monthly` |
| **Subscription Duration** | `1 Month` |

⚠️ **중요**: Product ID는 정확히 입력해야 합니다. 코드에서 이 ID를 사용합니다.

### 2.2 Subscription Pricing

1. **Subscription Prices** 섹션에서 **Add Subscription Price** 클릭
2. 다음 정보 입력:
   - **Price**: `₩2,900` (또는 Tier 선택)
   - **Start Date**: 즉시 시작
   - **End Date**: 없음 (계속 유지)

### 2.3 Free Trial (7일 무료 체험)

1. **Introductory Offers** 섹션에서 **Create Introductory Offer** 클릭
2. 다음 정보 입력:
   - **Offer Type**: `Free Trial`
   - **Duration**: `7 Days`
   - **Eligibility**: `New Subscribers`
   - **Start Date**: 즉시 시작

### 2.4 로컬라이제이션

**Korean (ko)**:
- **Subscription Display Name**: `월간 구독`
- **Description**: `월간 프리미엄 구독 (7일 무료 체험)`

**English (en_US)**:
- **Subscription Display Name**: `Monthly`
- **Description**: `Monthly Premium Subscription (7-day free trial)`

### 2.5 App Store Information

- **App Store Promotion** (선택): 활성화하면 App Store에서 구독 프로모션 가능
- **Promotional Image** (선택): 1600x1200px 이미지 업로드

3. **Save** 클릭

---

## Step 3: 연간 구독 상품 생성

### 3.1 기본 정보

1. `premium` Subscription Group에서 **Create Subscription** 클릭
2. 다음 정보 입력:

| Field | Value |
|-------|-------|
| **Reference Name** | `Premium Yearly` |
| **Product ID** | `com.onceagain.drinksomewater.premium.yearly` |
| **Subscription Duration** | `1 Year` |

### 3.2 Subscription Pricing

1. **Subscription Prices** 섹션에서 **Add Subscription Price** 클릭
2. 다음 정보 입력:
   - **Price**: `₩19,000`
   - **Start Date**: 즉시 시작
   - **End Date**: 없음

💡 **Tip**: 연간 구독은 월간 대비 45% 할인 (₩34,800 → ₩19,000)

### 3.3 Free Trial (7일 무료 체험)

1. **Introductory Offers** 섹션에서 **Create Introductory Offer** 클릭
2. 다음 정보 입력:
   - **Offer Type**: `Free Trial`
   - **Duration**: `7 Days`
   - **Eligibility**: `New Subscribers`
   - **Start Date**: 즉시 시작

### 3.4 로컬라이제이션

**Korean (ko)**:
- **Subscription Display Name**: `연간 구독`
- **Description**: `연간 프리미엄 구독 (7일 무료 체험, 45% 할인)`

**English (en_US)**:
- **Subscription Display Name**: `Yearly`
- **Description**: `Yearly Premium Subscription (7-day free trial, 45% off)`

3. **Save** 클릭

---

## Step 4: 평생 이용권 (Non-Consumable) 생성

### 4.1 In-App Purchases 섹션으로 이동

1. App Store Connect → **My Apps** → **벌컥벌컥** 선택
2. 왼쪽 메뉴에서 **In-App Purchases** 클릭
3. **Create** 버튼 클릭
4. **Non-Consumable** 선택

### 4.2 기본 정보

| Field | Value |
|-------|-------|
| **Reference Name** | `Premium Lifetime` |
| **Product ID** | `com.onceagain.drinksomewater.premium.lifetime` |

⚠️ **중요**: Product ID는 정확히 입력해야 합니다.

### 4.3 Pricing

1. **Price** 섹션에서 **Add Pricing** 클릭
2. 다음 정보 입력:
   - **Price**: `₩49,000`
   - **Availability**: 모든 지역

### 4.4 로컬라이제이션

**Korean (ko)**:
- **Display Name**: `평생 이용권`
- **Description**: `평생 프리미엄 이용권`

**English (en_US)**:
- **Display Name**: `Lifetime`
- **Description**: `Lifetime Premium Access`

### 4.5 Family Sharing

- **Family Sharing**: ✅ **Enabled** (가족 공유 허용)

💡 **Tip**: Non-Consumable 상품은 가족 공유를 활성화하는 것이 좋습니다.

### 4.6 Review Information

- **Screenshot**: 평생 이용권 구매 화면 스크린샷 업로드
- **Review Notes**: "평생 프리미엄 이용권으로 광고가 제거됩니다"

3. **Save** 클릭

---

## Step 5: 상품 심사 제출

### 5.1 상품 상태 확인

모든 상품이 다음 상태여야 합니다:
- ✅ **Ready to Submit** 또는 **Waiting for Review**

### 5.2 앱 버전에 상품 연결

1. **App Store** → **iOS App** → 최신 버전 선택
2. **In-App Purchases and Subscriptions** 섹션에서 **Add** 클릭
3. 생성한 3개 상품 모두 선택:
   - Premium Monthly
   - Premium Yearly
   - Premium Lifetime
4. **Done** 클릭

### 5.3 앱 버전 제출

1. 앱 버전의 모든 필수 정보 입력 완료
2. **Submit for Review** 클릭

⚠️ **중요**: 상품은 앱 버전과 함께 심사됩니다. 앱이 승인되면 상품도 함께 승인됩니다.

---

## Step 6: Testing (테스트)

### 6.1 Sandbox Testing (로컬 테스트)

#### Xcode StoreKit Configuration File
- 이미 `ios/DrinkSomeWater/DrinkSomeWater.storekit` 파일이 생성되어 있습니다
- Xcode Scheme에 연결되어 있어 시뮬레이터에서 바로 테스트 가능

#### 테스트 방법
1. Xcode에서 앱 실행 (시뮬레이터 또는 실제 기기)
2. 설정 화면 → "프리미엄 업그레이드" 탭
3. 구독 상품 선택 → 구매 진행
4. StoreKit 테스트 다이얼로그에서 "Subscribe" 클릭
5. 프리미엄 상태 확인 (광고 제거 확인)

#### 구매 복원 테스트
1. 앱 삭제 후 재설치
2. 설정 화면 → "구매 복원" 버튼 탭
3. 프리미엄 상태 복원 확인

### 6.2 Sandbox Account Testing (실제 서버 테스트)

#### Sandbox Account 생성
1. App Store Connect → **Users and Access** → **Sandbox Testers**
2. **Add Tester** 클릭
3. 테스트용 Apple ID 생성 (예: `test@example.com`)

#### 테스트 방법
1. 실제 기기에서 **Settings** → **App Store** → **Sandbox Account** 로그인
2. 앱 실행 후 구독 구매 진행
3. Sandbox 계정으로 구매 (실제 결제 안 됨)
4. 구독 상태 확인

💡 **Tip**: Sandbox 환경에서는 구독 기간이 가속됩니다:
- 1개월 구독 → 5분
- 1년 구독 → 1시간
- 7일 무료 체험 → 3분

### 6.3 TestFlight Testing

#### TestFlight 빌드 업로드
1. Xcode에서 **Product** → **Archive**
2. **Distribute App** → **App Store Connect**
3. TestFlight에 빌드 업로드

#### 테스터 초대
1. App Store Connect → **TestFlight** → **Internal Testing** 또는 **External Testing**
2. 테스터 이메일 추가
3. 테스터가 TestFlight 앱에서 앱 설치

#### 테스트 방법
- TestFlight 빌드는 **실제 App Store Connect 상품**을 사용합니다
- Sandbox 계정으로 로그인하여 테스트
- 구매, 복원, 구독 갱신 모두 테스트

---

## Step 7: Production Submission Checklist

### 7.1 상품 설정 확인

- [ ] 3개 상품 모두 생성 완료 (월간, 연간, 평생)
- [ ] Product ID가 코드와 정확히 일치
- [ ] 가격 설정 완료 (₩2,900, ₩19,000, ₩49,000)
- [ ] 무료 체험 설정 완료 (월간/연간 7일)
- [ ] 로컬라이제이션 완료 (Korean + English)
- [ ] Family Sharing 설정 (평생 이용권만 활성화)

### 7.2 앱 코드 확인

- [ ] StoreKit 2 구현 완료
- [ ] Product ID가 코드에 정확히 입력됨
- [ ] 구매 플로우 테스트 완료
- [ ] 구매 복원 기능 테스트 완료
- [ ] 프리미엄 상태 지속성 확인 (앱 재시작 시)
- [ ] 광고 제거 로직 동작 확인

### 7.3 테스트 완료

- [ ] Xcode StoreKit Configuration File 테스트 완료
- [ ] Sandbox Account 테스트 완료
- [ ] TestFlight 테스트 완료
- [ ] 구독 갱신 테스트 완료
- [ ] 구독 취소 테스트 완료

### 7.4 App Store 제출

- [ ] 앱 버전에 상품 연결 완료
- [ ] 스크린샷 업데이트 (프리미엄 기능 포함)
- [ ] 앱 설명 업데이트 (구독 정보 포함)
- [ ] Privacy Policy 업데이트 (구독 정보 포함)
- [ ] Review Notes 작성 (심사자용 테스트 계정 제공)

### 7.5 심사 후

- [ ] 앱 승인 확인
- [ ] 상품 승인 확인 (App Store Connect에서 "Ready for Sale" 상태)
- [ ] 실제 구매 테스트 (실제 Apple ID로)
- [ ] Analytics 이벤트 확인 (Firebase)

---

## Troubleshooting

### 문제 1: "Subscription Group을 생성할 수 없습니다"

**원인**: Paid Applications Agreement가 완료되지 않음

**해결**:
1. App Store Connect → **Agreements, Tax, and Banking**
2. Paid Applications Agreement 동의
3. 세금 정보 및 은행 계좌 정보 입력

### 문제 2: "Product ID가 이미 사용 중입니다"

**원인**: 다른 앱에서 동일한 Product ID 사용 중

**해결**:
- Product ID는 Bundle ID를 prefix로 사용해야 합니다
- 예: `com.onceagain.drinksomewater.premium.monthly`
- 다른 앱의 Bundle ID와 겹치지 않도록 확인

### 문제 3: "상품을 로드할 수 없습니다" (코드에서)

**원인**: Product ID 불일치 또는 상품이 아직 승인되지 않음

**해결**:
1. App Store Connect에서 Product ID 확인
2. 코드의 Product ID와 정확히 일치하는지 확인
3. 상품 상태가 "Ready for Sale" 또는 "Waiting for Review"인지 확인
4. Sandbox 계정으로 로그인했는지 확인

### 문제 4: "구매가 완료되지 않습니다"

**원인**: Transaction 검증 실패 또는 네트워크 문제

**해결**:
1. 네트워크 연결 확인
2. Sandbox 계정 로그인 확인
3. Xcode Console에서 에러 로그 확인
4. `Transaction.updates` 리스너가 동작하는지 확인

### 문제 5: "구독 갱신이 안 됩니다"

**원인**: Sandbox 환경에서는 구독이 자동으로 갱신되지만 제한이 있음

**해결**:
- Sandbox에서는 최대 6회까지만 자동 갱신됨
- 실제 프로덕션에서는 무제한 갱신
- TestFlight에서 실제 갱신 동작 테스트

### 문제 6: "Family Sharing이 동작하지 않습니다"

**원인**: Non-Consumable 상품만 Family Sharing 지원

**해결**:
- 구독 상품 (월간/연간)은 Family Sharing 불가
- 평생 이용권만 Family Sharing 활성화
- App Store Connect에서 설정 확인

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
   - Firebase Analytics에서 구매 이벤트 확인
   - 전환율 모니터링 (페이월 표시 → 구매)
   - 구독 갱신율 확인

2. **Optimize Pricing**
   - A/B 테스트 고려 (가격, 무료 체험 기간)
   - 지역별 가격 최적화

3. **Marketing**
   - App Store 구독 프로모션 활성화
   - 프로모션 코드 생성 (마케팅 캠페인용)
   - 소셜 미디어 홍보

4. **Future Enhancements**
   - 프로모션 오퍼 추가 (재구독 유도)
   - 윈백 오퍼 (Winback Offer)
   - 가격 인상 전략

---

**Last Updated**: 2026-01-27  
**Version**: 1.0  
**Author**: DrinkSomeWater Team
