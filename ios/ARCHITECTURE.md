# ARCHITECTURE.md – 벌컥벌컥 iOS

> iOS/watchOS 아키텍처 상세. 전체 시스템은 루트 ARCHITECTURE.md 를 참조.

---

## 아키텍처 패턴

@Observable Store Pattern (ReactorKit 영감, 단방향 데이터 흐름)을 사용한다.

데이터는 한 방향으로만 흐른다: **View → Store.send(action) → Service → Data**

Store는 `@MainActor @Observable`로 선언하며, `Action` enum으로 입력을 받는다.

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

---

## 레이어 다이어그램

```
┌─────────────────────────────────────────────┐
│  Presentation                               │
│  SwiftUI Views + UIKit ViewControllers      │
├─────────────────────────────────────────────┤
│  Store (@Observable)                        │
│  Action → State mutation                    │
├─────────────────────────────────────────────┤
│  Service (ServiceProvider)                  │
│  비즈니스 로직, 외부 연동                     │
├─────────────────────────────────────────────┤
│  Data                                       │
│  UserDefaults · HealthKit · iCloud · Widget │
└─────────────────────────────────────────────┘
```

---

## 앱 진입 흐름

```
main.swift → AppDelegate → SceneDelegate
                              │
                    ┌─────────┴──────────┐
                    │ 온보딩 미완료        │ 온보딩 완료
                    ▼                    ▼
            OnboardingVC         IntroViewController
                                        │
                                        ▼
                                   MainTabView
                                 ┌────┼────┐
                                Home History Settings
```

---

## 주요 Store 목록

| Store | 책임 |
|-------|------|
| HomeStore | 오늘 섭취량, 퀵버튼, 물 추가/빼기 |
| HistoryStore | 기록 조회, 캘린더/리스트/타임라인 |
| SettingsStore | 목표, 알림, 프로필 |
| StatisticsStore | 7일/30일 통계, 스트릭 |
| InformationStore | 앱 정보 |

---

## 주요 Service 목록

| Service | 책임 |
|---------|------|
| WaterStorageService | 물 섭취 CRUD (UserDefaults) |
| HealthKitService | Apple Health 연동 |
| CloudSyncService | iCloud 동기화 |
| NotificationService | 스마트 알림 |
| WatchConnectivityService | Apple Watch 동기화 |
| StoreKitService | 구독/IAP (StoreKit 2) |
| AdService | Google AdMob |
| InstagramSharingService | 소셜 공유 |
| AppUpdateChecker | 앱 업데이트 확인 |

---

## 위젯 아키텍처

- WidgetKit + AppIntent (Interactive) 기반
- `Shared/` 모듈의 WidgetDataManager로 앱↔위젯 데이터 공유
- TimelineProvider 기반 타임라인 갱신

---

## watchOS 아키텍처

- WatchConnectivity로 iPhone↔Watch 데이터 동기화
- 독립 UI (SwiftUI)

---

## 의존성

| 분류 | 항목 |
|------|------|
| Apple | SwiftUI, UIKit, HealthKit, WidgetKit, WatchConnectivity, StoreKit 2, iCloud |
| Firebase | Analytics, Crashlytics, RemoteConfig |
| Google | AdMob |
| UI | SnapKit, FSCalendar |
| Test | SnapshotTesting |

---

*상세 기술 스펙은 docs/TECH_SPEC.md 를 참조하세요.*
