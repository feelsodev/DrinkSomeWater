import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
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
  
  var motivationText: String {
    if entry.isGoalAchieved {
      return "Goal achieved! Great job! 🎉"
    } else if entry.progress >= 0.8 {
      return "Almost there! Keep going! 🚀"
    } else if entry.progress >= 0.5 {
      return "You're doing great! 💧"
    } else {
      return "Time to hydrate! 🥤"
    }
  }
  
  var body: some View {
    VStack(spacing: 0) {
      headerView
      
      HStack(spacing: 30) {
        progressRingView
        statsView
      }
      
      Spacer()
      
      Text(motivationText)
        .font(.system(size: 15, weight: .medium, design: .rounded))
        .foregroundStyle(.secondary)
        .padding(.bottom, 16)
      
      actionButtonsView
    }
    .padding(20)
    .containerBackground(for: .widget) {
      Color(.systemBackground)
    }
  }
  
  private var headerView: some View {
    HStack(spacing: 6) {
      Image(systemName: "drop.fill")
        .font(.system(size: 16))
        .foregroundStyle(Color(red: 0.35, green: 0.78, blue: 0.98))
      Text("Hydration Tracker")
        .font(.system(size: 15, weight: .medium, design: .rounded))
        .foregroundStyle(.secondary)
      Spacer()
    }
    .padding(.bottom, 20)
  }
  
  private var progressRingView: some View {
    ZStack {
      Circle()
        .stroke(Color.blue.opacity(0.1), lineWidth: 18)
      
      Circle()
        .trim(from: 0, to: CGFloat(min(entry.progress, 1.0)))
        .stroke(
          entry.isGoalAchieved ? successGradient : primaryGradient,
          style: StrokeStyle(lineWidth: 18, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))
      
      VStack(spacing: 0) {
        if entry.isGoalAchieved {
          Image(systemName: "checkmark")
            .font(.system(size: 40, weight: .bold))
            .foregroundStyle(Color(red: 0.20, green: 0.78, blue: 0.35))
        } else {
          Text("\(entry.progressPercent)%")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(.primary)
            .contentTransition(.numericText(value: Double(entry.progressPercent)))
        }
      }
    }
    .frame(width: 130, height: 130)
  }
  
  private var statsView: some View {
    VStack(alignment: .leading, spacing: 6) {
      VStack(alignment: .leading, spacing: 2) {
        Text("Current")
          .font(.system(size: 14, weight: .medium, design: .rounded))
          .foregroundStyle(.secondary)
        
        Text("\(entry.todayWater)")
          .font(.system(size: 34, weight: .bold, design: .rounded))
          .foregroundStyle(.primary)
          .contentTransition(.numericText(value: Double(entry.todayWater)))
      }
      
      Rectangle()
        .fill(Color.secondary.opacity(0.2))
        .frame(height: 1)
        .padding(.vertical, 4)
        .frame(width: 80)
        
      VStack(alignment: .leading, spacing: 2) {
        Text("Goal")
          .font(.system(size: 14, weight: .medium, design: .rounded))
          .foregroundStyle(.secondary)
        
        Text("\(entry.goal)ml")
          .font(.system(size: 20, weight: .semibold, design: .rounded))
          .foregroundStyle(.secondary)
      }
    }
  }
  
  private var actionButtonsView: some View {
    HStack(spacing: 12) {
      QuickAddButton(amount: 150)
      QuickAddButton(amount: 300)
      QuickAddButton(amount: 500)
    }
  }
}

private struct QuickAddButton: View {
  let amount: Int
  
  var body: some View {
    Button(intent: AddWaterIntent(amount: amount)) {
      VStack(spacing: 3) {
        Image(systemName: "plus")
          .font(.system(size: 10, weight: .bold))
        Text("\(amount)")
          .font(.system(size: 14, weight: .bold, design: .rounded))
      }
      .frame(maxWidth: .infinity)
      .frame(height: 50)
      .background(Color(red: 0.29, green: 0.56, blue: 0.85).opacity(0.1))
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .foregroundStyle(Color(red: 0.29, green: 0.56, blue: 0.85))
    }
    .buttonStyle(.plain)
  }
}
