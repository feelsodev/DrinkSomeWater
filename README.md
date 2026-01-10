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
- 직접 입력: 슬라이더로 정확한 양 입력
- 목표량 퀵설정: 🎯 버튼으로 빠르게 조절
- 물결 애니메이션으로 진행도 시각화

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
- **Small 위젯**: 원형 진행도 차트 + 백분율
- **Medium 위젯**: 진행도 + 빠른 추가 버튼 (150ml, 300ml)
- **Large 위젯**: 큰 진행도 + 동기부여 메시지 + 3개 버튼
- **잠금화면 위젯**: Circular/Rectangular/Inline 형태 지원
- 인터랙티브 버튼으로 위젯에서 직접 물 추가 가능

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
| iOS UI | UIKit + SnapKit |
| watchOS UI | SwiftUI |
| Widget | SwiftUI + WidgetKit |
| Architecture | @Observable Store Pattern |
| Concurrency | async/await, Swift 6 |
| Sync | WatchConnectivity |
| Animation | WaveAnimationView |
| Calendar | FSCalendar |
| Health | HealthKit |
| Ads | Google AdMob |
| Build | Tuist |

## 📦 의존성

```swift
// Tuist SPM
- SnapKit
- FSCalendar
- Google Mobile Ads

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

## 📝 아키텍처

### @Observable Store Pattern

ReactorKit에서 영감을 받은 단방향 데이터 흐름:

```swift
@MainActor
@Observable
final class HomeStore {
    enum Action {
        case refresh
        case addWater(Int)
    }
    
    var ml: Float = 0
    
    func send(_ action: Action) async {
        switch action {
        case .refresh:
            // 데이터 로드
        case .addWater(let amount):
            // 물 추가
        }
    }
}
```

ViewController에서 자동 UI 업데이트:

```swift
observation = startObservation { [weak self] in 
    self?.render() 
}
```

## 🏃 개발 목적

- 하루 물 섭취량을 간편하게 기록하고 싶었습니다
- Swift 최신 기능(Observation, async/await)을 실제 앱에 적용해보고 싶었습니다
- 깔끔한 3탭 구조로 직관적인 UX를 구현하고 싶었습니다

## 📄 License

MIT License - [LICENSE](https://github.com/feelsodev/DrinkSomeWater/blob/master/LICENSE)
