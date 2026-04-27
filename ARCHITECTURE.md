# ARCHITECTURE.md – DrinkSomeWater (벌컥벌컥)

> 최상위 구조 설명. 상세 설계는 각 플랫폼 docs/ 를 참조하세요.

---

## 시스템 개요

DrinkSomeWater(벌컥벌컥)는 하루 물 섭취량을 추적하고 HealthKit과 동기화하며, 주기적 알림으로 수분 섭취를 독려하는 크로스 플랫폼 앱이다.

**지원 플랫폼:** iOS, watchOS, Android, Wear OS

### 핵심 도메인

| 도메인 | 설명 |
|--------|------|
| Water Tracking | 섭취 기록 CRUD, 일일 목표, 음료 종류별 수분 효율 |
| HealthKit / Health Connect | 건강 데이터 동기화 |
| Reminders | 스마트 알림 (10가지 동기부여 문구) |
| Widget | 홈 화면 위젯 (Small / Medium / Large / 잠금화면) |
| Watch | Apple Watch / Wear OS 앱, 컴플리케이션 |
| Statistics | 7일 / 30일 통계, 스트릭 추적 |
| Cloud Sync | iCloud 동기화 |
| Premium | 구독 / 광고 제거 (StoreKit 2) |

---

## iOS 아키텍처

### 패턴: @Observable Store Pattern

ReactorKit에서 영감을 받은 단방향 데이터 흐름을 채택한다. 각 화면은 독립적인 Store를 가지며, View는 Store의 상태를 관찰하고 Action을 전달하는 역할만 한다.

```swift
@MainActor @Observable
final class HomeStore {
    enum Action { case addWater(Int), refresh }
    var ml: Float = 0
    func send(_ action: Action) async { /* ... */ }
}
```

### 레이어 구조

```
┌─────────────────────────────────────────┐
│  Presentation                           │
│  SwiftUI Views + UIKit ViewControllers  │
├─────────────────────────────────────────┤
│  Store                                  │
│  @Observable Store (Action → 상태 변환) │
├─────────────────────────────────────────┤
│  Service                                │
│  비즈니스 로직 (ServiceProvider)        │
├─────────────────────────────────────────┤
│  Data                                   │
│  UserDefaults / HealthKit / iCloud      │
│  WidgetKit                              │
└─────────────────────────────────────────┘
```

### 모듈 구조

| 모듈 | 역할 |
|------|------|
| `DrinkSomeWater/` | 메인 앱 (Models, Services, Stores, Views, ViewControllers, ViewComponents, DesignSystem) |
| `DrinkSomeWaterWidget/` | 위젯 익스텐션 |
| `DrinkSomeWaterWatch/` | watchOS 앱 |
| `Analytics/` | 분석 프레임워크 |
| `Shared/` | WidgetDataManager (앱 / 위젯 공유 헬퍼) |

---

## Android 아키텍처

### 패턴: MVI-style ViewModel + StateFlow

각 화면은 ViewModel이 단일 UI 상태를 StateFlow로 노출하며, 화면은 이벤트를 ViewModel에 전달한다.

### 멀티 모듈 구조

| 모듈 | 역할 |
|------|------|
| `app` | UI (Home / History / Settings / Onboarding), 서비스 (알림, 광고, 헬스), DI |
| `core` | 도메인 모델, Repository 인터페이스, DataStore 구현체 |
| `widget` | Glance 위젯 (UI / Data / Action) |
| `wear` | Wear OS (UI / Tile / Complication / Sync / Data / DI) |
| `analytics` | 분석 추상화 레이어 |

---

## 데이터 흐름

### iOS

```
User Action → SwiftUI View → Store.send(action) → ServiceProvider → Persistence
                                    │
                                    ├── HealthKit 동기화
                                    ├── iCloud 동기화
                                    ├── WidgetCenter.reloadAllTimelines()
                                    └── WatchConnectivity 동기화
```

### Android

```
User Event → Screen → ViewModel.onEvent() → Repository → DataStore
                                    │
                                    ├── Health Connect
                                    └── Wear DataLayer
```

---

## 주요 의존성

### iOS

| 종류 | 내용 |
|------|------|
| UI | SwiftUI + UIKit |
| 헬스 | HealthKit |
| 위젯 | WidgetKit |
| 워치 | WatchConnectivity |
| 인앱 결제 | StoreKit 2 |
| 클라우드 | iCloud (NSUbiquitousKeyValueStore) |
| 분석 | Firebase Analytics |
| 광고 | Google AdMob |
| 빌드 | Tuist |

### Android

| 종류 | 내용 |
|------|------|
| UI | Jetpack Compose |
| 헬스 | Health Connect |
| 위젯 | Glance |
| 워치 | Wear Compose |
| DI | Hilt |
| 비동기 | Coroutines + Flow |
| 저장 | DataStore |
| 백그라운드 작업 | WorkManager |
| 분석 | Firebase Analytics |
| 광고 | Google AdMob |
| 빌드 | Gradle KTS + Version Catalog |

---

## 빌드 & 타겟

| 플랫폼 | 타겟 / 모듈 | 최소 버전 |
|--------|------------|----------|
| iOS | DrinkSomeWater | iOS 18+ |
| iOS | DrinkSomeWaterWidget | iOS 18+ |
| iOS | DrinkSomeWaterWatch | watchOS 11+ |
| iOS | Analytics | iOS 18+ |
| iOS | DrinkSomeWaterTests | iOS 18+ |
| iOS | DrinkSomeWaterSnapshotTests | iOS 18+ |
| Android | app | Android 8.0+ |
| Android | core | Android 8.0+ |
| Android | widget | Android 8.0+ |
| Android | wear | Wear OS 2+ |
| Android | analytics | Android 8.0+ |

---

## 플랫폼 간 공유

공유 코드는 없다. iOS와 Android는 각각 독립적으로 구현된다.

- 기능 패리티 대응표 → `android/docs/IOS_ANDROID_MAPPING.md`
- 분석 이벤트 정의 → `docs/ANALYTICS.md`

---

*상세 설계 문서는 ios/docs/, android/docs/ 를 참조하세요.*
