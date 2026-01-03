# 벌컥벌컥 (Gulp)
> 💧 간편한 물 섭취 기록 iOS 앱

<img src="https://user-images.githubusercontent.com/59601439/115199996-bd370800-a12e-11eb-8f70-bc1ab0a0c97d.PNG">

<p align=center>
<a href="https://apps.apple.com/kr/app/%EB%B2%8C%EC%BB%A5%EB%B2%8C%EC%BB%A5/id1563673158">
<img src="https://user-images.githubusercontent.com/59601439/120217924-fefdb700-c273-11eb-9425-63860bf2c9a3.png">
</a>
</p>

<p align="center">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6-orange.svg">
  <img alt="iOS" src="https://img.shields.io/badge/iOS-26%2B-yellow">
  <img alt="Architecture" src="https://img.shields.io/badge/Architecture-Observable%20Store-blue">
</p>

## 📱 주요 기능

### 💧 오늘 탭
퀵버튼으로 간편하게 물 섭취량을 기록합니다.
- 기본 퀵버튼: 150ml, 300ml, 500ml
- 커스텀 퀵버튼: 자주 마시는 용량 설정 가능
- 직접 입력: 슬라이더로 정확한 양 입력
- 목표량 퀵설정: 🎯 버튼으로 빠르게 조절

### 📅 기록 탭
캘린더에서 달성 이력을 한눈에 확인합니다.
- 달성일 하이라이트 표시
- 선택한 날짜의 상세 기록
- 이번 달 달성 통계

### ⚙️ 설정 탭
앱을 나만의 스타일로 커스터마이즈합니다.
- 일일 목표량 설정 (1,500ml ~ 4,500ml)
- 퀵버튼 커스텀 (2개 버튼 설정)
- 알림 설정
- 문의 및 리뷰

## 🏗 앱 구조

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   Intro (스플래시)                                          │
│         │                                                   │
│         ▼                                                   │
│   ┌─────────────┬─────────────┬─────────────┐               │
│   │     💧      │     📅      │     ⚙️      │               │
│   │    오늘     │    기록     │    설정     │               │
│   └─────────────┴─────────────┴─────────────┘               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 🛠 기술 스택

| Category | Technology |
|----------|------------|
| UI | UIKit + SnapKit |
| Architecture | @Observable Store Pattern |
| Concurrency | async/await, Swift 6 |
| Animation | WaveAnimationView |
| Calendar | FSCalendar |
| Build | Tuist |

## 📦 의존성

```swift
// Tuist SPM
- SnapKit
- Then
- FSCalendar
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
