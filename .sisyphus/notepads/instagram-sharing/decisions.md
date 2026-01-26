# Architectural Decisions - Instagram Sharing Feature

## Design Decisions
- UI Style: Minimal design matching app colors
- Share Locations: HomeView (today) + HistoryView (selected date)
- Image Formats: Stories (1080x1920), Feed (1080x1080)
- Error Handling: Simple alerts, no App Store links

## Technical Decisions
- No external libraries (native APIs only)
- Use DesignTokens exclusively (no hardcoded styles)
- @Observable Store pattern for state management
- Tests after implementation (not TDD)
