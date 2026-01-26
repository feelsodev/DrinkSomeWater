# Instagram Sharing Feature for DrinkSomeWater

## Context

### Original Request
iOS 프로젝트에 물을 마시는 기록에 대해서 Instagram 스토리 및 게시물을 작성하는 기능을 만들어줘

### Interview Summary
**Key Discussions**:
- 공유 위치: HomeView (오늘 기록) + HistoryView (선택한 날짜 기록)
- 이미지 디자인: 새로운 공유 카드 생성 (Instagram 최적화, 미니멀 스타일)
- 카드 콘텐츠: 섭취량/목표량, 달성 퍼센트, 연속 달성 일수, 앱 로고/브랜딩
- Facebook App ID: 없음 (설정 가이드 제공)
- 테스트: 구현 후 테스트 추가
- 공유 버튼: 아이콘만 (SF Symbol)
- 에러 처리: Instagram 미설치 시 단순 알림
- 공유 대상: Stories + Feed (선택 옵션 제공)

**Research Findings**:
- iOS Deployment Target: 26.0 (ImageRenderer 사용 가능)
- 아키텍처: @Observable Store Pattern
- 테스트 프레임워크: Swift Testing
- 디자인 시스템: DesignTokens.swift (DS.Color, DS.Font)
- Instagram Stories: UIPasteboard + URL Scheme
- Instagram Feed: Photo Library 저장 후 Instagram 앱 열기

### Metis Review
**Identified Gaps** (addressed):
- UI 배치 불명확 → 아이콘만 버튼으로 결정
- 에러 처리 미정의 → 단순 알림으로 결정
- Stories vs Feed 선택 → 둘 다 지원, 선택 옵션 제공
- Facebook App ID 필요 → 가이드 문서 포함

---

## Work Objectives

### Core Objective
Instagram Stories 및 Feed에 물 섭취 기록을 공유할 수 있는 기능을 구현한다.

### Concrete Deliverables
- `InstagramSharingService.swift` - Instagram 공유 로직
- `ShareCardView.swift` - 공유용 카드 UI (Stories 1080x1920, Feed 1080x1080)
- `HomeView.swift` 수정 - 공유 버튼 추가
- `HistoryView.swift` 수정 - 공유 버튼 추가
- `Project.swift` 수정 - LSApplicationQueriesSchemes 추가
- `AnalyticsEvent.swift` 수정 - 공유 이벤트 추가
- `InstagramSharingServiceTests.swift` - 유닛 테스트
- `FACEBOOK_APP_ID_SETUP.md` - Facebook App ID 설정 가이드

### Definition of Done
- [ ] HomeView에서 오늘 기록을 Instagram Stories/Feed로 공유 가능
- [ ] HistoryView에서 선택한 날짜 기록을 Instagram Stories/Feed로 공유 가능
- [ ] Instagram 미설치 시 알림 표시
- [ ] 공유 카드에 섭취량, 목표량, 퍼센트, streak, 로고 표시
- [ ] Stories (1080x1920), Feed (1080x1080) 이미지 생성
- [ ] Analytics 이벤트 기록
- [ ] 유닛 테스트 통과

### Must Have
- Instagram Stories 공유 기능
- Instagram Feed 공유 기능 (Photo Library 저장 방식)
- Stories/Feed 선택 옵션 (ActionSheet)
- 미니멀 디자인 공유 카드 (기존 디자인 토큰 사용)
- Instagram 미설치 시 에러 처리
- Analytics 이벤트 추적

### Must NOT Have (Guardrails)
- watchOS 공유 기능 추가 금지
- Widget 공유 버튼 추가 금지
- 다른 SNS (Twitter, KakaoTalk, Facebook) 지원 금지
- 공유 미리보기 화면 추가 금지
- 이미지 커스터마이징 옵션 (배경색, 스티커 등) 금지
- 외부 라이브러리/패키지 추가 금지
- WaterRecord 모델 수정 금지
- 하드코딩된 색상/폰트 사용 금지 (DesignTokens 사용)

---

## Verification Strategy (MANDATORY)

