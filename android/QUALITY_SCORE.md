# QUALITY_SCORE.md – 벌컥벌컥 Android

> Android/Wear OS 코드 품질 채점 기준

---

## 개요

이 문서는 벌컥벌컥 Android 프로젝트의 코드 품질을 일관되게 평가하기 위한 채점 기준입니다. 각 항목은 1~5점 척도로 평가하며, 가중치를 적용해 100점 만점으로 환산합니다.

---

## 채점 항목

### 1. 코드 구조 (가중치: 20%)

MVI 패턴 준수, 멀티 모듈 의존성 방향, clean architecture 레이어 분리를 평가합니다.

| 점수 | 기준 |
|------|------|
| 5 | MVI 패턴 완벽 적용. `:app` → `:core` 단방향 의존성 유지. domain/data/ui 레이어 명확히 분리. `:widget`, `:wear`, `:analytics` 모두 `:core`만 참조 |
| 4 | MVI 구조 대체로 준수. 의존성 방향 소수 예외 존재하나 실질적 영향 없음 |
| 3 | MVI 부분 적용. 일부 뷰에서 상태 관리 혼재. 모듈 간 의존성 불명확 |
| 2 | MVI 형식만 차용, 실질적 단방향 흐름 미적용. 모듈 경계 위반 다수 |
| 1 | 패턴 없음. 레이어 혼재. 스파게티 의존성 |

**프로젝트 기준:**
- `core/domain/` — 비즈니스 로직, 외부 의존성 없음
- `core/data/` — Repository 구현체, DataStore, Health Connect
- `app/ui/` — Composable 화면, ViewModel
- `settings.gradle.kts` — 모듈 등록 및 버전 카탈로그

---

### 2. Kotlin 관용구 (가중치: 15%)

Kotlin 2.0 기능 활용도, null safety, 타입 시스템 표현력을 평가합니다.

| 점수 | 기준 |
|------|------|
| 5 | Kotlin 2.0 기능 적극 활용. `sealed interface` + `when` 완전 처리. `data class` copy 패턴 일관. `?.let`, `?: run` 등 null 처리 관용적. `object` / `companion object` 적절 사용 |
| 4 | 대부분 관용적 Kotlin. 간헐적으로 Java 스타일 패턴 혼재 |
| 3 | `sealed class` 사용하나 `else` 브랜치 남발. nullable 처리 일관성 부족 |
| 2 | `!!` 연산자 빈번 사용. 타입 캐스팅 unsafe. `if-else` 체인으로 `when` 대체 |
| 1 | null 처리 부재. Java 스타일 전반. 타입 안전성 무시 |

---

### 3. Jetpack Compose (가중치: 15%)

Composable 설계 원칙, 상태 호이스팅, 리컴포지션 최적화를 평가합니다.

| 점수 | 기준 |
|------|------|
| 5 | 상태 호이스팅 일관 적용. `remember` / `derivedStateOf` 적재적소 사용. 불필요한 리컴포지션 없음. stateless Composable 중심 설계. `key()` 활용 목록 최적화 |
| 4 | 호이스팅 대체로 적용. 미세 최적화 기회 일부 존재하나 성능 무관 |
| 3 | 상태를 Composable 내부에서 직접 관리하는 경우 다수. `derivedStateOf` 미사용 |
| 2 | ViewModel 직접 주입 남발. 리컴포지션 범위 과도. `LaunchedEffect` 오용 |
| 1 | 상태 관리 원칙 없음. Composable 내 사이드이펙트 무분별 |

---

### 4. Hilt DI (가중치: 10%)

모듈 구조의 명확성, 스코프 적절성, 테스트 가능성을 평가합니다.

| 점수 | 기준 |
|------|------|
| 5 | `@Singleton` / `@ViewModelScoped` / `@ActivityScoped` 역할별 정확 적용. 모듈 분리 명확 (NetworkModule, DataModule, DomainModule 등). 테스트 시 `@TestInstallIn`으로 대체 가능 |
| 4 | 스코프 대체로 적절. 모듈 몇 개 통합되어 있으나 관리 가능 수준 |
| 3 | `@Singleton` 과다 사용. 모듈 경계 불명확 |
| 2 | DI 구조 있으나 수동 인스턴스화 혼재. 테스트 격리 불가 |
| 1 | Hilt 형식만 차용, 실질적 의존성 주입 원칙 미적용 |

