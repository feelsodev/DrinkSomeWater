import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: WaterEntry
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "drop.fill")
                .font(.system(size: 28))
                .foregroundStyle(entry.isGoalAchieved ? .green : .blue)
            
            Text("\(entry.todayWater)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            
            Text("/ \(entry.goal)ml")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.secondary)
            
            Text("\(entry.progressPercent)%")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(entry.isGoalAchieved ? .green : .blue)
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}
