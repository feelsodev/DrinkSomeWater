import SwiftUI
import UIKit
import Foundation

enum ShareCardStyle {
    case stories
    case feed
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
    
    private var mascotImage: UIImage? {
        if achievementPercentage >= 100 {
            return UIImage(named: "bang3")
        } else if achievementPercentage >= 50 {
            return UIImage(named: "bang2")
        } else {
            return UIImage(named: "bang")
        }
    }
    
    private var scaleFactor: CGFloat {
        style == .stories ? 1.0 : 0.75
    }
    
    var body: some View {
        ZStack {
            DS.SwiftUIColor.primaryLight
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: style == .stories ? 180 : 80)
                
                if let mascot = mascotImage {
                    Image(uiImage: mascot)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 280 * scaleFactor, height: 280 * scaleFactor)
                }
                
                Spacer()
                    .frame(height: style == .stories ? 60 : 30)
                
                VStack(spacing: 24 * scaleFactor) {
                    Text("\(record.value)ml")
                        .font(.system(size: 96 * scaleFactor, weight: .heavy, design: .rounded))
                        .foregroundStyle(DS.SwiftUIColor.primary)
                    
                    Text("/ \(record.goal)ml")
                        .font(.system(size: 36 * scaleFactor, weight: .medium, design: .rounded))
                        .foregroundStyle(DS.SwiftUIColor.textSecondary)
                }
                
                Spacer()
                    .frame(height: style == .stories ? 50 : 24)
                
                HStack(spacing: 16 * scaleFactor) {
                    ZStack {
                        Circle()
                            .fill(achievementPercentage >= 100 ? DS.SwiftUIColor.success : DS.SwiftUIColor.primary)
                            .frame(width: 140 * scaleFactor, height: 140 * scaleFactor)
                        
                        Text("\(achievementPercentage)%")
                            .font(.system(size: 44 * scaleFactor, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    if streak > 0 {
                        VStack(alignment: .leading, spacing: 4 * scaleFactor) {
                            HStack(spacing: 8 * scaleFactor) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 32 * scaleFactor))
                                    .foregroundStyle(.orange)
                                Text("\(streak)일")
                                    .font(.system(size: 44 * scaleFactor, weight: .bold, design: .rounded))
                                    .foregroundStyle(DS.SwiftUIColor.textPrimary)
                            }
                            Text("연속 달성")
                                .font(.system(size: 24 * scaleFactor, weight: .medium))
                                .foregroundStyle(DS.SwiftUIColor.textSecondary)
                        }
                    }
                }
                .padding(.horizontal, 48 * scaleFactor)
                .padding(.vertical, 32 * scaleFactor)
                .background(
                    RoundedRectangle(cornerRadius: 32 * scaleFactor, style: .continuous)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.1), radius: 20 * scaleFactor, y: 8 * scaleFactor)
                )
                
                Spacer()
                
                VStack(spacing: 8 * scaleFactor) {
                    Text(formatDate(record.date))
                        .font(.system(size: 24 * scaleFactor, weight: .medium))
                        .foregroundStyle(DS.SwiftUIColor.textSecondary)
                    
                    Text("벌컥벌컥")
                        .font(.system(size: 28 * scaleFactor, weight: .bold))
                        .foregroundStyle(DS.SwiftUIColor.primary)
                }
                
                Spacer()
                    .frame(height: style == .stories ? 100 : 50)
            }
            .padding(.horizontal, 60 * scaleFactor)
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