### Test Decision
- **Infrastructure exists**: YES (Swift Testing framework)
- **User wants tests**: YES (구현 후 테스트)
- **Framework**: Swift Testing

### Test Structure
각 TODO 완료 후:
1. 수동 검증 먼저 수행
2. 테스트 코드 작성 (Task 10에서 일괄 작성)

### Manual Execution Verification
각 Task별 수동 검증 절차 포함

---

## Task Flow

```
Task 1 (Info.plist) 
    ↓
Task 2 (ShareCardView)
    ↓
Task 3 (InstagramSharingService)
    ↓
Task 4 (HomeView 공유 버튼) ←──┐
    ↓                         │ 병렬 가능
Task 5 (HistoryView 공유 버튼) ←┘
    ↓
Task 6 (Analytics 이벤트)
    ↓
Task 7 (에러 처리 개선)
    ↓
Task 8 (테스트 작성)
    ↓
Task 9 (Facebook App ID 가이드)
```

## Parallelization

| Group | Tasks | Reason |
|-------|-------|--------|
| A | 4, 5 | HomeView, HistoryView 독립적 수정 |

| Task | Depends On | Reason |
|------|------------|--------|
| 2 | 1 | URL Scheme 설정 후 카드 개발 |
| 3 | 2 | 카드 뷰 완성 후 서비스 개발 |
| 4, 5 | 3 | 서비스 완성 후 UI 통합 |
| 6 | 4, 5 | UI 통합 후 Analytics 추가 |
| 7 | 6 | 기본 플로우 완성 후 에러 처리 |
| 8 | 7 | 전체 기능 완성 후 테스트 |
| 9 | - | 독립적, 언제든 가능 |

---

## TODOs

- [x] 1. Info.plist에 LSApplicationQueriesSchemes 추가

  **What to do**:
  - Project.swift의 infoPlist 섹션에 LSApplicationQueriesSchemes 추가
  - `instagram-stories`, `instagram` URL scheme 등록

  **Must NOT do**:
  - Info.plist 파일 직접 수정 (Tuist 사용)
  - 불필요한 URL scheme 추가

  **Parallelizable**: NO (첫 번째 태스크)

  **References**:
  - `ios/Project.swift:33-115` - infoPlist 설정 패턴 (extendingDefault 사용법)
  - Instagram API 문서: LSApplicationQueriesSchemes에 `instagram-stories`, `instagram` 필요

  **Acceptance Criteria**:
  - [ ] Project.swift에 LSApplicationQueriesSchemes 배열 추가됨
  - [ ] `instagram-stories`, `instagram` 두 개의 scheme 등록됨
  
  **Manual Verification**:
  - [ ] `tuist generate` 실행 → 성공
  - [ ] 생성된 xcodeproj의 Info.plist 확인 → LSApplicationQueriesSchemes 포함

  **Commit**: YES
  - Message: `feat(sharing): add Instagram URL schemes to Info.plist`
  - Files: `ios/Project.swift`

---

