# 벌컥벌컥 (Gulp)
> 💧 간편한 물 섭취 기록 iOS & watchOS 앱

<img src="https://user-images.githubusercontent.com/59601439/115199996-bd370800-a12e-11eb-8f70-bc1ab0a0c97d.PNG">

<p align=center>
<a href="https://apps.apple.com/kr/app/%EB%B2%8C%EC%BB%A5%EB%B2%8C%EC%BB%A5/id1563673158">
<img src="https://user-images.githubusercontent.com/59601439/120217924-fefdb700-c273-11eb-9425-63860bf2c9a3.png">
</a>
</p>

<p align="center">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6-orange.svg">
  <img alt="iOS" src="https://img.shields.io/badge/iOS-26%2B-yellow">
  <img alt="watchOS" src="https://img.shields.io/badge/watchOS-11%2B-red">
  <img alt="Architecture" src="https://img.shields.io/badge/Architecture-Observable%20Store-blue">
</p>

## 📱 주요 기능

### 💧 오늘 탭
퀵버튼으로 간편하게 물 섭취량을 기록합니다.
- 기본 퀵버튼: 100ml, 200ml, 300ml, 500ml
- 커스텀 퀵버튼: 자주 마시는 용량 설정 가능
- 물 추가/빼기 모드: 잘못 기록한 양 쉽게 수정
- 오늘 기록 초기화: 하루 기록 리셋 가능
- 목표량 퀵설정: 🎯 버튼으로 빠르게 조절
- 물결 애니메이션으로 진행도 시각화
- 남은 양/컵 수 실시간 표시

### 📅 기록 탭
3가지 뷰 모드로 달성 이력을 확인합니다.
- **캘린더 모드**: FSCalendar로 월별 달성 현황
- **리스트 모드**: 최신순 물 섭취 기록
- **타임라인 모드**: 월별 그룹화된 타임라인
- 달성일 하이라이트 표시
- 이번 달 달성 통계 배지

### ⚙️ 설정 탭
앱을 나만의 스타일로 커스터마이즈합니다.
- 일일 목표량 설정 (1,500ml ~ 4,500ml)
- 퀵버튼 커스텀 (2개 버튼 설정)
- 알림 설정
- 문의 및 리뷰



### 💬 스마트 알림
다양한 동기부여 문구로 알림을 보냅니다.
- 10가지 랜덤 문구로 지루하지 않은 알림
- "물 마실 시간이에요! 💧"
- "집중력 UP! 물 한 잔 어때요? 🧠"
- 그 외 8가지 문구...

### 🍎 Apple Health 연동
건강 앱과 데이터를 동기화합니다.
- 체중 정보 연동 → 맞춤 권장량 자동 계산
- 물 섭취 기록 건강 앱에 자동 저장
- 다른 건강 앱과 데이터 통합

### 📱 홈 화면 위젯
홈 화면에서 바로 물 섭취량을 확인하고 기록합니다.
- **Small 위젯**: 원형 진행도 차트 + 백분율 + 섭취량
- **Medium 위젯**: 진행도 + 빠른 추가 버튼 (150ml, 300ml)
- **Large 위젯**: 큰 진행도 + 동기부여 메시지 + 3개 버튼 (150ml, 300ml, 500ml)
- **잠금화면 위젯**: Circular/Rectangular/Inline 형태 모두 지원
- 인터랙티브 버튼으로 위젯에서 직접 물 추가 가능 (AppIntent)

### 🎯 온보딩
최초 실행 시 앱 사용법을 안내합니다.
- 5페이지 스와이프 방식
- 목표량 설정 (슬라이더)
- HealthKit 연동 안내
- 알림 설정
- 위젯 설정 가이드

### ⌚ Apple Watch 앱
손목에서 바로 물 섭취량을 기록합니다.
- **홈 화면**: 오늘 섭취량과 목표 대비 진행률 표시
- **퀵 추가**: 150ml, 250ml, 300ml, 500ml 빠른 추가 버튼
- **직접 입력**: 50ml 단위로 세밀하게 조절
- **실시간 동기화**: iPhone과 Watch Connectivity로 자동 동기화
- **컴플리케이션**: 시계 페이스에서 바로 확인
  - Circular: 진행률 게이지
  - Rectangular: 섭취량/목표량 상세 표시
  - Corner: 아이콘과 퍼센트
  - Inline: 텍스트 형태

## 🏗 앱 구조

