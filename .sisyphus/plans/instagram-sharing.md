# Instagram Sharing Feature for DrinkSomeWater

## Context

### Original Request
Build a feature for the iOS project to share water intake records to Instagram Stories and posts.

### Interview Summary
**Key Discussions**:
- Share locations: HomeView (today's record) + HistoryView (selected date record)
- Image design: Create new sharing card (Instagram-optimized, minimal style)
- Card content: intake/goal, achievement percentage, streak days, app logo/branding
- Facebook App ID: None (setup guide provided)
- Testing: Add tests after implementation
- Share button: Icon only (SF Symbol)
- Error handling: Simple alert when Instagram not installed
- Share targets: Stories + Feed (provide selection option)

**Research Findings**:
- iOS Deployment Target: 26.0 (ImageRenderer available)
- Architecture: @Observable Store Pattern
- Testing framework: Swift Testing
- Design system: DesignTokens.swift (DS.Color, DS.Font)
- Instagram Stories: UIPasteboard + URL Scheme
- Instagram Feed: Save to Photo Library then open Instagram app

### Metis Review
**Identified Gaps** (addressed):
- UI placement unclear → decided: icon-only button
- Error handling undefined → decided: simple alert
- Stories vs Feed → support both, provide selection option
- Facebook App ID required → include guide document

---

## Work Objectives

### Core Objective
Implement a feature to share water intake records to Instagram Stories and Feed.

### Concrete Deliverables
- `InstagramSharingService.swift` - Instagram sharing logic
- `ShareCardView.swift` - Sharing card UI (Stories 1080x1920, Feed 1080x1080)
- `HomeView.swift` modification - Add share button
- `HistoryView.swift` modification - Add share button
- `Project.swift` modification - Add LSApplicationQueriesSchemes
- `AnalyticsEvent.swift` modification - Add sharing events
- `InstagramSharingServiceTests.swift` - Unit tests
- `FACEBOOK_APP_ID_SETUP.md` - Facebook App ID setup guide

### Definition of Done
- [x] Share today's record from HomeView to Instagram Stories/Feed
- [x] Share selected date record from HistoryView to Instagram Stories/Feed
- [x] Show alert when Instagram is not installed
- [x] Share card shows intake, goal, percentage, streak, logo
- [x] Generate Stories (1080x1920) and Feed (1080x1080) images
- [x] Analytics events recorded
- [x] Unit tests pass

### Must Have
- Instagram Stories sharing
- Instagram Feed sharing (via Photo Library save)
- Stories/Feed selection option (ActionSheet)
- Minimal design sharing card (using existing design tokens)
- Error handling when Instagram is not installed
- Analytics event tracking

### Must NOT Have (Guardrails)
- watchOS sharing feature
- Widget share button
- Other social networks (Twitter, KakaoTalk, Facebook)
- Share preview screen
- Image customization options (background color, stickers, etc.)
- External libraries/packages
- WaterRecord model modifications
- Hardcoded colors/fonts (use DesignTokens)

---

## Verification Strategy (MANDATORY)

### Test Decision
- **Infrastructure exists**: YES (Swift Testing framework)
- **User wants tests**: YES (tests after implementation)
- **Framework**: Swift Testing

### Test Structure
After each TODO:
1. Manual verification first
2. Write test code (written in bulk at Task 10)

### Manual Execution Verification
Manual verification steps included per task.

---

## Task Flow

```
Task 1 (Info.plist) 
    ↓
Task 2 (ShareCardView)
    ↓
Task 3 (InstagramSharingService)
    ↓
Task 4 (HomeView share button) ←──┐
    ↓                         │ parallelizable
Task 5 (HistoryView share button) ←┘
    ↓
Task 6 (Analytics events)
    ↓
Task 7 (Error handling improvements)
    ↓
Task 8 (Write tests)
    ↓
Task 9 (Facebook App ID guide)
```

## Parallelization

| Group | Tasks | Reason |
|-------|-------|--------|
| A | 4, 5 | HomeView, HistoryView are independent modifications |

| Task | Depends On | Reason |
|------|------------|--------|
| 2 | 1 | Develop card after URL Scheme setup |
| 3 | 2 | Develop service after card view complete |
| 4, 5 | 3 | Integrate UI after service complete |
| 6 | 4, 5 | Add Analytics after UI integration |
| 7 | 6 | Error handling after basic flow complete |
| 8 | 7 | Tests after full feature complete |
| 9 | - | Independent, can be done anytime |

---

## TODOs

- [x] 1. Add LSApplicationQueriesSchemes to Info.plist

  **What to do**:
  - Add LSApplicationQueriesSchemes to the infoPlist section in Project.swift
  - Register `instagram-stories` and `instagram` URL schemes

  **Must NOT do**:
  - Modify Info.plist directly (use Tuist)
  - Add unnecessary URL schemes

  **Parallelizable**: NO (first task)

  **References**:
  - `ios/Project.swift:33-115` - infoPlist configuration pattern (extendingDefault usage)
  - Instagram API docs: `instagram-stories` and `instagram` needed in LSApplicationQueriesSchemes

  **Acceptance Criteria**:
  - [ ] LSApplicationQueriesSchemes array added to Project.swift
  - [ ] Two schemes registered: `instagram-stories` and `instagram`
  
  **Manual Verification**:
  - [ ] Run `tuist generate` → success
  - [ ] Check generated xcodeproj Info.plist → LSApplicationQueriesSchemes included

  **Commit**: YES
  - Message: `feat(sharing): add Instagram URL schemes to Info.plist`
  - Files: `ios/Project.swift`

---

- [x] 2. Create ShareCardView (sharing card UI)

  **What to do**:
  - Create `ios/DrinkSomeWater/Sources/Views/ShareCardView.swift`
  - Stories layout (1080x1920, 9:16) and Feed layout (1080x1080, 1:1)
  - Content: intake (ml), goal (ml), achievement percentage, streak days, app logo
  - Minimal design, use DesignTokens
  - Support both Light/Dark mode (background uses app primary color family)

  **Must NOT do**:
  - Use hardcoded colors/fonts
  - Add animations
  - User customization options

  **Parallelizable**: NO (after Task 1)

  **References**:
  - `ios/DrinkSomeWater/Sources/DesignSystem/DesignTokens.swift` - Use DS.Color, DS.SwiftUIFont
  - `ios/DrinkSomeWater/Sources/Views/HomeView.swift:109-130` - messageCard design pattern reference
  - `ios/DrinkSomeWater/Sources/Views/HistoryView.swift:421-485` - RecordCard design pattern reference
  - `ios/DrinkSomeWater/Sources/Models/WaterRecord.swift` - WaterRecord model structure
  - Instagram Stories optimal size: 1080x1920 (9:16)
  - Instagram Feed optimal size: 1080x1080 (1:1)

  **Acceptance Criteria**:
  - [ ] ShareCardView.swift file created
  - [ ] `enum ShareCardStyle { case stories, feed }` defined
  - [ ] stories: 1080x1920 ratio, feed: 1080x1080 ratio layout
  - [ ] Intake, goal, percentage, streak, logo displayed
  - [ ] Only DS.Color, DS.SwiftUIFont used (no hardcoding)
  
  **Manual Verification**:
  - [ ] ShareCardView renders in Xcode Preview
  - [ ] Stories style: tall vertical layout confirmed
  - [ ] Feed style: square layout confirmed
  - [ ] All achievement rates (0%, 50%, 100%, 150%) display correctly

  **Commit**: YES
  - Message: `feat(sharing): add ShareCardView for Instagram sharing`
  - Files: `ios/DrinkSomeWater/Sources/Views/ShareCardView.swift`

---

- [x] 3. Create InstagramSharingService

  **What to do**:
  - Create `ios/DrinkSomeWater/Sources/Services/InstagramSharingService.swift`
  - Render ShareCardView to UIImage (using ImageRenderer)
  - Instagram Stories sharing: UIPasteboard + URL scheme
  - Instagram Feed sharing: Save to Photo Library + open Instagram app
  - Add to ServiceProviderProtocol
  - Instagram installation check method

  **Must NOT do**:
  - Use external libraries
  - Facebook SDK integration
  - Synchronous blocking code

  **Parallelizable**: NO (after Task 2)

  **References**:
  - `ios/DrinkSomeWater/Sources/Services/ServiceProvider.swift` - Service registration pattern
  - `ios/DrinkSomeWater/Sources/Services/WaterService.swift` - Service structure pattern (async/await)
  - Instagram Stories API: Save image to UIPasteboard with key `com.instagram.sharedSticker.backgroundImage`
  - URL Scheme: `instagram-stories://share?source_application={appId}`
  - Feed sharing: `instagram://library?LocalIdentifier={assetId}`
  - ImageRenderer: iOS 16+ SwiftUI → UIImage conversion

  **Acceptance Criteria**:
  - [ ] InstagramSharingService.swift created
  - [ ] `func isInstagramInstalled() -> Bool` implemented
  - [ ] `func shareToStories(record: WaterRecord, streak: Int) async throws` implemented
  - [ ] `func shareToFeed(record: WaterRecord, streak: Int) async throws` implemented
  - [ ] `instagramSharingService` property added to ServiceProvider
  - [ ] @MainActor applied (UI rendering required)
  
  **Manual Verification**:
  - [ ] `isInstagramInstalled()` returns false in simulator
  - [ ] Returns true on real device with Instagram installed
  - [ ] ShareCardView → UIImage conversion successful (via logs or breakpoint)

  **Commit**: YES
  - Message: `feat(sharing): add InstagramSharingService with Stories and Feed support`
  - Files: `ios/DrinkSomeWater/Sources/Services/InstagramSharingService.swift`, `ios/DrinkSomeWater/Sources/Services/ServiceProvider.swift`

---

- [x] 4. Add share button to HomeView

  **What to do**:
  - Add share button to HomeView (SF Symbol: `square.and.arrow.up`)
  - Place in headerSection area (next to goal amount)
  - Show ActionSheet on tap: "Share to Instagram Stories" / "Share to Instagram Feed"
  - Make streak calculation in HomeStore accessible (currently private)
  - Call InstagramSharingService when sharing

  **Must NOT do**:
  - Add complex UI
  - Share preview screen
  - Add text labels (icon only)

  **Parallelizable**: YES (can run parallel with Task 5)

  **References**:
  - `ios/DrinkSomeWater/Sources/Views/HomeView.swift:78-107` - headerSection structure
  - `ios/DrinkSomeWater/Sources/Stores/HomeStore.swift:96-114` - calculateStreak() method (change private → internal)
  - `ios/DrinkSomeWater/Sources/Views/HomeView.swift:247-252` - Button style pattern

  **Acceptance Criteria**:
  - [ ] Share button displayed in HomeView headerSection
  - [ ] Share button uses `square.and.arrow.up` SF Symbol
  - [ ] ActionSheet shown on button tap (Stories/Feed selection)
  - [ ] HomeStore.calculateStreak() changed to internal
  - [ ] Stories selection → calls InstagramSharingService.shareToStories
  - [ ] Feed selection → calls InstagramSharingService.shareToFeed
  
  **Manual Verification**:
  - [ ] Launch app → share button visible in HomeView
  - [ ] Tap button → ActionSheet shown
  - [ ] "Share to Instagram Stories" option shown
  - [ ] "Share to Instagram Feed" option shown
  - [ ] (On device with Instagram) Select Stories → Instagram Stories editor opens

  **Commit**: YES
  - Message: `feat(sharing): add Instagram share button to HomeView`
  - Files: `ios/DrinkSomeWater/Sources/Views/HomeView.swift`, `ios/DrinkSomeWater/Sources/Stores/HomeStore.swift`

---

- [x] 5. Add share button to HistoryView

  **What to do**:
  - Add share button to RecordCard component
  - Enable share button only when selectedRecord exists
  - Show ActionSheet on tap
  - Need streak calculation for that date (add method to HistoryStore)

  **Must NOT do**:
  - Change entire HistoryView layout
  - Multi-select sharing
  - Share preview

  **Parallelizable**: YES (can run parallel with Task 4)

  **References**:
  - `ios/DrinkSomeWater/Sources/Views/HistoryView.swift:421-485` - RecordCard component
  - `ios/DrinkSomeWater/Sources/Stores/HistoryStore.swift` - HistoryStore structure
  - `ios/DrinkSomeWater/Sources/Stores/HomeStore.swift:96-114` - Reference for streak calculation logic

  **Acceptance Criteria**:
  - [ ] Share button added to RecordCard
  - [ ] ActionSheet shown on button tap
  - [ ] `calculateStreakForDate(_ date: Date) -> Int` method added to HistoryStore
  - [ ] Share with streak calculated for selected date
  
  **Manual Verification**:
  - [ ] HistoryView → select date in calendar
  - [ ] RecordCard shown + share button visible
  - [ ] Tap share button → ActionSheet shown
  - [ ] Select Stories → card generated with that date's record

  **Commit**: YES
  - Message: `feat(sharing): add Instagram share button to HistoryView RecordCard`
  - Files: `ios/DrinkSomeWater/Sources/Views/HistoryView.swift`, `ios/DrinkSomeWater/Sources/Stores/HistoryStore.swift`

---

- [x] 6. Add Analytics events

  **What to do**:
  - Add sharing-related events to AnalyticsEvent:
  - `instagramShareInitiated(destination: ShareDestination, source: ShareSource)`
  - `instagramShareCompleted(destination: ShareDestination, source: ShareSource)`
  - `instagramShareFailed(destination: ShareDestination, reason: String)`
  - Call Analytics in sharing flow

  **Must NOT do**:
  - Events containing personal data (intake amounts, etc.)
  - Excessive event additions

  **Parallelizable**: NO (after Tasks 4, 5)

  **References**:
  - `ios/Analytics/Sources/AnalyticsEvent.swift` - Event definition pattern
  - `ios/Analytics/Sources/Analytics.swift` - Analytics.shared.log() usage
  - `ios/DrinkSomeWater/Sources/Stores/HomeStore.swift:57` - Analytics usage example

  **Acceptance Criteria**:
  - [ ] `instagramShareInitiated`, `instagramShareCompleted`, `instagramShareFailed` added to AnalyticsEvent
  - [ ] `ShareDestination` enum: `.stories`, `.feed`
  - [ ] `ShareSource` enum: `.home`, `.history`
  - [ ] Analytics events recorded at share start, complete, and failure
  
  **Manual Verification**:
  - [ ] Tap share button → confirm `instagram_share_initiated` event in Firebase Debug View
  - [ ] Share complete → confirm `instagram_share_completed` event
  - [ ] Instagram not installed → confirm `instagram_share_failed` event

  **Commit**: YES
  - Message: `feat(analytics): add Instagram sharing analytics events`
  - Files: `ios/Analytics/Sources/AnalyticsEvent.swift`, `ios/DrinkSomeWater/Sources/Views/HomeView.swift`, `ios/DrinkSomeWater/Sources/Views/HistoryView.swift`

---

- [x] 7. Improve error handling

  **What to do**:
  - Show alert when Instagram is not installed (use AlertService)
  - Request Photo Library permission (for Feed sharing)
  - Handle image generation failure
  - User-friendly error messages (Localizable)

  **Must NOT do**:
  - Provide App Store link (simple alert only)
  - Complex error recovery logic

  **Parallelizable**: NO (after Task 6)

  **References**:
  - `ios/DrinkSomeWater/Sources/Services/AlertService.swift` - Alert display pattern
  - `ios/DrinkSomeWater/Resources/Localizable.xcstrings` - Localization pattern

  **Acceptance Criteria**:
  - [ ] Show "Instagram is not installed" alert when Instagram missing
  - [ ] Photo Library permission requested for Feed sharing
  - [ ] Settings guidance alert shown when permission denied
  - [ ] Error messages localized in Korean/English
  
  **Manual Verification**:
  - [ ] Attempt to share in simulator (no Instagram) → alert shown
  - [ ] Alert text: "Instagram is not installed"
  - [ ] First Feed share attempt → Photo Library permission popup

  **Commit**: YES
  - Message: `feat(sharing): add error handling and localization for Instagram sharing`
  - Files: `ios/DrinkSomeWater/Sources/Services/InstagramSharingService.swift`, `ios/DrinkSomeWater/Resources/Localizable.xcstrings`

---

- [x] 8. Write unit tests

  **What to do**:
  - Create `InstagramSharingServiceTests.swift`
  - ShareCardView rendering tests
  - InstagramSharingService logic tests (using Mocks)
  - Error case tests

  **Must NOT do**:
  - UI tests (unit tests only)
  - Real Instagram app integration tests

  **Parallelizable**: NO (after Task 7)

  **References**:
  - `ios/DrinkSomeWaterTests/HomeStoreTests.swift` - Swift Testing usage pattern
  - `ios/DrinkSomeWaterTests/Mocks/MockServices.swift` - Mock service pattern
  - `ios/DrinkSomeWaterTests/WaterServiceTests.swift` - Service test pattern

  **Acceptance Criteria**:
  - [ ] InstagramSharingServiceTests.swift created
  - [ ] Uses `@Suite("InstagramSharingService")`
  - [ ] ShareCardView → UIImage rendering test
  - [ ] Card generation tests for 0%, 100%, 150% achievement rates
  - [ ] Error return test when Instagram not installed
  
  **Manual Verification**:
  - [ ] Run `tuist test` → all tests pass
  - [ ] Confirm InstagramSharingServiceTests included

  **Commit**: YES
  - Message: `test(sharing): add InstagramSharingService unit tests`
  - Files: `ios/DrinkSomeWaterTests/InstagramSharingServiceTests.swift`, `ios/DrinkSomeWaterTests/Mocks/MockServices.swift`

---

- [x] 9. Write Facebook App ID setup guide

  **What to do**:
  - Create `.sisyphus/docs/FACEBOOK_APP_ID_SETUP.md`
  - Facebook Developer account creation steps
  - App ID registration procedure
  - Info.plist configuration instructions
  - Testing instructions

  **Must NOT do**:
  - Include actual App ID
  - Include sensitive information

  **Parallelizable**: YES (can be done anytime)

  **References**:
  - https://developers.facebook.com/docs/sharing/
  - Existing project documentation patterns

  **Acceptance Criteria**:
  - [ ] FACEBOOK_APP_ID_SETUP.md created
  - [ ] Includes step-by-step screenshots or detailed instructions
  - [ ] Written in Korean
  
  **Manual Verification**:
  - [ ] Review document content → procedures are clear
  - [ ] Click links → working

  **Commit**: YES
  - Message: `docs(sharing): add Facebook App ID setup guide`
  - Files: `.sisyphus/docs/FACEBOOK_APP_ID_SETUP.md`

---

## Commit Strategy

| After Task | Message | Files | Verification |
|------------|---------|-------|--------------|
| 1 | `feat(sharing): add Instagram URL schemes` | Project.swift | tuist generate |
| 2 | `feat(sharing): add ShareCardView` | ShareCardView.swift | Xcode Preview |
| 3 | `feat(sharing): add InstagramSharingService` | InstagramSharingService.swift, ServiceProvider.swift | Manual testing |
| 4 | `feat(sharing): add share button to HomeView` | HomeView.swift, HomeStore.swift | App launch |
| 5 | `feat(sharing): add share button to HistoryView` | HistoryView.swift, HistoryStore.swift | App launch |
| 6 | `feat(analytics): add sharing events` | AnalyticsEvent.swift, Views | Firebase Debug |
| 7 | `feat(sharing): add error handling` | InstagramSharingService.swift, Localizable | Simulator |
| 8 | `test(sharing): add unit tests` | Tests | tuist test |
| 9 | `docs(sharing): add FB setup guide` | FACEBOOK_APP_ID_SETUP.md | Document review |

---

## Success Criteria

### Verification Commands
```bash
# Generate project
tuist generate

# Build
tuist build

# Test
tuist test
```

### Final Checklist
- [x] Share today's record from HomeView to Instagram Stories/Feed
- [x] Share selected date record from HistoryView
- [x] Share card shows intake, goal, percentage, streak, logo
- [x] Stories (1080x1920), Feed (1080x1080) images generated correctly
- [x] Alert shown when Instagram not installed
- [x] Analytics events recorded correctly
- [x] All unit tests pass
- [x] Facebook App ID setup guide complete