- [x] 2. ShareCardView 생성 (공유용 카드 UI)

  **What to do**:
  - `ios/DrinkSomeWater/Sources/Views/ShareCardView.swift` 생성
  - Stories용 (1080x1920, 9:16) 및 Feed용 (1080x1080, 1:1) 레이아웃
  - 표시 내용: 섭취량(ml), 목표량(ml), 달성 퍼센트, 연속 달성 일수, 앱 로고
  - 미니멀 디자인, DesignTokens 사용
  - Light/Dark mode 모두 지원 (배경은 앱 primary color 계열)

  **Must NOT do**:
  - 하드코딩된 색상/폰트 사용
  - 애니메이션 추가
  - 사용자 커스터마이징 옵션

  **Parallelizable**: NO (Task 1 완료 후)

  **References**:
  - `ios/DrinkSomeWater/Sources/DesignSystem/DesignTokens.swift` - DS.Color, DS.SwiftUIFont 사용
  - `ios/DrinkSomeWater/Sources/Views/HomeView.swift:109-130` - messageCard 디자인 패턴 참고
  - `ios/DrinkSomeWater/Sources/Views/HistoryView.swift:421-485` - RecordCard 디자인 패턴 참고
  - `ios/DrinkSomeWater/Sources/Models/WaterRecord.swift` - WaterRecord 모델 구조
  - Instagram Stories 최적 크기: 1080x1920 (9:16)
  - Instagram Feed 최적 크기: 1080x1080 (1:1)

  **Acceptance Criteria**:
  - [ ] ShareCardView.swift 파일 생성됨
  - [ ] `enum ShareCardStyle { case stories, feed }` 정의됨
  - [ ] stories: 1080x1920 비율, feed: 1080x1080 비율 레이아웃
  - [ ] 섭취량, 목표량, 퍼센트, streak, 로고 표시
  - [ ] DS.Color, DS.SwiftUIFont만 사용 (하드코딩 없음)
  
  **Manual Verification**:
  - [ ] Xcode Preview에서 ShareCardView 렌더링 확인
  - [ ] Stories 스타일: 세로 긴 형태 확인
  - [ ] Feed 스타일: 정사각형 형태 확인
  - [ ] 0%, 50%, 100%, 150% 달성률 모두 정상 표시 확인

  **Commit**: YES
  - Message: `feat(sharing): add ShareCardView for Instagram sharing`
  - Files: `ios/DrinkSomeWater/Sources/Views/ShareCardView.swift`

---

- [x] 3. InstagramSharingService 생성

  **What to do**:
  - `ios/DrinkSomeWater/Sources/Services/InstagramSharingService.swift` 생성
  - ShareCardView를 UIImage로 렌더링 (ImageRenderer 사용)
  - Instagram Stories 공유: UIPasteboard + URL scheme
  - Instagram Feed 공유: Photo Library 저장 + Instagram 앱 열기
  - ServiceProviderProtocol에 추가
  - Instagram 설치 여부 확인 메서드

  **Must NOT do**:
  - 외부 라이브러리 사용
  - Facebook SDK 통합
  - 동기 blocking 코드

  **Parallelizable**: NO (Task 2 완료 후)

  **References**:
  - `ios/DrinkSomeWater/Sources/Services/ServiceProvider.swift` - 서비스 등록 패턴
  - `ios/DrinkSomeWater/Sources/Services/WaterService.swift` - 서비스 구조 패턴 (async/await)
  - Instagram Stories API: UIPasteboard에 `com.instagram.sharedSticker.backgroundImage` 키로 이미지 저장
  - URL Scheme: `instagram-stories://share?source_application={appId}`
  - Feed 공유: `instagram://library?LocalIdentifier={assetId}`
  - ImageRenderer: iOS 16+ SwiftUI → UIImage 변환

  **Acceptance Criteria**:
  - [ ] InstagramSharingService.swift 생성됨
  - [ ] `func isInstagramInstalled() -> Bool` 구현
  - [ ] `func shareToStories(record: WaterRecord, streak: Int) async throws` 구현
  - [ ] `func shareToFeed(record: WaterRecord, streak: Int) async throws` 구현
  - [ ] ServiceProvider에 instagramSharingService 프로퍼티 추가
  - [ ] @MainActor 적용 (UI 렌더링 필요)
  
  **Manual Verification**:
  - [ ] 시뮬레이터에서 `isInstagramInstalled()` 호출 → false 반환
  - [ ] 실제 기기에서 Instagram 설치 후 → true 반환
  - [ ] ShareCardView → UIImage 변환 성공 확인 (로그 또는 브레이크포인트)

  **Commit**: YES
  - Message: `feat(sharing): add InstagramSharingService with Stories and Feed support`
  - Files: `ios/DrinkSomeWater/Sources/Services/InstagramSharingService.swift`, `ios/DrinkSomeWater/Sources/Services/ServiceProvider.swift`

---