```
┌─────────────────────────────────────────────────────────────┐
│                         iOS App                             │
│   Intro (스플래시)                                          │
│         │                                                   │
│         ▼                                                   │
│   ┌─────────────┬─────────────┬─────────────┐               │
│   │     💧      │     📅      │     ⚙️      │               │
│   │    오늘     │    기록     │    설정     │               │
│   └─────────────┴─────────────┴─────────────┘               │
│                         │                                   │
│                  WatchConnectivity                          │
│                         │                                   │
├─────────────────────────┼───────────────────────────────────┤
│                    watchOS App                              │
│   ┌─────────────────────┴─────────────────────┐             │
│   │              ⌚ Watch App                  │             │
│   │   ┌─────────────┬─────────────────────┐   │             │
│   │   │    홈      │     퀵 추가          │   │             │
│   │   │  진행률    │  150/250/300/500ml   │   │             │
│   │   └─────────────┴─────────────────────┘   │             │
│   └───────────────────────────────────────────┘             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🛠 기술 스택

| Category | Technology |
|----------|------------|
| iOS UI | SwiftUI + UIKit (Settings) |
| watchOS UI | SwiftUI |
| Widget | SwiftUI + WidgetKit + AppIntent |
| Architecture | @Observable Store Pattern |
| Concurrency | async/await, Swift 6 |
| Sync | WatchConnectivity |
| Animation | WaveAnimationView |
| Calendar | FSCalendar |
| Health | HealthKit |
| Ads | Google AdMob (Native, Rewarded) |
| Analytics | Firebase Analytics |
| Design System | DesignTokens (DS) |
| Build | Tuist |

## 📦 의존성

```swift
// Tuist SPM
- SnapKit (5.7.0+)
- FSCalendar (2.8.4+)
- Google Mobile Ads (11.2.0+)

// Internal Modules
- Analytics

// System Frameworks
- HealthKit
- WidgetKit
- WatchConnectivity
- WatchKit
```

## 🚀 빌드 방법

```bash
# Tuist 설치 (mise 사용)
mise install tuist

# 의존성 설치
tuist install

# 프로젝트 생성
tuist generate

# 빌드
tuist build

# 테스트
tuist test

# Xcode 열기
open DrinkSomeWater.xcworkspace
```

## 🧪 테스트

### 테스트 실행
```bash
tuist test
```

### 테스트 커버리지

| 모듈 | 테스트 파일 | 테스트 케이스 |
|------|------------|--------------|
| HomeStore | HomeStoreTests.swift | 12개 |
| WaterService | WaterServiceTests.swift | 13개 |
| HistoryStore | HistoryStoreTests.swift | 8개 |
| ProfileStore | ProfileStoreTests.swift | 12개 |
| NotificationStore | NotificationStoreTests.swift | 10개 |
| Models | DrinkSomeWaterTests.swift | 11개 |

총 **53개 이상**의 테스트 케이스로 핵심 비즈니스 로직을 검증합니다.

### 테스트 구조

```
DrinkSomeWaterTests/
├── Mocks/
│   └── MockServices.swift      # 테스트용 Mock 서비스
├── HomeStoreTests.swift        # 홈 화면 Store 테스트
├── WaterServiceTests.swift     # 물 섭취 서비스 테스트
├── HistoryStoreTests.swift     # 기록 화면 Store 테스트
├── ProfileStoreTests.swift     # 프로필 Store 테스트
└── DrinkSomeWaterTests.swift   # 모델 및 기타 테스트
```

## ♿ 접근성

VoiceOver를 지원하여 시각 장애인도 앱을 사용할 수 있습니다.

- **홈 화면**: 현재 섭취량, 목표량, 퀵버튼에 접근성 레이블 제공
- **기록 화면**: 월간 달성 통계, 기록 리스트에 접근성 지원
- **다국어 지원**: 한국어/영어 접근성 레이블 완비

## 📝 아키텍처

### @Observable Store Pattern

ReactorKit에서 영감을 받은 단방향 데이터 흐름:

```swift
@MainActor
@Observable
final class HomeStore {
    enum Action {
        case refresh
        case refreshGoal
        case refreshQuickButtons
        case addWater(Int)
        case subtractWater(Int)
        case resetTodayWater
        case checkNotificationPermission
        case dismissNotificationBanner
    }

    var total: Float = 0
    var ml: Float = 0
    var progress: Float { total == 0 ? 0 : ml / total }
    var remainingMl: Int { max(0, Int(total - ml)) }
    var quickButtons: [Int] = [100, 200, 300, 500]

    func send(_ action: Action) async {
        switch action {
        case .refresh:
            // 오늘 섭취량 로드
        case .addWater(let amount):
            // 물 추가
        case .subtractWater(let amount):
            // 물 빼기
        // ...
        }
    }
}
```

SwiftUI View에서 자동 UI 업데이트:

```swift
struct HomeView: View {
    @Bindable var store: HomeStore

    var body: some View {
        VStack {
            Text("\(Int(store.ml))ml")
            // store 프로퍼티 변경 시 자동 리렌더링
        }
        .task {
            await store.send(.refresh)
        }
    }
}
```

## 🏃 개발 목적

- 하루 물 섭취량을 간편하게 기록하고 싶었습니다
- Swift 최신 기능(Observation, async/await)을 실제 앱에 적용해보고 싶었습니다
- 깔끔한 3탭 구조로 직관적인 UX를 구현하고 싶었습니다

## 📄 License

MIT License - [LICENSE](https://github.com/feelsodev/DrinkSomeWater/blob/master/LICENSE)