---

### 5. 비동기 처리 (가중치: 15%)

Coroutines + Flow 활용, 에러 처리 일관성, 생명주기 안전성을 평가합니다.

| 점수 | 기준 |
|------|------|
| 5 | `StateFlow` / `SharedFlow` 목적별 구분. `viewModelScope` 내 코루틴 안전 관리. `Result<T>` 또는 sealed class로 에러 전파. `catch` / `onEach` 체인 일관. `Dispatchers` 명시적 사용 |
| 4 | Flow 활용 적절. 에러 처리 일부 누락되나 크래시 위험 낮음 |
| 3 | `StateFlow` 사용하나 에러 상태 미정의. `GlobalScope` 간헐 사용 |
| 2 | 콜백과 Flow 혼재. 생명주기 누수 가능성. 예외 전파 불명확 |
| 1 | `runBlocking` 남용. 에러 무시. 메인 스레드 블로킹 |

---

### 6. Glance 위젯 (가중치: 10%)

`GlanceAppWidget` 구조, 데이터 갱신 전략, `ActionCallback` 보안을 평가합니다.

| 점수 | 기준 |
|------|------|
| 5 | `GlanceAppWidget` + `GlanceAppWidgetReceiver` 명확히 분리. `updateAll` / `WorkManager` 기반 갱신 전략. `ActionCallback`에서 민감 데이터 미노출. Glance 컴포넌트 재사용성 고려 |
| 4 | 위젯 구조 적절. 갱신 주기 합리적. 소소한 최적화 여지 |
| 3 | 데이터 갱신이 비효율적 (과도한 polling 등). ActionCallback 검증 부족 |
| 2 | 위젯에서 직접 DB 접근. 에러 시 빈 화면 처리 없음 |
| 1 | Glance API 오용. 위젯 갱신 전략 없음 |

---

### 7. Wear OS (가중치: 10%)

Tile/Complication 구현 품질, DataLayer 동기화, Wear Compose 활용을 평가합니다.

| 점수 | 기준 |
|------|------|
| 5 | `TileService` + `SuspendingTileService` 적절 사용. `DataClient` / `MessageClient` 통한 폰↔워치 동기화 명확. Wear Compose 컴포넌트 (ScalingLazyColumn 등) 올바른 사용. 배터리 효율 고려 |
| 4 | DataLayer 동기화 동작 정상. Wear Compose 대체로 올바름. 일부 비효율 존재 |
| 3 | DataLayer 사용하나 동기화 타이밍 불명확. 폰 UI 컴포넌트 wear에 직접 재사용 |
| 2 | DataLayer 무시하고 독립 데이터 관리. Wear 최적화 전혀 없음 |
| 1 | Wear OS 특성 무시. 폰 앱 그대로 이식 수준 |

---

### 8. 테스트 (가중치: 15%)

테스트 커버리지, TDD 원칙 준수, 테스트 구조 품질을 평가합니다.

| 점수 | 기준 |
|------|------|
| 5 | JUnit5 + MockK + Turbine 조합 일관 사용. 모듈별 커버리지 80% 이상. UseCase / Repository 단위 테스트 완비. TDD 사이클 흔적 (실패 테스트 먼저). Fake 구현체로 통합 테스트 격리 |
| 4 | 핵심 로직 테스트 완비. 커버리지 60~79%. 일부 Fake 대신 Mock 과다 사용 |
| 3 | 테스트 존재하나 happy path만 검증. 에러/엣지 케이스 미비 |
| 2 | 테스트 코드 있으나 실질적 검증 없는 형식적 테스트 다수 |
| 1 | 테스트 없거나 컴파일 불가 상태 |

---

## 가중치 및 총점 계산

