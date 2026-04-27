# AGENTS.md – 벌컥벌컥 Android

> Android/Wear OS 플랫폼 에이전트 진입점(ToC/맵).

---

## 빠른 참조

| 항목 | 내용 |
|------|------|
| 앱 이름 | 벌컥벌컥 (Gulp) |
| 언어 | Kotlin 2.0 |
| UI | Jetpack Compose |
| 아키텍처 | MVI (ViewModel + StateFlow) |
| DI | Hilt |
| 비동기 | Coroutines + Flow |
| 저장소 | DataStore Preferences |
| 빌드 | Gradle KTS + Version Catalog |
| 최소 지원 | Android 10+ (API 29), Wear OS 3+ |
| 주요 퍼미션 | Health Connect, Notifications |

---

## 디렉터리 맵

```
android/
├── app/                    # 메인 폰 앱
│   └── src/main/java/.../
│       ├── ui/             # Home, History, Settings, Onboarding
│       ├── service/        # Notifications, Ads, Health
│       └── di/             # Hilt 모듈
├── core/                   # 공유 domain/data
│   └── src/main/java/.../
│       ├── domain/         # 모델, Repository 인터페이스
│       └── data/           # DataStore, Repository 구현
├── widget/                 # Glance 위젯
│   └── src/main/java/.../
│       ├── ui/             # 위젯 렌더링
│       ├── data/           # 위젯 데이터
│       └── action/         # 위젯 액션
├── wear/                   # Wear OS 앱
│   └── src/main/java/.../
│       ├── ui/             # Wear UI
│       ├── tile/           # 타일 서비스
│       ├── complication/   # 컴플리케이션
│       ├── sync/           # 데이터 동기화
│       └── di/             # Hilt 모듈
├── analytics/              # 분석 모듈
├── docs/                   # Android 전용 문서
├── gradle/libs.versions.toml # 버전 카탈로그
└── settings.gradle.kts     # 모듈 설정
```

---

## 주요 문서

| 문서 | 경로 | 설명 |
|------|------|------|
| Android 아키텍처 상세 | `android/ARCHITECTURE.md` | Android 아키텍처 상세 |
| Android 품질 루브릭 | `android/QUALITY_SCORE.md` | Android 품질 루브릭 |
| Android 보안 규칙 | `android/SECURITY.md` | Android 보안 규칙 |
| Android 개요 및 빌드 | `android/README.md` | Android 개요 및 빌드 |
| 프로젝트 계획서 | `android/docs/ANDROID_PROJECT_PLAN.md` | 프로젝트 계획서 |
| TDD 가이드 | `android/docs/ANDROID_TDD_GUIDE.md` | TDD 가이드 |
| iOS-Android 매핑 | `android/docs/IOS_ANDROID_MAPPING.md` | iOS-Android 매핑 |
| 스토어 등록 정보 | `android/docs/PLAY_STORE_LISTING.md` | 스토어 등록 정보 |
| 릴리즈 가이드 | `android/docs/RELEASE_GUIDE.md` | 릴리즈 가이드 |

---

## 컨벤션 요약

- **빌드**: `./gradlew build`
- **테스트**: `./gradlew test`
- **앱 설치**: `./gradlew :app:installDebug`
- **모듈 의존성**: `app`, `widget`, `wear` → `:core`

---

*상세 설계는 docs/ 하위 문서를 확인하세요.*
