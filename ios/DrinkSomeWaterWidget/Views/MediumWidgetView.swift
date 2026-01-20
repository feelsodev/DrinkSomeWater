import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
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
    HStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 6) {
          Image(systemName: "drop.fill")
            .font(.system(size: 14))
            .foregroundStyle(Color(red: 0.35, green: 0.78, blue: 0.98))
          Text(String(localized: "widget.todays.hydration"))
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundStyle(.secondary)
        }
        .padding(.bottom, 12)
        
        HStack(spacing: 16) {
          ZStack {
            Circle()
              .stroke(Color.blue.opacity(0.1), lineWidth: 8)
            
            Circle()
              .trim(from: 0, to: CGFloat(min(entry.progress, 1.0)))
              .stroke(
                entry.isGoalAchieved ? successGradient : primaryGradient,
                style: StrokeStyle(lineWidth: 8, lineCap: .round)
              )
              .rotationEffect(.degrees(-90))
            
            Text("\(entry.progressPercent)%")
              .font(.system(size: 14, weight: .bold, design: .rounded))
              .contentTransition(.numericText(value: Double(entry.progressPercent)))
          }
          .frame(width: 60, height: 60)
          
          VStack(alignment: .leading, spacing: 2) {
            Text("\(entry.todayWater)")
              .font(.system(size: 28, weight: .bold, design: .rounded))
              .foregroundStyle(.primary)
              .contentTransition(.numericText(value: Double(entry.todayWater)))
            
            Text("/ \(entry.goal)ml")
              .font(.system(size: 14, weight: .medium, design: .rounded))
              .foregroundStyle(.secondary)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.leading, 6)
      
      Rectangle()
        .fill(Color.secondary.opacity(0.1))
        .frame(width: 1)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
      
      VStack(spacing: 12) {
        Button(intent: AddWaterIntent(amount: 150)) {
          HStack {
            Image(systemName: "plus")
              .font(.system(size: 12, weight: .bold))
            Text("150")
              .font(.system(size: 15, weight: .semibold, design: .rounded))
          }
          .frame(maxWidth: .infinity)
          .frame(height: 40)
          .background(Color(red: 0.29, green: 0.56, blue: 0.85).opacity(0.1))
          .clipShape(Capsule())
          .foregroundStyle(Color(red: 0.29, green: 0.56, blue: 0.85))
        }
        .buttonStyle(.plain)
        
        Button(intent: AddWaterIntent(amount: 300)) {
          HStack {
            Image(systemName: "plus")
              .font(.system(size: 12, weight: .bold))
            Text("300")
              .font(.system(size: 15, weight: .semibold, design: .rounded))
          }
          .frame(maxWidth: .infinity)
          .frame(height: 40)
          .background(Color(red: 0.35, green: 0.78, blue: 0.98).opacity(0.15))
          .clipShape(Capsule())
          .foregroundStyle(Color(red: 0.20, green: 0.60, blue: 0.80))
        }
        .buttonStyle(.plain)
      }
      .frame(width: 90)
    }
    .padding(16)
    .containerBackground(for: .widget) {
      Color(.systemBackground)
    }
  }
}