| 항목 | 가중치 | 최대 점수 |
|------|--------|-----------|
| 코드 구조 | 20% | 20점 |
| Kotlin 관용구 | 15% | 15점 |
| Jetpack Compose | 15% | 15점 |
| Hilt DI | 10% | 10점 |
| 비동기 처리 | 15% | 15점 |
| Glance 위젯 | 10% | 10점 |
| Wear OS | 10% | 10점 |
| 테스트 | 15% | 15점 |
| **합계** | **100%** | **100점** |

**환산 공식:** `총점 = Σ (항목 점수 / 5) × 가중치 × 100`

### 등급 기준

| 등급 | 점수 | 의미 |
|------|------|------|
| S | 90~100 | 출시 준비 완료. 벤치마크 수준 |
| A | 80~89 | 프로덕션 품질. 소소한 개선 여지 |
| B | 65~79 | 동작하나 리팩터링 필요 |
| C | 50~64 | 기술 부채 누적. 점진적 개선 필요 |
| D | 50 미만 | 구조적 재작업 필요 |

---

## 자가 점검 체크리스트

### 코드 구조

- [ ] `:core` 모듈이 `:app`에 의존하지 않는다
- [ ] `core/domain/`에 Android 프레임워크 import 없다
- [ ] ViewModel이 Repository를 직접 참조하지 않고 UseCase를 통한다
- [ ] `settings.gradle.kts`에 모든 모듈이 등록되어 있다
- [ ] `app/ui/`에 비즈니스 로직이 없다

### Kotlin 관용구

- [ ] `!!` 연산자 사용 없다 (또는 최소화하고 주석 있다)
- [ ] `sealed interface` + `when`에서 `else` 브랜치 없다
- [ ] `data class`의 `copy()` 활용해 불변 상태 갱신한다
- [ ] `typealias` 활용해 복잡한 람다 타입 명명했다
- [ ] `inline` / `reified` 적절히 활용한다

### Jetpack Compose

- [ ] Composable 함수가 상태를 직접 소유하지 않는다 (stateless 원칙)
- [ ] `remember { derivedStateOf { ... } }` 계산 프로퍼티에 사용한다
- [ ] 목록 아이템에 안정적인 `key`를 제공한다
- [ ] `@Stable` / `@Immutable` 어노테이션 필요한 곳에 적용했다
- [ ] Preview가 각 Composable에 존재한다

### Hilt DI

- [ ] `@HiltViewModel` 적용된 ViewModel만 Hilt로 주입한다
- [ ] `@Singleton`은 앱 전역 단일 인스턴스에만 사용한다
- [ ] 테스트 모듈 (`@TestInstallIn`) 준비되어 있다
- [ ] 모듈 클래스가 역할별로 분리되어 있다

### 비동기 처리

- [ ] `GlobalScope` 사용 없다
- [ ] `StateFlow`의 초기값이 적절하다
- [ ] `viewModelScope.launch` 내에서 예외 처리 (`try-catch` 또는 `CoroutineExceptionHandler`)한다
- [ ] Flow 에러를 `catch` 연산자로 처리한다
- [ ] `Dispatchers.Main` 대신 `Dispatchers.Main.immediate` 고려했다

### Glance 위젯

- [ ] 위젯 UI 갱신이 WorkManager 또는 `updateAll()`로 트리거된다
- [ ] 위젯에서 DB를 직접 쿼리하지 않는다
- [ ] `ActionCallback`에서 사용자 식별 정보를 노출하지 않는다

### Wear OS

- [ ] DataLayer 메시지/데이터 경로가 상수로 정의되어 있다
- [ ] 폰 앱 Composable을 wear에서 재사용하지 않는다
- [ ] 배터리 영향을 최소화하는 갱신 전략을 사용한다

### 테스트

- [ ] 모든 UseCase에 단위 테스트 존재한다
- [ ] Repository 테스트가 Fake DataSource로 격리되어 있다
- [ ] `Turbine`으로 Flow 방출 순서를 검증한다
- [ ] 실패 케이스 (에러, 빈 상태) 테스트가 있다
- [ ] 테스트 이름이 `given_when_then` 또는 한국어 설명 형식이다

---

*이 문서는 코드 리뷰 및 PR 체크리스트로 활용합니다. 점수보다 체크리스트 항목 준수가 우선입니다.*
