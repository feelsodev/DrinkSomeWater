import SwiftUI
import WidgetKit

struct LockScreenCircularView: View {
  let entry: WaterEntry
  
  var body: some View {
    Gauge(value: entry.progress) {
      Image(systemName: entry.isGoalAchieved ? "checkmark" : "drop.fill")
        .font(.system(size: 12))
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
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        HStack(spacing: 4) {
          Image(systemName: "drop.fill")
            .font(.system(size: 10))
          Text(String(localized: "widget.current.hydration"))
            .font(.system(size: 10, weight: .medium))
            .textCase(.uppercase)
        }
        .opacity(0.8)
        
        HStack(alignment: .firstTextBaseline, spacing: 4) {
          Text("\(entry.todayWater)")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .minimumScaleFactor(0.8)
          
          Text("/ \(entry.goal)")
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .opacity(0.6)
            .padding(.bottom, 2)
        }
      }
      
      Spacer()
      
      if entry.isGoalAchieved {
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 20))
      } else {
        Gauge(value: entry.progress) {
          EmptyView()
        }
        .gaugeStyle(.accessoryCircularCapacity)
        .frame(width: 24, height: 24)
      }
    }
  }
}

struct LockScreenInlineView: View {
  let entry: WaterEntry
  
  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "drop.fill")
      Text("\(entry.todayWater)ml")
        .font(.body.monospacedDigit())
      Text("•")
      Text("\(entry.progressPercent)%")
        .bold()
    }
  }
}
