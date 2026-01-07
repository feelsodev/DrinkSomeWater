import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
  let entry: WaterEntry
  
  private let primaryGradient = LinearGradient(
    colors: [Color(red: 0.29, green: 0.56, blue: 0.85), Color(red: 0.40, green: 0.72, blue: 0.87)],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
  
  private let successGradient = LinearGradient(
    colors: [Color(red: 0.20, green: 0.78, blue: 0.35), Color(red: 0.19, green: 0.70, blue: 0.31)],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
  
  var body: some View {
    ZStack {
      ZStack {
        Circle()
          .stroke(Color.blue.opacity(0.1), lineWidth: 12)
        
        Circle()
          .trim(from: 0, to: CGFloat(min(entry.progress, 1.0)))
          .stroke(
            entry.isGoalAchieved ? successGradient : primaryGradient,
            style: StrokeStyle(lineWidth: 12, lineCap: .round)
          )
          .rotationEffect(.degrees(-90))
      }
      .padding(8)
      
      VStack(spacing: 2) {
        if entry.isGoalAchieved {
          Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 24))
            .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.35))
            .padding(.bottom, 2)
        } else {
          Image(systemName: "drop.fill")
            .font(.system(size: 20))
            .foregroundStyle(Color(red: 0.35, green: 0.78, blue: 0.98))
            .padding(.bottom, 2)
        }
        
        Text("\(entry.progressPercent)%")
          .font(.system(size: 26, weight: .bold, design: .rounded))
          .foregroundStyle(.primary)
          .contentTransition(.numericText(value: Double(entry.progressPercent)))
        
        Text("\(entry.todayWater)")
          .font(.system(size: 13, weight: .medium, design: .rounded))
          .foregroundStyle(.secondary)
          .contentTransition(.numericText(value: Double(entry.todayWater)))
      }
    }
    .containerBackground(for: .widget) {
      Color(.systemBackground)
    }
  }
}
