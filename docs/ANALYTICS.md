# Analytics Events Documentation (iOS)

> Firebase Analytics events and user properties for DrinkSomeWater iOS

## Table of Contents

- [Overview](#overview)
- [Events](#events)
  - [Tier 1: Core Events](#tier-1-core-events)
  - [Tier 2: Onboarding Funnel](#tier-2-onboarding-funnel)
  - [Tier 3: Feature Usage](#tier-3-feature-usage)
  - [Tier 4: HealthKit](#tier-4-healthkit)
  - [Tier 5: Retention](#tier-5-retention)
  - [Tier 6: Monetization](#tier-6-monetization)
- [User Properties](#user-properties)
- [Supporting Types](#supporting-types)
- [Usage Examples](#usage-examples)

---

## Overview

| Item | Value |
|------|-------|
| Provider | Firebase Analytics |
| Total Events | 51 |
| User Properties | 12 |
| Source File | `ios/Analytics/Sources/AnalyticsEvent.swift` |

---

## Events

### Tier 1: Core Events

핵심 사용자 행동 추적

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `water_intake` | 물 섭취 기록 | `amount_ml`, `method`, `hour` |
| `goal_achieved` | 일일 목표 달성 | `goal_ml`, `actual_ml`, `streak_days` |
| `goal_failed` | 일일 목표 미달성 | `goal_ml`, `actual_ml`, `percentage` |
| `app_open` | 앱 실행 | `hour`, `day_of_week`, `days_since_install` |
| `screen_view` | 화면 조회 | `screen_name`, `previous_screen` |

**water_intake**
```
amount_ml: Int       - 섭취량 (ml)
method: String       - quick_button | slider | widget | shortcut
hour: Int            - 기록 시간 (0-23)
```

**goal_achieved**
```
goal_ml: Int         - 목표량 (ml)
actual_ml: Int       - 실제 섭취량 (ml)
streak_days: Int     - 연속 달성 일수
```

**goal_failed**
```
goal_ml: Int         - 목표량 (ml)
actual_ml: Int       - 실제 섭취량 (ml)
percentage: Double   - 달성률 (0.0 ~ 1.0)
```

**app_open**
```
hour: Int            - 실행 시간 (0-23)
day_of_week: Int     - 요일 (1-7)
days_since_install: Int - 설치 후 경과 일수
```

**screen_view**
```
screen_name: String      - 화면 이름
previous_screen: String? - 이전 화면 (optional)
```

---

### Tier 2: Onboarding Funnel

온보딩 퍼널 추적

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `onboarding_started` | 온보딩 시작 | `source` |
| `onboarding_step_viewed` | 단계 조회 | `step` |
| `onboarding_step_completed` | 단계 완료 | `step`, `time_spent_sec` |
| `onboarding_skipped` | 온보딩 스킵 | `step` |
| `onboarding_completed` | 온보딩 완료 | `total_time_sec` |
| `first_water_intake` | 최초 물 기록 | `amount_ml`, `minutes_since_install` |
| `permission_requested` | 권한 요청 | `type` |
| `permission_granted` | 권한 허용 | `type` |
| `permission_denied` | 권한 거부 | `type` |

**onboarding_started**
```
source: String?      - 온보딩 진입 경로 (optional)
```

**onboarding_step_viewed / onboarding_step_completed / onboarding_skipped**
```
step: Int            - 온보딩 단계 번호 (0-based)
time_spent_sec: Int  - 해당 단계 소요 시간 (completed만)
```

**onboarding_completed**
```
total_time_sec: Int  - 전체 온보딩 소요 시간
```

**first_water_intake**
```
amount_ml: Int           - 첫 섭취량 (ml)
minutes_since_install: Int - 설치 후 경과 분
```

**permission_requested / permission_granted / permission_denied**
```
type: String         - notification | healthkit
```

---

### Tier 3: Feature Usage

기능 사용 추적

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `water_subtracted` | 물 섭취 취소 | `amount_ml` |
| `water_reset` | 오늘 기록 초기화 | `previous_amount_ml` |
| `quick_button_tap` | 퀵버튼 탭 | `amount_ml`, `button_index`, `is_custom` |
| `slider_used` | 슬라이더 사용 | `amount_ml` |
| `goal_changed` | 목표량 변경 | `old_goal`, `new_goal`, `source` |
| `goal_quick_set_used` | 목표 퀵설정 사용 | `new_goal` |
| `quick_button_customized` | 퀵버튼 커스텀 | `button_index`, `amount_ml` |
| `calendar_viewed` | 캘린더 조회 | `month`, `year` |
| `calendar_date_selected` | 날짜 선택 | `date`, `had_records`, `was_achieved` |
| `history_record_viewed` | 기록 상세 조회 | `date`, `record_count` |
| `notification_setting_changed` | 알림 설정 변경 | `enabled`, `start_time`, `end_time`, `interval_hours` |
| `widget_added` | 위젯 추가 | `widget_type` |
| `widget_interaction` | 위젯 인터랙션 | `widget_type`, `action`, `amount_ml` |

**water_subtracted**
```
amount_ml: Int       - 취소한 양 (ml)
```

**water_reset**
```
previous_amount_ml: Int - 초기화 전 섭취량 (ml)
```

**quick_button_tap**
```
amount_ml: Int       - 버튼 용량 (ml)
button_index: Int    - 버튼 인덱스 (0-3)
is_custom: Bool      - 커스텀 버튼 여부
```

**goal_changed**
```
old_goal: Int        - 이전 목표량 (ml)
new_goal: Int        - 새 목표량 (ml)
source: String       - settings | onboarding | quick_set | recommendation
```

**calendar_viewed**
```
month: Int           - 월 (1-12)
year: Int            - 연도
```

**calendar_date_selected**
```
date: String         - ISO8601 날짜
had_records: Bool    - 기록 존재 여부
was_achieved: Bool   - 목표 달성 여부
```

**notification_setting_changed**
```
enabled: Bool            - 알림 활성화 여부
start_time: String?      - 시작 시간 (HH:mm)
end_time: String?        - 종료 시간 (HH:mm)
interval_hours: Int?     - 알림 간격 (시간)
```

**widget_added / widget_interaction**
```
widget_type: String  - small | medium | large | lock_screen
action: String       - add_water | open_app (interaction만)
amount_ml: Int?      - 추가한 양 (interaction만, optional)
```

---

### Tier 4: HealthKit

HealthKit 연동 이벤트

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `healthkit_connected` | HealthKit 연결 | - |
| `healthkit_disconnected` | HealthKit 해제 | `reason` |
| `healthkit_sync_success` | 동기화 성공 | `record_count`, `sync_type` |
| `healthkit_sync_failed` | 동기화 실패 | `error_code`, `error_message` |
| `weight_updated` | 체중 업데이트 | `weight_kg`, `source` |
| `recommended_goal_accepted` | 권장량 수락 | `recommended_ml`, `weight_kg` |
| `recommended_goal_rejected` | 권장량 거부 | `recommended_ml`, `custom_ml` |

**healthkit_disconnected**
```
reason: String?      - 해제 사유 (optional)
```

**healthkit_sync_success**
```
record_count: Int    - 동기화된 레코드 수
sync_type: String    - manual | automatic | background
```

**healthkit_sync_failed**
```
error_code: String       - 에러 코드
error_message: String    - 에러 메시지
```

**weight_updated**
```
weight_kg: Double    - 체중 (kg)
source: String       - manual | healthkit
```

**recommended_goal_accepted**
```
recommended_ml: Int  - 권장 목표량 (ml)
weight_kg: Double    - 체중 (kg)
```

**recommended_goal_rejected**
```
recommended_ml: Int  - 권장 목표량 (ml)
custom_ml: Int       - 사용자 설정 목표량 (ml)
```

---

### Tier 5: Retention

리텐션 관련 이벤트

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `streak_achieved` | 연속 달성 | `streak_days` |
| `streak_broken` | 연속 달성 실패 | `previous_streak_days` |
| `notification_received` | 알림 수신 | `notification_id`, `message_type` |
| `notification_tapped` | 알림 탭 | `notification_id`, `time_to_tap_sec` |
| `notification_dismissed` | 알림 무시 | `notification_id` |
| `inactive_return` | 비활성 후 복귀 | `days_inactive` |

**streak_achieved**
```
streak_days: Int     - 연속 달성 일수
```

**streak_broken**
```
previous_streak_days: Int - 이전 연속 달성 일수
```

**notification_received / notification_tapped / notification_dismissed**
```
notification_id: String  - 알림 ID
message_type: String     - 메시지 유형 (received만)
time_to_tap_sec: Int     - 알림 후 탭까지 시간 (tapped만)
```

**inactive_return**
```
days_inactive: Int   - 비활성 기간 (일)
```

---

### Tier 6: Monetization

광고 및 수익화 이벤트

| Event Name | Description | Parameters |
|------------|-------------|------------|
| `ad_impression` | 광고 노출 | `ad_type`, `ad_unit_id`, `screen` |
| `ad_clicked` | 광고 클릭 | `ad_type`, `ad_unit_id` |
| `ad_closed` | 광고 닫기 | `ad_type`, `view_duration_sec` |
| `rewarded_ad_started` | 보상형 광고 시작 | `reward_type` |
| `rewarded_ad_completed` | 보상형 광고 완료 | `reward_type`, `reward_amount` |
| `premium_prompt_shown` | 프리미엄 프롬프트 표시 | `trigger_point`, `variant` |
| `premium_prompt_action` | 프리미엄 프롬프트 액션 | `action` |
| `purchase_started` | 구매 시작 | `product_id`, `price` |
| `purchase_completed` | 구매 완료 | `product_id`, `price`, `currency` |
| `purchase_failed` | 구매 실패 | `product_id`, `error_code` |

**ad_impression / ad_clicked / ad_closed**
```
ad_type: String          - banner | native | rewarded | interstitial
ad_unit_id: String       - 광고 유닛 ID
screen: String           - 노출 화면 (impression만)
view_duration_sec: Int   - 조회 시간 (closed만)
```

**rewarded_ad_started / rewarded_ad_completed**
```
reward_type: String      - 보상 유형
reward_amount: Int       - 보상 수량 (completed만)
```

**premium_prompt_shown**
```
trigger_point: String    - 표시 트리거 지점
variant: String?         - A/B 테스트 변형 (optional)
```

**premium_prompt_action**
```
action: String           - purchase | dismiss | later
```

**purchase_started / purchase_completed / purchase_failed**
```
product_id: String       - 상품 ID
price: Double            - 가격
currency: String         - 통화 코드 (completed만)
error_code: String       - 에러 코드 (failed만)
```

---

## User Properties

| Property | Type | Description |
|----------|------|-------------|
| `daily_goal_ml` | Int | 일일 목표량 (ml) |
| `weight_kg` | Double | 체중 (kg) |
| `notification_enabled` | Bool | 알림 활성화 |
| `healthkit_enabled` | Bool | HealthKit 연동 |
| `onboarding_completed` | Bool | 온보딩 완료 |
| `days_since_install` | Int | 설치 후 경과 일수 |
| `total_intake_count` | Int | 총 기록 횟수 |
| `current_streak` | Int | 현재 연속 달성 |
| `user_segment` | String | light / medium / heavy |
| `premium_status` | String | free / premium |
| `app_version` | String | 앱 버전 |
| `ios_version` | String | iOS 버전 |

---

## Supporting Types

### IntakeMethod
| Value | Description |
|-------|-------------|
| `quick_button` | 퀵버튼 |
| `slider` | 슬라이더 |
| `widget` | 위젯 |
| `shortcut` | Siri 숏컷 |

### GoalChangeSource
| Value | Description |
|-------|-------------|
| `settings` | 설정 화면 |
| `onboarding` | 온보딩 |
| `quick_set` | 퀵설정 |
| `recommendation` | 권장량 기반 |

### WidgetType
| Value | Description |
|-------|-------------|
| `small` | Small 위젯 |
| `medium` | Medium 위젯 |
| `large` | Large 위젯 |
| `lock_screen` | 잠금화면 위젯 |

### WidgetAction
| Value | Description |
|-------|-------------|
| `add_water` | 물 추가 |
| `open_app` | 앱 열기 |

### PermissionType
| Value | Description |
|-------|-------------|
| `notification` | 알림 권한 |
| `healthkit` | HealthKit 권한 |

### SyncType
| Value | Description |
|-------|-------------|
| `manual` | 수동 |
| `automatic` | 자동 |
| `background` | 백그라운드 |

### WeightSource
| Value | Description |
|-------|-------------|
| `manual` | 수동 입력 |
| `healthkit` | HealthKit |

### AdType
| Value | Description |
|-------|-------------|
| `banner` | 배너 |
| `native` | 네이티브 |
| `rewarded` | 보상형 |
| `interstitial` | 전면 |

### PremiumAction
| Value | Description |
|-------|-------------|
| `purchase` | 구매 |
| `dismiss` | 닫기 |
| `later` | 나중에 |

---

## Usage Examples

```swift
import Analytics

// 물 섭취 기록
Analytics.shared.log(.waterIntake(amountMl: 200, method: .quickButton, hour: 14))

// 목표 달성
Analytics.shared.log(.goalAchieved(goalMl: 2000, actualMl: 2100, streakDays: 5))

// 화면 조회
Analytics.shared.logScreenView("home_screen")

// 목표 변경
Analytics.shared.log(.goalChanged(oldGoal: 2000, newGoal: 2500, source: .settings))

// HealthKit 동기화 성공
Analytics.shared.log(.healthKitSyncSuccess(recordCount: 1, syncType: .automatic))

// 사용자 속성 설정
Analytics.shared.setUserProperty(.dailyGoalMl, value: 2000)
Analytics.shared.setUserProperty(.notificationEnabled, value: true)
```

---

*Source: `ios/Analytics/Sources/AnalyticsEvent.swift`*
