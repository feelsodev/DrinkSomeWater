import SwiftUI
import Foundation

enum ShareCardStyle {
    case stories  // 9:16 aspect ratio (1080x1920)
    case feed     // 1:1 aspect ratio (1080x1080)
}

struct ShareCardView: View {
    let record: WaterRecord
    let streak: Int
    let style: ShareCardStyle
    
    private var cardWidth: CGFloat {
        switch style {
        case .stories: return 1080
        case .feed: return 1080
        }
    }
    
    private var cardHeight: CGFloat {
        switch style {
        case .stories: return 1920
        case .feed: return 1080
        }
    }
    
    private var achievementPercentage: Int {
        guard record.goal > 0 else { return 0 }
        return Int((Float(record.value) / Float(record.goal)) * 100)
    }
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    DS.SwiftUIColor.primaryLight,
                    DS.SwiftUIColor.primary.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: style == .stories ? DS.Spacing.xxxxl : DS.Spacing.xl) {
                Spacer()
                
                // App Logo/Branding
                VStack(spacing: DS.Spacing.sm) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: style == .stories ? 80 : 60))
                        .foregroundStyle(DS.SwiftUIColor.primary)
                    
                    Text("벌컥벌컥")
                        .font(.system(size: style == .stories ? 32 : 24, weight: .bold))
                        .foregroundStyle(DS.SwiftUIColor.textPrimary)
                }
                
                Spacer()
                
                // Main Content Card
                VStack(spacing: DS.Spacing.lg) {
                    // Water Intake Display
                    VStack(spacing: DS.Spacing.xs) {
                        Text("\(record.value)ml")
                            .font(.system(size: style == .stories ? 72 : 56, weight: .bold))
                            .foregroundStyle(DS.SwiftUIColor.primary)
                        
                        Text("/ \(record.goal)ml")
                            .font(.system(size: style == .stories ? 28 : 22, weight: .medium))
                            .foregroundStyle(DS.SwiftUIColor.textSecondary)
                    }
                    
                    // Achievement Percentage
                    HStack(spacing: DS.Spacing.xs) {
                        Text("\(achievementPercentage)%")
                            .font(.system(size: style == .stories ? 48 : 36, weight: .bold))
                            .foregroundStyle(
                                achievementPercentage >= 100 ? DS.SwiftUIColor.success : DS.SwiftUIColor.primary
                            )
                        
                        if achievementPercentage >= 100 {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: style == .stories ? 40 : 32))
                                .foregroundStyle(DS.SwiftUIColor.success)
                        }
                    }
                    
                    // Streak Display
                    if streak > 0 {
                        HStack(spacing: DS.Spacing.sm) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: style == .stories ? 32 : 24))
                                .foregroundStyle(.orange)
                            
                            Text("\(streak)일 연속 달성")
                                .font(.system(size: style == .stories ? 24 : 18, weight: .semibold))
                                .foregroundStyle(DS.SwiftUIColor.textPrimary)
                        }
                        .padding(.horizontal, DS.Spacing.xl)
                        .padding(.vertical, DS.Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: DS.Size.cornerRadiusXLarge, style: .continuous)
                                .fill(.white.opacity(0.9))
                        )
                    }
                }
                .padding(style == .stories ? DS.Spacing.xxxxl : DS.Spacing.xxl)
                .background(
                    RoundedRectangle(cornerRadius: style == .stories ? 40 : 32, style: .continuous)
                        .fill(.white.opacity(0.95))
                        .shadow(
                            color: DS.SwiftUIColor.primary.opacity(0.3),
                            radius: style == .stories ? 30 : 20,
                            y: style == .stories ? 15 : 10
                        )
                )
                
                Spacer()
                
                // Date
                Text(formatDate(record.date))
                    .font(.system(size: style == .stories ? 20 : 16, weight: .medium))
                    .foregroundStyle(DS.SwiftUIColor.textSecondary)
                
                Spacer()
            }
            .padding(style == .stories ? DS.Spacing.xxxxl : DS.Spacing.xxl)
        }
        .frame(width: cardWidth, height: cardHeight)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

// MARK: - Previews

#Preview("Stories - 0% Achievement") {
    ShareCardView(
        record: WaterRecord(
            date: Date(),
            value: 0,
            isSuccess: false,
            goal: 2000
        ),
        streak: 0,
        style: .stories
    )
}

#Preview("Stories - 50% Achievement") {
    ShareCardView(
        record: WaterRecord(
            date: Date(),
            value: 1000,
            isSuccess: false,
            goal: 2000
        ),
        streak: 3,
        style: .stories
    )
}

#Preview("Stories - 100% Achievement") {
    ShareCardView(
        record: WaterRecord(
            date: Date(),
            value: 2000,
            isSuccess: true,
            goal: 2000
        ),
        streak: 7,
        style: .stories
    )
}

#Preview("Stories - 150% Achievement") {
    ShareCardView(
        record: WaterRecord(
            date: Date(),
            value: 3000,
            isSuccess: true,
            goal: 2000
        ),
        streak: 14,
        style: .stories
    )
}

#Preview("Feed - 100% Achievement") {
    ShareCardView(
        record: WaterRecord(
            date: Date(),
            value: 2000,
            isSuccess: true,
            goal: 2000
        ),
        streak: 7,
        style: .feed
    )
}

#Preview("Feed - 50% Achievement") {
    ShareCardView(
        record: WaterRecord(
            date: Date(),
            value: 1000,
            isSuccess: false,
            goal: 2000
        ),
        streak: 3,
        style: .feed
    )
}
