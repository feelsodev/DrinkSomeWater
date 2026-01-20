# 벌컥벌컥 (Gulp) Android 프로젝트 계획서

> 💧 물 섭취 기록 Android & Wear OS 앱 개발 마스터 문서

---

## 메타 정보

| 항목 | 값 |
|------|-----|
| **버전** | 1.0.0 |
| **최종 업데이트** | 2026-01-20 |
| **상태** | 📝 문서 단계 (프로젝트 스캐폴딩 전) |
| **개발 방식** | TDD (Test-Driven Development) |
| **iOS 참조 버전** | 26.2.0 |

---

## 목차

1. [프로젝트 개요](#1-프로젝트-개요)
2. [기술 스택](#2-기술-스택)
3. [프로젝트 구조](#3-프로젝트-구조)
4. [Phase별 작업 목록](#4-phase별-작업-목록)
5. [의존성 목록](#5-의존성-목록)
6. [진행 상황 로그](#6-진행-상황-로그)

---

## 1. 프로젝트 개요

### 1.1 목표
iOS 벌컥벌컥 앱의 완전한 Android 버전 개발

### 1.2 범위
- ✅ Phone 앱 (메인)
- ✅ 홈 화면 위젯 (Glance)
- ✅ Wear OS 앱

### 1.3 핵심 기능
| 기능 | 설명 | iOS 참조 |
|------|------|----------|
| 물 섭취 기록 | 퀵버튼으로 간편 기록 | HomeView.swift |
| 물 빼기/초기화 | 잘못 기록한 양 수정 | HomeStore.swift |
| 기록 조회 | 캘린더/리스트/타임라인 3가지 뷰 | HistoryView.swift |
| 목표 설정 | 일일 목표량 (1,000~4,500ml) | GoalSettingView |
| 퀵버튼 커스텀 | 자주 마시는 용량 설정 | QuickButtonSettingView |
| 알림 시스템 | 10가지 랜덤 문구 알림 | NotificationService.swift |
| Health Connect | 체중/물 섭취 연동 | HealthKitService.swift |
| 홈 위젯 | Small/Medium/Large 위젯 | DrinkSomeWaterWidget |
| Wear OS | 워치에서 물 기록 | DrinkSomeWaterWatch |

### 1.4 개발 원칙
1. **TDD 필수**: 테스트 먼저 작성, 구현, 리팩토링
2. **iOS 동일 UX**: 사용자 경험 일관성 유지
3. **Clean Architecture**: Domain/Data/UI 레이어 분리
4. **단방향 데이터 흐름**: MVI 패턴 적용

### 1.5 현재 상태

> ⚠️ **주의**: 현재는 **문서 단계**입니다. `android/` 폴더에는 문서만 있고, 실제 Gradle 프로젝트는 Phase 1에서 생성됩니다.

```
현재 상태:
android/
├── docs/           ✅ 문서 (완료)
├── README.md       ✅ 가이드 (완료)
└── .gitignore      ✅ 설정 (완료)

Phase 1 완료 후:
android/
├── app/            ⏳ 메인 앱 모듈
├── widget/         ⏳ 위젯 모듈
├── wear/           ⏳ Wear OS 모듈
├── analytics/      ⏳ Analytics 모듈
├── gradle/         ⏳ Version Catalog
├── build.gradle.kts ⏳ Root build script
└── settings.gradle.kts ⏳ 모듈 설정
```

### 1.6 저장소 전략

| 데이터 | 저장 방식 | 이유 |
|--------|----------|------|
| **목표량, 퀵버튼, 설정** | DataStore Preferences | 단순 key-value |
| **물 섭취 기록 (History)** | DataStore Preferences + JSON 직렬화 | 레코드 수가 적음 (일 1개) |
| **온보딩 완료 플래그** | DataStore Preferences | 단순 Boolean |

**History 저장 전략:**
- 일별 1개 레코드 → 연간 최대 365개
- `List<WaterRecord>`를 JSON으로 직렬화하여 저장
- 마이그레이션: 버전 필드 포함, 스키마 변경 시 변환 로직 추가
- 향후 확장: 레코드 수 1000개 초과 시 Room DB로 마이그레이션 고려

```kotlin
// 저장 형태 예시
@Serializable
data class WaterRecordsWrapper(
    val version: Int = 1,
    val records: List<WaterRecord>
)
```

### 1.7 플랫폼별 제약사항

#### Glance (홈 화면 위젯)

| 제약 | 설명 | 대응 |
|------|------|------|
| **제한된 Composable** | Row, Column, Box, Text, Image 등 기본만 지원 | Compose Canvas 사용 불가 → PNG/Vector 이미지로 대체 |
| **상호작용 제한** | 클릭만 가능, 드래그/스와이프 불가 | 퀵버튼은 단순 클릭으로 설계 |
| **스타일 제한** | Material 3 테마 직접 적용 불가 | `glance-material3` 어댑터 사용 |
| **갱신 빈도** | 최소 30분 간격 (시스템 제한) | 사용자 액션 시 즉시 갱신 + 주기적 백그라운드 갱신 |
| **크기 제약** | 위젯 크기에 따라 레이아웃 분기 필요 | Small/Medium/Large 별도 UI 구현 |

```kotlin
// Wave 애니메이션 대체 전략
// ❌ Compose Canvas (Glance에서 미지원)
// ✅ 정적 진행률 표시 (CircularProgressIndicator 유사)
// ✅ 또는 미리 렌더링된 이미지 에셋 사용
```

#### Wear OS

| 제약 | 설명 | 대응 |
|------|------|------|
| **데이터 동기화 지연** | Phone ↔ Watch 동기화에 수초~수십초 소요 가능 | 낙관적 UI 업데이트 + 백그라운드 동기화 |
| **타일 갱신 제한** | 시스템이 타일 갱신 시점 제어 | `TileService.getRequester().requestUpdate()` 호출하되, 즉시 반영 보장 X |
| **배터리 민감** | 백그라운드 작업 제한적 | Data Layer API 사용, 불필요한 폴링 X |
| **화면 크기** | 작은 원형 디스플레이 | 최소 정보만 표시, 큰 터치 영역 |
| **입력 제한** | 키보드 입력 불편 | 50ml 단위 스텝퍼로 직접 입력 대체 |
| **독립 실행 제한** | Phone 앱 설치 필수 (Dependent app) | Phone 미연결 시 오프라인 모드 안내 |

```kotlin
// 데이터 동기화 전략
// 1. Watch에서 물 추가 → 로컬 UI 즉시 업데이트 (낙관적)
// 2. MessageClient로 Phone에 전송
// 3. Phone에서 처리 후 DataClient로 확정 데이터 동기화
// 4. 충돌 시: Phone 데이터 우선 (source of truth)
```

#### Health Connect

| 제약 | 설명 | 대응 |
|------|------|------|
| **가용성** | Android 14+ 기본 탑재, 이전 버전은 별도 앱 설치 필요 | `HealthConnectClient.getSdkStatus()` 또는 `sdkStatus` 체크 후 미설치 시 Play Store 안내 |
| **권한 플로우** | 각 데이터 타입별 별도 권한 요청 | 체중 읽기, 물 섭취 쓰기 권한 분리 요청 |
| **지역 제한** | 일부 국가/디바이스에서 사용 불가 | SDK status 체크로 가용성 확인, 불가 시 graceful degradation |
| **백그라운드/주기 작업** | OS 정책/쿼터로 제한, foreground 중심 설계 권장 | 앱 실행 시 최신 체중 조회 + 로컬 캐싱, 백그라운드 실패 대비 |
| **히스토리 접근 제한** | 권한 승인 후 과거 데이터 접근 제한 (예: 최근 30일) | 과거 데이터 없을 시 UX 안내, 수동 입력 fallback |
| **데이터 중복** | 다른 앱과 중복 기록 가능 | `metadata.clientRecordId`로 우리 앱 기록만 관리 |

```kotlin
// Health Connect 초기화 플로우
// 1. HealthConnectClient.getSdkStatus(context) 체크
//    - SDK_UNAVAILABLE: Health Connect 미지원 (기능 비활성화)
//    - SDK_UNAVAILABLE_PROVIDER_UPDATE_REQUIRED: Play Store 업데이트 안내
//    - SDK_AVAILABLE: 사용 가능
// 2. 권한 요청: HealthPermission.getReadPermission(WeightRecord::class)
//              HealthPermission.getWritePermission(HydrationRecord::class)
// 3. 권한 거부 시: 기능 비활성화, 수동 체중 입력 유도
// 4. 히스토리 읽기 실패/빈 결과 시: "최근 기록이 없습니다" 안내

// UX 실패 대비 플로우
// - Health Connect 연동 ON이지만 데이터 없음 → "체중을 직접 입력해주세요"
// - 권한 취소됨 → 다음 실행 시 재요청 또는 설정 화면 안내
// - 쓰기 실패 → 로컬에는 저장, 나중에 재시도 (best effort)
```

---

## 2. 기술 스택

### 2.1 iOS → Android 매핑

| 영역 | iOS | Android |
|------|-----|---------|
| **Language** | Swift 6 | Kotlin 2.0 |
| **UI Framework** | SwiftUI | Jetpack Compose |
| **Architecture** | @Observable Store | ViewModel + StateFlow (MVI) |
| **Async** | async/await | Coroutines + Flow |
| **DI** | Manual | Hilt |
| **Storage** | UserDefaults | DataStore Preferences |
| **Health** | HealthKit | Health Connect |
| **Widget** | WidgetKit | Glance API |
| **Watch** | WatchConnectivity | Wear OS Data Layer |
| **Calendar** | FSCalendar | Custom Compose |
| **Animation** | WaveAnimationView | Compose Canvas |
| **Analytics** | Firebase Analytics | Firebase Analytics |
| **Ads** | Google AdMob | Google AdMob |
| **Build** | Tuist | Gradle + Version Catalog |

### 2.2 핵심 라이브러리

| 라이브러리 | 버전 | 용도 |
|-----------|------|------|
| Kotlin | 2.0.0 | 언어 |
| Compose BOM | 2024.09.00 | UI 프레임워크 |
| Hilt | 2.51 | 의존성 주입 |
| DataStore | 1.1.1 | 로컬 저장소 |
| Coroutines | 1.8.0 | 비동기 처리 |
| Glance | 1.1.0 | 위젯 |
| Health Connect | 1.1.0-alpha07 | 건강 데이터 |
| Firebase BOM | 33.1.0 | 분석/광고 |
| JUnit5 | 5.10.0 | 테스트 |
| Turbine | 1.1.0 | Flow 테스트 |
| MockK | 1.13.10 | 모킹 |

### 2.3 빌드 환경

| 항목 | 값 |
|------|-----|
| minSdk | 29 (Android 10) |
| targetSdk | 35 (Android 15) |
| compileSdk | 35 |
| JDK | 17 |
| Gradle | 8.5 |
| AGP | 8.3.0 |

---

## 3. 프로젝트 구조

### 3.1 모듈 구조

> ⚠️ **중요**: `widget`과 `wear` 모듈이 `app`의 domain/data 코드를 재사용해야 합니다.
> 따라서 **공유 모듈 `:core`**를 두어 모델, Repository 인터페이스, DataStore를 분리합니다.

```
android/
├── core/                         # 🆕 공유 모듈 (app, widget, wear 공통)
│   ├── src/main/java/com/onceagain/drinksomewater/core/
│   │   ├── domain/               # 도메인 레이어 (공유)
│   │   │   ├── model/            # WaterRecord, UserProfile 등
│   │   │   └── repository/       # Repository 인터페이스
│   │   ├── data/                 # 데이터 레이어 (공유)
│   │   │   ├── repository/       # Repository 구현
│   │   │   ├── datastore/        # DataStore
│   │   │   └── mapper/           # 데이터 매퍼
│   │   └── util/                 # 공통 유틸리티
│   ├── src/test/                 # core 단위 테스트
│   └── build.gradle.kts
│
├── app/                          # 메인 앱 모듈 (Phone)
│   ├── src/main/java/com/onceagain/drinksomewater/
│   │   ├── di/                   # Hilt 모듈
│   │   ├── ui/                   # UI 레이어
│   │   │   ├── home/             # 홈 화면
│   │   │   ├── history/          # 기록 화면
│   │   │   ├── settings/         # 설정 화면
│   │   │   ├── onboarding/       # 온보딩
│   │   │   ├── theme/            # 테마/디자인 토큰
│   │   │   ├── components/       # 공통 컴포넌트
│   │   │   └── navigation/       # 네비게이션
│   │   └── service/              # 서비스
│   │       ├── notification/     # 알림
│   │       └── health/           # Health Connect
│   ├── src/test/                 # app 단위 테스트 (JUnit5)
│   ├── src/androidTest/          # UI 테스트 (JUnit4)
│   └── build.gradle.kts          # implementation(project(":core"))
│
├── widget/                       # Glance 위젯 모듈
│   ├── src/main/java/.../widget/
│   │   ├── WaterGlanceWidget.kt
│   │   ├── WaterWidgetReceiver.kt
│   │   ├── ui/
│   │   │   ├── SmallWidget.kt
│   │   │   ├── MediumWidget.kt
│   │   │   └── LargeWidget.kt
│   │   └── action/
│   │       └── AddWaterAction.kt
│   └── build.gradle.kts          # implementation(project(":core"))
│
├── wear/                         # Wear OS 모듈
│   ├── src/main/java/.../wear/
│   │   ├── WearApplication.kt
│   │   ├── ui/
│   │   │   ├── HomeScreen.kt
│   │   │   ├── QuickAddScreen.kt
│   │   │   └── CustomAmountScreen.kt
│   │   ├── tile/
│   │   │   └── WaterTileService.kt
│   │   └── complication/
│   │       └── WaterComplicationService.kt
│   └── build.gradle.kts          # implementation(project(":core"))
│
├── analytics/                    # Analytics 모듈
│   ├── src/main/java/.../analytics/
│   │   ├── Analytics.kt
│   │   ├── AnalyticsEvent.kt
│   │   └── AnalyticsTracker.kt
│   └── build.gradle.kts
│
├── docs/                         # 문서
│   ├── ANDROID_PROJECT_PLAN.md   # 이 문서
│   ├── ANDROID_TDD_GUIDE.md      # TDD 가이드
│   └── IOS_ANDROID_MAPPING.md    # 파일 매핑
│
├── gradle/
│   └── libs.versions.toml        # Version Catalog
│
├── build.gradle.kts              # Root build script
├── settings.gradle.kts           # include(":core", ":app", ":widget", ":wear", ":analytics")
└── README.md                     # 빌드 가이드
```

#### 모듈 의존성 그래프

```
              ┌─────────────┐
              │  analytics  │  (독립, 어디서든 사용)
              └─────────────┘
                     │
    ┌────────────────┼────────────────┐
    │                │                │
    ▼                ▼                ▼
┌───────┐       ┌─────────┐      ┌────────┐
│  app  │       │  widget │      │  wear  │
└───┬───┘       └────┬────┘      └───┬────┘
    │                │               │
    └────────────────┼───────────────┘
                     │
                     ▼
              ┌─────────────┐
              │    core     │  (domain + data 공유)
              └─────────────┘
```

### 3.2 패키지 구조

#### core 모듈 (공유)

```
com.onceagain.drinksomewater.core
├── domain
│   ├── model
│   │   ├── WaterRecord.kt
│   │   ├── UserProfile.kt
│   │   └── NotificationSettings.kt
│   └── repository
│       ├── WaterRepository.kt
│       ├── SettingsRepository.kt
│       └── ProfileRepository.kt
├── data
│   ├── repository
│   │   ├── WaterRepositoryImpl.kt
│   │   ├── SettingsRepositoryImpl.kt
│   │   └── ProfileRepositoryImpl.kt
│   ├── datastore
│   │   ├── WaterDataStore.kt
│   │   └── PreferencesKeys.kt
│   └── mapper
│       └── RecordMapper.kt
└── util
    ├── DateExtensions.kt
    └── FlowExtensions.kt
```

#### app 모듈 (Phone UI)

```
com.onceagain.drinksomewater
├── di
│   ├── AppModule.kt
│   ├── DataModule.kt
│   └── ServiceModule.kt
├── ui
│   ├── home
│   │   ├── HomeScreen.kt
│   │   ├── HomeViewModel.kt
│   │   ├── HomeUiState.kt
│   │   └── components/
│   ├── history
│   │   ├── HistoryScreen.kt
│   │   ├── HistoryViewModel.kt
│   │   └── components/
│   ├── settings
│   │   ├── SettingsScreen.kt
│   │   ├── SettingsViewModel.kt
│   │   └── screens/
│   ├── onboarding
│   │   ├── OnboardingScreen.kt
│   │   └── OnboardingViewModel.kt
│   ├── theme
│   │   ├── DesignTokens.kt
│   │   ├── Theme.kt
│   │   ├── Color.kt
│   │   └── Type.kt
│   ├── components
│   │   ├── WaveAnimation.kt
│   │   ├── BottleView.kt
│   │   ├── QuickButton.kt
│   │   ├── CustomCalendar.kt
│   │   └── RecordCard.kt
│   └── navigation
│       ├── AppNavigation.kt
│       └── Screen.kt
└── service
    ├── notification
    │   ├── NotificationHelper.kt
    │   ├── WaterReminderWorker.kt
    │   └── NotificationMessages.kt
    └── health
        └── HealthConnectHelper.kt
```

---

## 4. Phase별 작업 목록

> ✅ 완료 | 🚧 진행 중 | ⏳ 대기 중 | ❌ 차단됨

### Phase 1: 프로젝트 초기 설정 (예상 1주)

| # | 작업 | 테스트 | 상태 | 비고 |
|---|------|--------|------|------|
| 1.1 | Android 프로젝트 생성 | - | ⏳ | Kotlin 2.0, Compose |
| 1.2 | 멀티모듈 구조 설정 | - | ⏳ | app, widget, wear, analytics |
| 1.3 | Version Catalog 설정 | - | ⏳ | libs.versions.toml |
| 1.4 | Hilt DI 설정 | - | ⏳ | AppModule 기본 구성 |
| 1.5 | 디자인 시스템 | DesignTokensTest | ⏳ | DesignTokens.kt |
| 1.6 | 테마 설정 | - | ⏳ | Material 3 테마 |
| 1.7 | 네비게이션 설정 | - | ⏳ | Navigation Compose |
| 1.8 | 테스트 인프라 | - | ⏳ | JUnit5, Turbine, MockK |
| 1.9 | CI 설정 | - | ⏳ | GitHub Actions |

### Phase 2: 데이터 레이어 (예상 1주)

| # | 작업 | 테스트 | 상태 | iOS 참조 |
|---|------|--------|------|----------|
| 2.1 | WaterRecord 모델 | WaterRecordTest | ⏳ | WaterRecord.swift |
| 2.2 | UserProfile 모델 | UserProfileTest | ⏳ | UserProfile.swift |
| 2.3 | NotificationSettings 모델 | NotificationSettingsTest | ⏳ | NotificationSettings.swift |
| 2.4 | PreferencesKeys 정의 | - | ⏳ | UserDefaultsKey.swift |
| 2.5 | WaterDataStore | WaterDataStoreTest | ⏳ | UserDefaultsService.swift |
| 2.6 | WaterRepository 인터페이스 | - | ⏳ | WaterServiceProtocol |
| 2.7 | WaterRepositoryImpl | WaterRepositoryTest | ⏳ | WaterService.swift |
| 2.8 | SettingsRepository | SettingsRepositoryTest | ⏳ | - |

### Phase 3: 홈 화면 (예상 2주)

| # | 작업 | 테스트 | 상태 | iOS 참조 |
|---|------|--------|------|----------|
| 3.1 | HomeUiState 정의 | - | ⏳ | HomeStore state |
| 3.2 | HomeViewModel | HomeViewModelTest | ⏳ | HomeStore.swift |
| 3.3 | WaveAnimation | WaveAnimationTest | ⏳ | WaveAnimationView.swift |
| 3.4 | BottleView | - | ⏳ | HomeView bottleSection |
| 3.5 | QuickButton 컴포넌트 | - | ⏳ | HomeView quickButtonsSection |
| 3.6 | HomeScreen 레이아웃 | HomeScreenTest | ⏳ | HomeView.swift |
| 3.7 | GoalSettingSheet | GoalSettingTest | ⏳ | GoalSettingView |
| 3.8 | QuickButtonSettingSheet | - | ⏳ | QuickButtonSettingView |
| 3.9 | NotificationBanner | - | ⏳ | notificationBanner |
| 3.10 | 접근성 레이블 | - | ⏳ | accessibility labels |

### Phase 4: 기록 화면 (예상 2주)

| # | 작업 | 테스트 | 상태 | iOS 참조 |
|---|------|--------|------|----------|
| 4.1 | HistoryUiState 정의 | - | ⏳ | HistoryStore state |
| 4.2 | HistoryViewModel | HistoryViewModelTest | ⏳ | HistoryStore.swift |
| 4.3 | CustomCalendar | CustomCalendarTest | ⏳ | FSCalendarRepresentable |
| 4.4 | CalendarTab | - | ⏳ | HistoryCalendarTab |
| 4.5 | ListTab | - | ⏳ | HistoryListTab |
| 4.6 | TimelineTab | - | ⏳ | HistoryTimelineTab |
| 4.7 | RecordCard | - | ⏳ | RecordCard |
| 4.8 | HistoryScreen (Pager) | HistoryScreenTest | ⏳ | HistoryView.swift |
| 4.9 | MonthSummaryBadge | - | ⏳ | monthSummaryBadge |

### Phase 5: 설정 화면 (예상 1주)

| # | 작업 | 테스트 | 상태 | iOS 참조 |
|---|------|--------|------|----------|
| 5.1 | SettingsViewModel | SettingsViewModelTest | ⏳ | SettingsStore.swift |
| 5.2 | SettingsScreen | - | ⏳ | SettingsViewController |
| 5.3 | NotificationSettingScreen | - | ⏳ | NotificationSettingVC |
| 5.4 | ProfileSettingScreen | ProfileSettingTest | ⏳ | ProfileSettingVC |
| 5.5 | WidgetGuideScreen | - | ⏳ | WidgetGuideVC |
| 5.6 | AboutSection | - | ⏳ | 버전, 리뷰, 문의 |

### Phase 6: 알림 시스템 (예상 1주)

| # | 작업 | 테스트 | 상태 | iOS 참조 |
|---|------|--------|------|----------|
| 6.1 | NotificationMessages | NotificationMessagesTest | ⏳ | NotificationMessages.swift |
| 6.2 | NotificationHelper | NotificationHelperTest | ⏳ | NotificationService.swift |
| 6.3 | WaterReminderWorker | WorkerTest | ⏳ | - |
| 6.4 | NotificationChannel 설정 | - | ⏳ | - |
| 6.5 | BootReceiver | - | ⏳ | - |
| 6.6 | 권한 요청 (Android 13+) | - | ⏳ | - |

### Phase 7: 홈 화면 위젯 (예상 2주)

| # | 작업 | 테스트 | 상태 | iOS 참조 |
|---|------|--------|------|----------|
| 7.1 | widget 모듈 설정 | - | ⏳ | DrinkSomeWaterWidget |
| 7.2 | WaterWidgetState | - | ⏳ | WaterEntry.swift |
| 7.3 | WaterGlanceWidget | - | ⏳ | DrinkSomeWaterWidget.swift |
| 7.4 | SmallWidget UI | SmallWidgetTest | ⏳ | SmallWidgetView.swift |
| 7.5 | MediumWidget UI | MediumWidgetTest | ⏳ | MediumWidgetView.swift |
| 7.6 | LargeWidget UI | LargeWidgetTest | ⏳ | LargeWidgetView.swift |
| 7.7 | AddWaterAction | AddWaterActionTest | ⏳ | AddWaterIntent.swift |
| 7.8 | 위젯 데이터 동기화 | - | ⏳ | WidgetDataManager.swift |

### Phase 8: 온보딩 (예상 1주)

| # | 작업 | 테스트 | 상태 | iOS 참조 |
|---|------|--------|------|----------|
| 8.1 | OnboardingViewModel | OnboardingViewModelTest | ⏳ | OnboardingStore.swift |
| 8.2 | OnboardingScreen (Pager) | - | ⏳ | OnboardingViewController |
| 8.3 | IntroPage | - | ⏳ | 앱 소개 |
| 8.4 | GoalSettingPage | - | ⏳ | 목표 설정 |
| 8.5 | HealthConnectPage | - | ⏳ | HealthKit 연동 |
| 8.6 | NotificationPage | - | ⏳ | 알림 설정 |
| 8.7 | WidgetGuidePage | - | ⏳ | 위젯 안내 |
| 8.8 | 완료 플래그 저장 | - | ⏳ | onboardingCompleted |

### Phase 9: Health Connect (예상 1주)

| # | 작업 | 테스트 | 상태 | iOS 참조 |
|---|------|--------|------|----------|
| 9.1 | Health Connect SDK 설정 | - | ⏳ | HealthKitService.swift |
| 9.2 | HealthConnectHelper | HealthConnectHelperTest | ⏳ | - |
| 9.3 | 체중 읽기 | - | ⏳ | fetchWeight |
| 9.4 | 권장량 계산 | RecommendedIntakeTest | ⏳ | recommendedIntake |
| 9.5 | 물 섭취 기록 저장 | - | ⏳ | writeHydration |
| 9.6 | 권한 요청 화면 | - | ⏳ | - |

### Phase 10: Analytics & AdMob (예상 1주)

| # | 작업 | 테스트 | 상태 | iOS 참조 |
|---|------|--------|------|----------|
| 10.1 | analytics 모듈 설정 | - | ⏳ | Analytics/ |
| 10.2 | AnalyticsEvent 정의 | - | ⏳ | AnalyticsEvent.swift |
| 10.3 | AnalyticsTracker | AnalyticsTrackerTest | ⏳ | Analytics.swift |
| 10.4 | Firebase 초기화 | - | ⏳ | google-services.json |
| 10.5 | AdMob 초기화 | - | ⏳ | AdMobService.swift |
| 10.6 | NativeAdView | - | ⏳ | NativeAdView.swift |
| 10.7 | RewardedAdHelper | - | ⏳ | - |

### Phase 11: Wear OS (예상 2주)

| # | 작업 | 테스트 | 상태 | iOS 참조 |
|---|------|--------|------|----------|
| 11.1 | wear 모듈 설정 | - | ⏳ | DrinkSomeWaterWatch |
| 11.2 | WearApplication | - | ⏳ | DrinkSomeWaterWatchApp |
| 11.3 | WatchViewModel | WatchViewModelTest | ⏳ | WatchStore.swift |
| 11.4 | HomeScreen | - | ⏳ | HomeView.swift (Watch) |
| 11.5 | QuickAddScreen | - | ⏳ | QuickAddView.swift |
| 11.6 | CustomAmountScreen | - | ⏳ | CustomAmountView.swift |
| 11.7 | DataLayerSync | DataLayerSyncTest | ⏳ | WatchConnectivityService |
| 11.8 | WaterTileService | - | ⏳ | WaterComplication.swift |
| 11.9 | Complication | - | ⏳ | - |

### Phase 12: 테스트 & 마무리 (예상 1주)

| # | 작업 | 상태 | 비고 |
|---|------|------|------|
| 12.1 | 통합 테스트 | ⏳ | E2E 테스트 |
| 12.2 | UI 테스트 | ⏳ | Compose UI 테스트 |
| 12.3 | 접근성 검증 | ⏳ | TalkBack 테스트 |
| 12.4 | 다국어 지원 | ⏳ | 한국어/영어 |
| 12.5 | ProGuard 설정 | ⏳ | 난독화 |
| 12.6 | 릴리스 서명 | ⏳ | 키스토어 |
| 12.7 | Play Store 준비 | ⏳ | 스크린샷, 설명 |

---

## 5. 의존성 목록

### 5.1 Version Catalog (libs.versions.toml)

> ⚠️ **Kotlin 2.0 + Compose 설정**: Kotlin 2.0부터 Compose 컴파일러는 별도 artifact가 아닌 `org.jetbrains.kotlin.plugin.compose` 플러그인으로 통합되었습니다. `compose-compiler` 버전을 별도로 지정하지 않습니다.

```toml
[versions]
# Kotlin & Android
kotlin = "2.0.0"
agp = "8.3.0"
ksp = "2.0.0-1.0.21"

# Compose (Kotlin 2.0에서는 compose-compiler 버전 불필요)
compose-bom = "2024.09.00"
activity-compose = "1.9.0"
navigation-compose = "2.7.7"

# AndroidX
core-ktx = "1.13.1"
lifecycle = "2.8.0"
datastore = "1.1.1"
work = "2.9.0"

# Hilt
hilt = "2.51"
hilt-navigation-compose = "1.2.0"

# Widget
glance = "1.1.0"

# Wear OS
wear-compose = "1.3.1"
wear-tiles = "1.3.0"
play-services-wearable = "18.1.0"

# Health
health-connect = "1.1.0-alpha07"

# Firebase
firebase-bom = "33.1.0"

# AdMob
play-services-ads = "23.0.0"

# Testing
junit5 = "5.10.0"
turbine = "1.1.0"
mockk = "1.13.10"
coroutines-test = "1.8.0"
androidx-test-runner = "1.5.2"
androidx-test-rules = "1.5.0"

# Serialization
kotlinx-serialization = "1.6.3"
kotlinx-datetime = "0.6.0"

[libraries]
# Compose BOM
androidx-compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "compose-bom" }
androidx-compose-ui = { group = "androidx.compose.ui", name = "ui" }
androidx-compose-ui-graphics = { group = "androidx.compose.ui", name = "ui-graphics" }
androidx-compose-ui-tooling = { group = "androidx.compose.ui", name = "ui-tooling" }
androidx-compose-ui-tooling-preview = { group = "androidx.compose.ui", name = "ui-tooling-preview" }
androidx-compose-material3 = { group = "androidx.compose.material3", name = "material3" }
androidx-compose-material-icons = { group = "androidx.compose.material", name = "material-icons-extended" }

# Activity & Navigation
androidx-activity-compose = { group = "androidx.activity", name = "activity-compose", version.ref = "activity-compose" }
androidx-navigation-compose = { group = "androidx.navigation", name = "navigation-compose", version.ref = "navigation-compose" }

# Lifecycle
androidx-lifecycle-runtime = { group = "androidx.lifecycle", name = "lifecycle-runtime-ktx", version.ref = "lifecycle" }
androidx-lifecycle-viewmodel-compose = { group = "androidx.lifecycle", name = "lifecycle-viewmodel-compose", version.ref = "lifecycle" }

# DataStore
androidx-datastore-preferences = { group = "androidx.datastore", name = "datastore-preferences", version.ref = "datastore" }

# WorkManager
androidx-work-runtime = { group = "androidx.work", name = "work-runtime-ktx", version.ref = "work" }

# Hilt
hilt-android = { group = "com.google.dagger", name = "hilt-android", version.ref = "hilt" }
hilt-compiler = { group = "com.google.dagger", name = "hilt-android-compiler", version.ref = "hilt" }
hilt-navigation-compose = { group = "androidx.hilt", name = "hilt-navigation-compose", version.ref = "hilt-navigation-compose" }

# Glance (Widget)
androidx-glance = { group = "androidx.glance", name = "glance", version.ref = "glance" }
androidx-glance-appwidget = { group = "androidx.glance", name = "glance-appwidget", version.ref = "glance" }
androidx-glance-material3 = { group = "androidx.glance", name = "glance-material3", version.ref = "glance" }

# Wear OS
androidx-wear-compose-foundation = { group = "androidx.wear.compose", name = "compose-foundation", version.ref = "wear-compose" }
androidx-wear-compose-material = { group = "androidx.wear.compose", name = "compose-material", version.ref = "wear-compose" }
androidx-wear-tiles = { group = "androidx.wear.tiles", name = "tiles", version.ref = "wear-tiles" }
play-services-wearable = { group = "com.google.android.gms", name = "play-services-wearable", version.ref = "play-services-wearable" }

# Health Connect
health-connect = { group = "androidx.health.connect", name = "connect-client", version.ref = "health-connect" }

# Firebase
firebase-bom = { group = "com.google.firebase", name = "firebase-bom", version.ref = "firebase-bom" }
firebase-analytics = { group = "com.google.firebase", name = "firebase-analytics-ktx" }
firebase-crashlytics = { group = "com.google.firebase", name = "firebase-crashlytics-ktx" }

# AdMob
play-services-ads = { group = "com.google.android.gms", name = "play-services-ads", version.ref = "play-services-ads" }

# Serialization
kotlinx-serialization-json = { group = "org.jetbrains.kotlinx", name = "kotlinx-serialization-json", version.ref = "kotlinx-serialization" }
kotlinx-datetime = { group = "org.jetbrains.kotlinx", name = "kotlinx-datetime", version.ref = "kotlinx-datetime" }

# Testing - JVM (src/test/)
junit5 = { group = "org.junit.jupiter", name = "junit-jupiter", version.ref = "junit5" }
turbine = { group = "app.cash.turbine", name = "turbine", version.ref = "turbine" }
mockk = { group = "io.mockk", name = "mockk", version.ref = "mockk" }
kotlinx-coroutines-test = { group = "org.jetbrains.kotlinx", name = "kotlinx-coroutines-test", version.ref = "coroutines-test" }

# Testing - Instrumented (src/androidTest/)
androidx-test-runner = { group = "androidx.test", name = "runner", version.ref = "androidx-test-runner" }
androidx-test-rules = { group = "androidx.test", name = "rules", version.ref = "androidx-test-rules" }
mockk-android = { group = "io.mockk", name = "mockk-android", version.ref = "mockk" }
hilt-android-testing = { group = "com.google.dagger", name = "hilt-android-testing", version.ref = "hilt" }
androidx-compose-ui-test = { group = "androidx.compose.ui", name = "ui-test-junit4" }
androidx-compose-ui-test-manifest = { group = "androidx.compose.ui", name = "ui-test-manifest" }

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
android-library = { id = "com.android.library", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
kotlin-serialization = { id = "org.jetbrains.kotlin.plugin.serialization", version.ref = "kotlin" }
ksp = { id = "com.google.devtools.ksp", version.ref = "ksp" }
hilt = { id = "com.google.dagger.hilt.android", version.ref = "hilt" }
# Kotlin 2.0: Compose 컴파일러 플러그인 (별도 버전 지정 불필요, kotlin 버전 사용)
compose-compiler = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
google-services = { id = "com.google.gms.google-services", version = "4.4.1" }
firebase-crashlytics = { id = "com.google.firebase.crashlytics", version = "2.9.9" }

# 참고: build.gradle.kts 적용 예시
# plugins {
#     alias(libs.plugins.kotlin.android)
#     alias(libs.plugins.compose.compiler)  // Kotlin 2.0 Compose 플러그인
# }

[bundles]
compose = [
    "androidx-compose-ui",
    "androidx-compose-ui-graphics",
    "androidx-compose-ui-tooling-preview",
    "androidx-compose-material3",
    "androidx-compose-material-icons"
]
compose-debug = [
    "androidx-compose-ui-tooling",
    "androidx-compose-ui-test-manifest"
]
lifecycle = [
    "androidx-lifecycle-runtime",
    "androidx-lifecycle-viewmodel-compose"
]
# JVM 테스트 (src/test/)
testing-jvm = [
    "junit5",
    "turbine",
    "mockk",
    "kotlinx-coroutines-test"
]

# Instrumented 테스트 (src/androidTest/)
testing-android = [
    "androidx-test-runner",
    "androidx-test-rules",
    "mockk-android",
    "androidx-compose-ui-test"
]
```

---

## 6. 진행 상황 로그

### 2026-01-20

**작업 내용:**
- [x] Android 프로젝트 계획 수립
- [x] TDD 가이드 문서 작성
- [x] iOS-Android 매핑 테이블 작성
- [x] 문서 구조 확정

**다음 작업:**
- Phase 1 시작: 프로젝트 초기 설정

---

### 템플릿 (복사해서 사용)

```markdown
### YYYY-MM-DD

**완료:**
- [ ] 

**진행 중:**
- [ ] 

**차단 사항:**
- 

**다음 작업:**
- 
```

---

## 부록

### A. 명령어 참조

```bash
# 빌드
./gradlew build

# 테스트 (전체)
./gradlew test

# 테스트 (모듈별)
./gradlew :app:test
./gradlew :widget:test
./gradlew :wear:test

# 커버리지 리포트
./gradlew koverHtmlReport

# 앱 설치
./gradlew :app:installDebug
./gradlew :wear:installDebug

# 린트
./gradlew lint

# 클린 빌드
./gradlew clean build
```

### B. 관련 문서 링크

- [TDD 가이드](./ANDROID_TDD_GUIDE.md)
- [iOS-Android 매핑](./IOS_ANDROID_MAPPING.md)
- [빌드 가이드](../README.md)
- [iOS 프로젝트 문서](../../ios/docs/IOS_PROJECT_DOCUMENTATION.md)
- [iOS 기술 명세](../../ios/docs/TECH_SPEC.md)