- [x] 4. HomeView에 공유 버튼 추가

  **What to do**:
  - HomeView에 공유 버튼 추가 (SF Symbol: `square.and.arrow.up`)
  - headerSection 영역에 배치 (목표량 옆)
  - 탭 시 ActionSheet 표시: "Instagram Stories로 공유" / "Instagram Feed로 공유"
  - HomeStore에 streak 계산 로직 공개 (현재 private)
  - 공유 실행 시 InstagramSharingService 호출

  **Must NOT do**:
  - 복잡한 UI 추가
  - 공유 미리보기 화면
  - 텍스트 레이블 추가 (아이콘만)

  **Parallelizable**: YES (Task 5와 병렬 가능)

  **References**:
  - `ios/DrinkSomeWater/Sources/Views/HomeView.swift:78-107` - headerSection 구조
  - `ios/DrinkSomeWater/Sources/Stores/HomeStore.swift:96-114` - calculateStreak() 메서드 (private → internal로 변경 필요)
  - `ios/DrinkSomeWater/Sources/Views/HomeView.swift:247-252` - Button 스타일 패턴

  **Acceptance Criteria**:
  - [ ] HomeView headerSection에 공유 버튼 표시됨
  - [ ] 공유 버튼은 `square.and.arrow.up` SF Symbol 사용
  - [ ] 버튼 탭 시 ActionSheet 표시 (Stories/Feed 선택)
  - [ ] HomeStore.calculateStreak()이 internal로 변경됨
  - [ ] Stories 선택 시 → InstagramSharingService.shareToStories 호출
  - [ ] Feed 선택 시 → InstagramSharingService.shareToFeed 호출
  
  **Manual Verification**:
  - [ ] 앱 실행 → HomeView에 공유 버튼 표시됨
  - [ ] 버튼 탭 → ActionSheet 표시됨
  - [ ] "Instagram Stories로 공유" 옵션 표시됨
  - [ ] "Instagram Feed로 공유" 옵션 표시됨
  - [ ] (Instagram 설치된 기기) Stories 선택 → Instagram Stories 편집 화면 열림

  **Commit**: YES
  - Message: `feat(sharing): add Instagram share button to HomeView`
  - Files: `ios/DrinkSomeWater/Sources/Views/HomeView.swift`, `ios/DrinkSomeWater/Sources/Stores/HomeStore.swift`

---

- [x] 5. HistoryView에 공유 버튼 추가

  **What to do**:
  - RecordCard 컴포넌트에 공유 버튼 추가
  - selectedRecord가 있을 때만 공유 버튼 활성화
  - 탭 시 ActionSheet 표시
  - 해당 날짜 기준 streak 계산 필요 (HistoryStore에 메서드 추가)

  **Must NOT do**:
  - HistoryView 전체 레이아웃 변경
  - 다중 선택 공유
  - 공유 미리보기

  **Parallelizable**: YES (Task 4와 병렬 가능)

  **References**:
  - `ios/DrinkSomeWater/Sources/Views/HistoryView.swift:421-485` - RecordCard 컴포넌트
  - `ios/DrinkSomeWater/Sources/Stores/HistoryStore.swift` - HistoryStore 구조
  - `ios/DrinkSomeWater/Sources/Stores/HomeStore.swift:96-114` - streak 계산 로직 참고

  **Acceptance Criteria**:
  - [ ] RecordCard에 공유 버튼 추가됨
  - [ ] 버튼 탭 시 ActionSheet 표시
  - [ ] HistoryStore에 `calculateStreakForDate(_ date: Date) -> Int` 메서드 추가
  - [ ] 선택한 날짜 기준 streak 계산 후 공유
  
  **Manual Verification**:
  - [ ] HistoryView → 캘린더에서 날짜 선택
  - [ ] RecordCard 표시됨 + 공유 버튼 표시됨
  - [ ] 공유 버튼 탭 → ActionSheet 표시됨
  - [ ] Stories 선택 → 해당 날짜 기록으로 카드 생성됨

  **Commit**: YES
  - Message: `feat(sharing): add Instagram share button to HistoryView RecordCard`
  - Files: `ios/DrinkSomeWater/Sources/Views/HistoryView.swift`, `ios/DrinkSomeWater/Sources/Stores/HistoryStore.swift`

---

