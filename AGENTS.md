# AGENTS.md – DrinkSomeWater (벌컥벌컥)

> AI 에이전트가 프로젝트 구조를 빠르게 파악하기 위한 진입점(ToC/맵).

---

## 빠른 참조

| 항목 | 내용 |
|------|------|
| 앱 이름 | 벌컥벌컥 (Gulp) / DrinkSomeWater |
| 언어 | Swift 6 (iOS), Kotlin (Android) |
| UI | SwiftUI + UIKit (iOS), Jetpack Compose (Android) |
| 아키텍처 | @Observable Store Pattern (iOS), MVI ViewModel (Android) |
| 빌드 | Tuist (iOS), Gradle KTS (Android) |
| 최소 지원 | iOS 18+, watchOS 11+ |
| 주요 퍼미션 | HealthKit, UserNotifications, iCloud |

---

## 디렉터리 맵

```
DrinkSomeWater/
├── ios/                    # iOS/watchOS 앱
│   ├── DrinkSomeWater/     # 메인 앱 타겟
│   ├── DrinkSomeWaterWidget/ # 위젯 익스텐션
│   ├── DrinkSomeWaterWatch/  # watchOS 앱
│   ├── Analytics/          # 분석 프레임워크
│   ├── Shared/             # 위젯/앱 공유 헬퍼
│   ├── DrinkSomeWaterTests/
│   ├── DrinkSomeWaterSnapshotTests/
│   └── docs/               # iOS 전용 문서
├── android/                # Android/Wear OS 앱
│   ├── app/                # 메인 폰 앱
│   ├── core/               # 공유 domain/data 레이어
│   ├── widget/             # 홈 화면 위젯
│   ├── wear/               # Wear OS 앱
│   ├── analytics/          # 분석 모듈
│   └── docs/               # Android 전용 문서
├── docs/                   # 상세 지식 저장소
│   ├── references/         # 외부 레퍼런스
│   ├── design-docs/        # 설계 문서 (계획됨)
│   ├── product-specs/      # 수용 기준 (계획됨)
│   └── exec-plans/         # 실행 계획 (계획됨)
├── .github/workflows/      # CI/CD
├── AGENTS.md               # ← 이 파일
├── ARCHITECTURE.md
├── QUALITY_SCORE.md
├── SECURITY.md
└── README.md
```

---

## 주요 문서

| 문서 | 경로 | 설명 |
|------|------|------|
| 최상위 구조 | `ARCHITECTURE.md` | 전체 아키텍처 설명 |
| 품질 루브릭 | `QUALITY_SCORE.md` | 코드 품질 기준 |
| 보안 규칙 | `SECURITY.md` | 보안 정책 및 규칙 |
| Analytics 이벤트 | `docs/ANALYTICS.md` | Firebase Analytics 이벤트 정의 |
| App Store 설정 | `docs/APP_STORE_CONNECT_SETUP.md` | App Store Connect 설정 가이드 |
| iOS 상세 문서 | `ios/docs/IOS_PROJECT_DOCUMENTATION.md` | iOS 프로젝트 전반 문서 |
| iOS 기술 스펙 | `ios/docs/TECH_SPEC.md` | iOS 기술 명세 |
| 마이그레이션 로그 | `ios/docs/MIGRATION_LOG.md` | iOS 마이그레이션 이력 |
| Android 개요 | `android/README.md` | Android 프로젝트 개요 |
| Android 프로젝트 계획 | `android/docs/ANDROID_PROJECT_PLAN.md` | Android 개발 계획 |
| Android TDD 가이드 | `android/docs/ANDROID_TDD_GUIDE.md` | Android 테스트 주도 개발 가이드 |
| iOS-Android 매핑 | `android/docs/IOS_ANDROID_MAPPING.md` | iOS/Android 기능 대응표 |
| Play Store 리스팅 | `android/docs/PLAY_STORE_LISTING.md` | Play Store 등록 정보 |
| 릴리즈 가이드 | `android/docs/RELEASE_GUIDE.md` | Android 릴리즈 절차 |

---

## 컨벤션 요약

- **네이밍**: Swift API Design Guidelines 준수
- **브랜치**: `feature/*`, `fix/*`, `docs/*`
- **커밋**: Conventional Commits 형식
- **iOS 빌드**: `tuist install && tuist generate`
- **Android 빌드**: `./gradlew build`

---

*이 파일은 에이전트 진입점입니다. 상세 설계는 각 링크 문서를 확인하세요.*
