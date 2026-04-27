# AGENTS.md – 벌컥벌컥 iOS

> iOS/watchOS 플랫폼 에이전트 진입점(ToC/맵).

---

## 빠른 참조

| 항목 | 내용 |
|------|------|
| 앱 이름 | 벌컥벌컥 (Gulp) |
| 언어 | Swift 6 |
| UI | SwiftUI + UIKit |
| 아키텍처 | @Observable Store Pattern (ReactorKit 영감) |
| 빌드 | Tuist (`tuist install && tuist generate`) |
| 최소 지원 | iOS 18+, watchOS 11+ |
| 주요 퍼미션 | HealthKit, UserNotifications, iCloud |
| 외부 의존성 | Firebase Analytics, Google AdMob, SnapKit, FSCalendar |

---

## 디렉터리 맵

```
ios/
├── DrinkSomeWater/          # 메인 앱 타겟
│   ├── Sources/
│   │   ├── Models/          # 데이터 모델
│   │   ├── Services/        # 비즈니스 서비스
│   │   ├── Stores/          # @Observable Store
│   │   ├── Views/           # SwiftUI 뷰
│   │   ├── ViewController/  # UIKit 뷰컨트롤러
│   │   ├── ViewComponent/   # 재사용 UI 컴포넌트
│   │   ├── DesignSystem/    # 디자인 토큰
│   │   └── StaticComponent/ # 정적 데이터
│   ├── Resources/           # Assets, Localizable
│   └── Support/             # Info.plist, Entitlements
├── DrinkSomeWaterWidget/    # 위젯 익스텐션
├── DrinkSomeWaterWatch/     # watchOS 앱
├── Analytics/               # 분석 프레임워크
├── Shared/                  # WidgetDataManager
├── DrinkSomeWaterTests/     # 유닛 테스트
├── DrinkSomeWaterSnapshotTests/ # 스냅샷 테스트
├── docs/                    # iOS 전용 문서
├── Project.swift            # Tuist 프로젝트 정의
└── .swiftlint.yml           # SwiftLint 설정
```

---

## 주요 문서

| 문서 | 경로 | 설명 |
|------|------|------|
| iOS 아키텍처 | `ios/ARCHITECTURE.md` | iOS 아키텍처 상세 |
| 품질 루브릭 | `ios/QUALITY_SCORE.md` | iOS 품질 루브릭 |
| 보안 규칙 | `ios/SECURITY.md` | iOS 보안 규칙 |
| 프로젝트 상세 | `ios/docs/IOS_PROJECT_DOCUMENTATION.md` | 프로젝트 상세 문서 |
| 기술 스펙 | `ios/docs/TECH_SPEC.md` | 기술 스펙 |
| 마이그레이션 로그 | `ios/docs/MIGRATION_LOG.md` | 마이그레이션 로그 |
| UI 카탈로그 | `ios/UI_CATALOG.md` | UI 카탈로그 |

---

## 컨벤션

- **네이밍**: Swift API Design Guidelines
- **빌드**: `tuist install && tuist generate`
- **테스트**: `tuist test`
- **Lint**: SwiftLint (`.swiftlint.yml`)

---

*상세 설계는 docs/ 하위 문서를 확인하세요.*