- [ ] 6. Analytics 이벤트 추가

  **What to do**:
  - AnalyticsEvent에 공유 관련 이벤트 추가
  - `instagramShareInitiated(destination: ShareDestination, source: ShareSource)`
  - `instagramShareCompleted(destination: ShareDestination, source: ShareSource)`
  - `instagramShareFailed(destination: ShareDestination, reason: String)`
  - 공유 플로우에서 Analytics 호출

  **Must NOT do**:
  - 개인정보 포함 이벤트 (섭취량 등 민감 데이터)
  - 과도한 이벤트 추가

  **Parallelizable**: NO (Task 4, 5 완료 후)

  **References**:
  - `ios/Analytics/Sources/AnalyticsEvent.swift` - 이벤트 정의 패턴
  - `ios/Analytics/Sources/Analytics.swift` - Analytics.shared.log() 사용법
  - `ios/DrinkSomeWater/Sources/Stores/HomeStore.swift:57` - Analytics 사용 예시

  **Acceptance Criteria**:
  - [ ] AnalyticsEvent에 `instagramShareInitiated`, `instagramShareCompleted`, `instagramShareFailed` 추가
  - [ ] `ShareDestination` enum: `.stories`, `.feed`
  - [ ] `ShareSource` enum: `.home`, `.history`
  - [ ] 공유 시작, 완료, 실패 시점에 Analytics 이벤트 기록
  
  **Manual Verification**:
  - [ ] 공유 버튼 탭 → Firebase Debug View에서 `instagram_share_initiated` 이벤트 확인
  - [ ] 공유 완료 → `instagram_share_completed` 이벤트 확인
  - [ ] Instagram 미설치 시 → `instagram_share_failed` 이벤트 확인

  **Commit**: YES
  - Message: `feat(analytics): add Instagram sharing analytics events`
  - Files: `ios/Analytics/Sources/AnalyticsEvent.swift`, `ios/DrinkSomeWater/Sources/Views/HomeView.swift`, `ios/DrinkSomeWater/Sources/Views/HistoryView.swift`

---

- [ ] 7. 에러 처리 개선

  **What to do**:
  - Instagram 미설치 시 알림 표시 (AlertService 사용)
  - Photo Library 권한 요청 (Feed 공유 시)
  - 이미지 생성 실패 시 에러 처리
  - 사용자 친화적 에러 메시지 (Localizable)

  **Must NOT do**:
  - App Store 링크 제공 (단순 알림만)
  - 복잡한 에러 복구 로직

  **Parallelizable**: NO (Task 6 완료 후)

  **References**:
  - `ios/DrinkSomeWater/Sources/Services/AlertService.swift` - 알림 표시 패턴
  - `ios/DrinkSomeWater/Resources/Localizable.xcstrings` - Localization 패턴

  **Acceptance Criteria**:
  - [ ] Instagram 미설치 시 "Instagram이 설치되어 있지 않습니다" 알림 표시
  - [ ] Feed 공유 시 Photo Library 권한 요청
  - [ ] 권한 거부 시 설정 안내 알림
  - [ ] 에러 메시지 한국어/영어 Localization
  
  **Manual Verification**:
  - [ ] 시뮬레이터 (Instagram 없음)에서 공유 시도 → 알림 표시됨
  - [ ] 알림 텍스트: "Instagram이 설치되어 있지 않습니다"
  - [ ] Feed 공유 처음 시도 → Photo Library 권한 요청 팝업

  **Commit**: YES
  - Message: `feat(sharing): add error handling and localization for Instagram sharing`
  - Files: `ios/DrinkSomeWater/Sources/Services/InstagramSharingService.swift`, `ios/DrinkSomeWater/Resources/Localizable.xcstrings`

---

