# 벌컥벌컥 (Gulp)

> 💧 간편한 물 섭취 기록 iOS & watchOS 앱

<p align="center">
  <img src="https://user-images.githubusercontent.com/59601439/115199996-bd370800-a12e-11eb-8f70-bc1ab0a0c97d.PNG" width="600">
</p>

<p align="center">
  <a href="https://apps.apple.com/kr/app/%EB%B2%8C%EC%BB%A5%EB%B2%8C%EC%BB%A5/id1563673158">
    <img src="https://user-images.githubusercontent.com/59601439/120217924-fefdb700-c273-11eb-9425-63860bf2c9a3.png" height="50">
  </a>
</p>

<p align="center">
  <img alt="Swift" src="https://img.shields.io/badge/Swift-6-orange.svg">
  <img alt="iOS" src="https://img.shields.io/badge/iOS-18%2B-blue">
  <img alt="watchOS" src="https://img.shields.io/badge/watchOS-11%2B-red">
  <img alt="Architecture" src="https://img.shields.io/badge/Architecture-Observable%20Store-green">
</p>

---

## Features

| 💧 오늘 | 📅 기록 | ⚙️ 설정 |
|--------|--------|--------|
| 퀵버튼으로 물 섭취 기록 | 캘린더/리스트/타임라인 뷰 | 목표량 설정 |
| 물결 애니메이션 진행도 | 달성일 하이라이트 | 퀵버튼 커스텀 |
| 목표량 퀵설정 | 월간 달성 통계 | 알림 설정 |

### Additional Features

- **Apple Watch** - 손목에서 바로 기록, 컴플리케이션 지원
- **홈 화면 위젯** - Small/Medium/Large/잠금화면 위젯
- **Apple Health** - 체중 연동, 물 섭취 기록 동기화
- **스마트 알림** - 10가지 랜덤 동기부여 문구

---

## Tech Stack

| Category | Technology |
|----------|------------|
| UI | SwiftUI + UIKit |
| Architecture | @Observable Store Pattern |
| Concurrency | Swift 6, async/await |
| Widget | WidgetKit + AppIntent |
| Watch | WatchConnectivity |
| Health | HealthKit |
| Analytics | Firebase Analytics |
| Ads | Google AdMob |
| Build | Tuist |

---

## Getting Started

```bash
# Install Tuist
mise install tuist

# Setup & Run
tuist install && tuist generate

# Build & Test
tuist build
tuist test
```

---

## Architecture

**@Observable Store Pattern** - ReactorKit 영감의 단방향 데이터 흐름

```swift
@MainActor @Observable
final class HomeStore {
    enum Action { case addWater(Int), refresh }
    
    var ml: Float = 0
    var total: Float = 0
    var progress: Float { total == 0 ? 0 : ml / total }
    
    func send(_ action: Action) async { /* ... */ }
}
```

```
┌─────────────────────────────────────────┐
│              iOS App                    │
│   ┌─────────┬─────────┬─────────┐       │
│   │  오늘   │  기록   │  설정   │       │
│   └─────────┴─────────┴─────────┘       │
│              WatchConnectivity          │
├─────────────────────────────────────────┤
│            watchOS App                  │
│   ┌─────────────────────────────┐       │
│   │   홈 + 퀵추가 + 컴플리케이션   │       │
│   └─────────────────────────────┘       │
└─────────────────────────────────────────┘
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [Analytics Events](./docs/ANALYTICS.md) | Firebase Analytics 이벤트 정의 |

---

## License

MIT License - [LICENSE](./LICENSE)
