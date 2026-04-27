# Learnings - Instagram Sharing Feature

## Conventions
(To be filled as we discover patterns)

## Patterns
(To be filled with reusable patterns)

## Gotchas
(To be filled with discovered issues)

## LSApplicationQueriesSchemes Configuration (Completed)

### Pattern Used
- Added `LSApplicationQueriesSchemes` array to Project.swift infoPlist configuration
- Followed existing `.extendingDefault(with: [:])` pattern used throughout the project
- Placed logically after UIApplicationSceneManifest and before health-related keys

### Implementation Details
- Location: `ios/Project.swift` lines 54-57
- Array contains two Instagram URL schemes:
  - `instagram-stories` - for Instagram Stories sharing
  - `instagram` - for general Instagram app integration
- Tuist generates the configuration into the final Info.plist during build

### Verification
- `tuist generate` executed successfully from ios/ directory
- Generated workspace: `DrinkSomeWater.xcworkspace`
- No syntax errors in Project.swift configuration
- Configuration follows iOS requirements for URL scheme declaration via LSApplicationQueriesSchemes

### Key Insight
- Tuist Project.swift is the source of truth for Info.plist configuration
- The `.extendingDefault(with: [:])` pattern merges custom keys with default iOS Info.plist keys
- URL schemes must be declared in LSApplicationQueriesSchemes for canOpenURL() to work on iOS 9+

## ShareCardView Implementation (Completed)

### Design Approach
- Created minimal, clean design matching app aesthetic
- Used gradient background (primaryLight → primary) for visual depth
- Centered layout with white card containing main content
- Responsive sizing based on style (Stories vs Feed)

### Layout Structure
- Stories: 1080x1920 (9:16 aspect ratio)
- Feed: 1080x1080 (1:1 aspect ratio)
- Vertical stack: Logo → Content Card → Date
- Content Card displays: intake value, goal, percentage, streak

### Design Tokens Usage
- All colors: DS.SwiftUIColor (primary, textPrimary, textSecondary, success)
- All spacing: DS.Spacing (xs, sm, md, lg, xl, xxl, xxxxl)
- All corner radius: DS.Size.cornerRadius values
- Fonts: System fonts with dynamic sizing based on card style

### Key Features
- Achievement percentage calculation
- Success indicator (checkmark) for 100%+ achievement
- Streak display with flame icon (only if streak > 0)
- Date formatting in Korean locale
- Conditional styling based on achievement level

### Preview Coverage
- 0%, 50%, 100%, 150% achievement scenarios
- Both Stories and Feed styles
- Multiple streak values (0, 3, 7, 14 days)

### Technical Notes
- No external dependencies (pure SwiftUI)
- No hardcoded colors/fonts (all via DesignTokens)
- Supports Light/Dark mode automatically (DS colors adapt)
- Ready for ImageRenderer conversion to UIImage

## InstagramSharingService Implementation (Completed)

### Service Structure
- Protocol: `InstagramSharingServiceProtocol` with 3 methods
- Implementation: `InstagramSharingService` as @MainActor final class
- Error handling: `InstagramSharingError` enum with LocalizedError conformance

### Key Methods
1. `isInstagramInstalled()` - Check if Instagram app is available via URL scheme
2. `shareToStories()` - Share to Instagram Stories using UIPasteboard
3. `shareToFeed()` - Share to Instagram Feed via Photo Library

### Stories Sharing Flow
1. Render ShareCardView to UIImage using ImageRenderer
2. Convert UIImage to PNG data
3. Copy to UIPasteboard with `com.instagram.sharedSticker.backgroundImage` key
4. Open Instagram Stories with `instagram-stories://share?source_application={bundleId}`

### Feed Sharing Flow
1. Request Photo Library permission (addOnly)
2. Render ShareCardView to UIImage
3. Save image to Photo Library using PHPhotoLibrary
4. Get asset localIdentifier
5. Open Instagram with `instagram://library?LocalIdentifier={assetId}`

### Technical Details
- ImageRenderer scale: 3.0 for high quality
- Photo Library permission: `.addOnly` (minimal permission)
- Async/await throughout for clean error handling
- LocalizedError for user-friendly error messages

### Integration
- Added to ServiceProvider protocol and implementation
- Instantiated in ServiceProvider.init()
- Ready for use in HomeView and HistoryView


## HomeView Instagram Share Button (Completed)

### Implementation Details
- Share button added to headerSection (line 145-156)
- SF Symbol: `square.and.arrow.up`
- Positioned next to goal setting button
- Circular background with primary color opacity

### ActionSheet Integration
- confirmationDialog for Stories/Feed selection (line 78-90)
- Two options: "Share to Instagram Stories" and "Share to Instagram Feed"
- Cancel button included

### Share Flow
1. Button tap → showShareSheet = true
2. ActionSheet displays with 2 options
3. User selects Stories or Feed
4. shareToInstagram(destination:) called
5. Creates WaterRecord from current data
6. Calculates streak using store.calculateStreak()
7. Calls InstagramSharingService
8. Handles errors (Instagram not installed)

### Error Handling
- Instagram not installed → showInstagramNotInstalledAlert = true
- Alert displays localized error message
- User-friendly error messages

### State Management
- @State showShareSheet: Bool - ActionSheet visibility
- @State showInstagramNotInstalledAlert: Bool - Error alert visibility

## HistoryView Instagram Share Button (Completed)

### Implementation Details
- Share button added to RecordCard component (line 475-483)
- Same SF Symbol and styling as HomeView
- Only shown when record is selected

### HistoryStore Enhancement
- Added calculateStreakForDate(_ date: Date) -> Int method
- Calculates streak up to specified date
- Reuses logic from HomeStore.calculateStreak()

### Share Flow
1. User selects date in calendar
2. RecordCard displays with share button
3. Button tap → showShareSheet = true
4. ActionSheet displays
5. User selects Stories or Feed
6. shareToInstagram(destination:) called with selected record
7. Calculates streak for that specific date
8. Calls InstagramSharingService

### Key Difference from HomeView
- Uses selectedRecord instead of current day
- Calculates streak for historical date
- Streak calculation considers records up to selected date only