- [ ] 8. 유닛 테스트 작성

  **What to do**:
  - `InstagramSharingServiceTests.swift` 생성
  - ShareCardView 렌더링 테스트
  - InstagramSharingService 로직 테스트 (Mock 사용)
  - 에러 케이스 테스트

  **Must NOT do**:
  - UI 테스트 (유닛 테스트만)
  - 실제 Instagram 앱 연동 테스트

  **Parallelizable**: NO (Task 7 완료 후)

  **References**:
  - `ios/DrinkSomeWaterTests/HomeStoreTests.swift` - Swift Testing 사용 패턴
  - `ios/DrinkSomeWaterTests/Mocks/MockServices.swift` - Mock 서비스 패턴
  - `ios/DrinkSomeWaterTests/WaterServiceTests.swift` - 서비스 테스트 패턴

  **Acceptance Criteria**:
  - [ ] InstagramSharingServiceTests.swift 생성됨
  - [ ] `@Suite("InstagramSharingService")` 사용
  - [ ] ShareCardView → UIImage 렌더링 테스트
  - [ ] 0%, 100%, 150% 달성률 카드 생성 테스트
  - [ ] Instagram 미설치 시 에러 반환 테스트
  
  **Manual Verification**:
  - [ ] `tuist test` 실행 → 모든 테스트 통과
  - [ ] InstagramSharingServiceTests 포함 확인

  **Commit**: YES
  - Message: `test(sharing): add InstagramSharingService unit tests`
  - Files: `ios/DrinkSomeWaterTests/InstagramSharingServiceTests.swift`, `ios/DrinkSomeWaterTests/Mocks/MockServices.swift`

---

- [ ] 9. Facebook App ID 설정 가이드 작성

  **What to do**:
  - `.sisyphus/docs/FACEBOOK_APP_ID_SETUP.md` 생성
  - Facebook Developer 계정 생성 방법
  - App ID 발급 절차
  - Info.plist 설정 방법
  - 테스트 방법

  **Must NOT do**:
  - 실제 App ID 포함
  - 민감한 정보 포함

  **Parallelizable**: YES (언제든 가능)

  **References**:
  - https://developers.facebook.com/docs/sharing/
  - 프로젝트의 기존 문서 패턴

  **Acceptance Criteria**:
  - [ ] FACEBOOK_APP_ID_SETUP.md 생성됨
  - [ ] 단계별 스크린샷 또는 상세 설명 포함
  - [ ] 한국어로 작성
  
  **Manual Verification**:
  - [ ] 문서 내용 검토 → 절차가 명확함
  - [ ] 링크 클릭 → 정상 작동

  **Commit**: YES
  - Message: `docs(sharing): add Facebook App ID setup guide`
  - Files: `.sisyphus/docs/FACEBOOK_APP_ID_SETUP.md`

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `feat(sharing): add Instagram URL schemes` | Project.swift | tuist generate |
| 2 | `feat(sharing): add ShareCardView` | ShareCardView.swift | Xcode Preview |
| 3 | `feat(sharing): add InstagramSharingService` | InstagramSharingService.swift, ServiceProvider.swift | 수동 테스트 |
| 4 | `feat(sharing): add share button to HomeView` | HomeView.swift, HomeStore.swift | 앱 실행 |
| 5 | `feat(sharing): add share button to HistoryView` | HistoryView.swift, HistoryStore.swift | 앱 실행 |
| 6 | `feat(analytics): add sharing events` | AnalyticsEvent.swift, Views | Firebase Debug |
| 7 | `feat(sharing): add error handling` | InstagramSharingService.swift, Localizable | 시뮬레이터 |
| 8 | `test(sharing): add unit tests` | Tests | tuist test |
| 9 | `docs(sharing): add FB setup guide` | FACEBOOK_APP_ID_SETUP.md | 문서 검토 |

---

## Success Criteria

### Verification Commands
```bash
# 프로젝트 생성
tuist generate

# 빌드
tuist build

# 테스트
tuist test
```

### Final Checklist
- [ ] HomeView에서 Instagram Stories/Feed로 오늘 기록 공유 가능
- [ ] HistoryView에서 선택한 날짜 기록 공유 가능
- [ ] 공유 카드에 섭취량, 목표량, 퍼센트, streak, 로고 표시
- [ ] Stories (1080x1920), Feed (1080x1080) 이미지 정상 생성
- [ ] Instagram 미설치 시 알림 표시
- [ ] Analytics 이벤트 정상 기록
- [ ] 모든 유닛 테스트 통과
- [ ] Facebook App ID 설정 가이드 완성
