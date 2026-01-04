import SwiftUI
import WidgetKit

struct LockScreenCircularView: View {
    let entry: WaterEntry
    
    var body: some View {
        Gauge(value: entry.progress) {
            Image(systemName: "drop.fill")
        } currentValueLabel: {
            Text("\(entry.progressPercent)")
                .font(.system(size: 12, weight: .bold, design: .rounded))
        }
        .gaugeStyle(.accessoryCircular)
    }
}

struct LockScreenRectangularView: View {
    let entry: WaterEntry
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "drop.fill")
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(entry.todayWater)ml")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                Text("/ \(entry.goal)ml")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Text("\(entry.progressPercent)%")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
        }
    }
}

struct LockScreenInlineView: View {
    let entry: WaterEntry
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "drop.fill")
            Text("\(entry.todayWater)/\(entry.goal)ml")
        }
    }
}
