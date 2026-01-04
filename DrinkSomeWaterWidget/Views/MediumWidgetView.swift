import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: WaterEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.blue)
                    Text("Today")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                
                Text("\(entry.todayWater)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                
                Text("/ \(entry.goal)ml")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                
                ProgressView(value: entry.progress)
                    .tint(entry.isGoalAchieved ? .green : .blue)
            }
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(intent: AddWaterIntent(amount: 150)) {
                    Label("+150", systemImage: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 70, height: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                
                Button(intent: AddWaterIntent(amount: 300)) {
                    Label("+300", systemImage: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(width: 70, height: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(.cyan)
            }
        }
        .padding()
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}
