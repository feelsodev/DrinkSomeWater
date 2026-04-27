import WidgetKit
import SwiftUI

struct WaterComplicationEntry: TimelineEntry {
  let date: Date
  let todayWater: Int
  let goal: Int
  let isSubscribed: Bool

  var progress: Float {
    guard goal > 0 else { return 0 }
    return min(Float(todayWater) / Float(goal), 1.0)
  }

  var progressPercent: Int {
    Int(progress * 100)
  }
}

struct WaterComplicationProvider: TimelineProvider {
  func placeholder(in context: Context) -> WaterComplicationEntry {
    WaterComplicationEntry(date: Date(), todayWater: 1200, goal: 2000, isSubscribed: true)
  }

  func getSnapshot(in context: Context, completion: @escaping (WaterComplicationEntry) -> Void) {
    let entry = WaterComplicationEntry(
      date: Date(),
      todayWater: loadTodayWater(),
      goal: loadGoal(),
      isSubscribed: loadIsSubscribed()
    )
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<WaterComplicationEntry>) -> Void) {
    let entry = WaterComplicationEntry(
      date: Date(),
      todayWater: loadTodayWater(),
      goal: loadGoal(),
      isSubscribed: loadIsSubscribed()
    )

    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
  }

  private func loadTodayWater() -> Int {
    UserDefaults.standard.integer(forKey: "watch_today_water")
  }

  private func loadGoal() -> Int {
    let goal = UserDefaults.standard.integer(forKey: "watch_goal")
    return goal > 0 ? goal : 2000
  }
  
  private func loadIsSubscribed() -> Bool {
    let defaults = UserDefaults.standard
    let isLifetime = defaults.bool(forKey: "watch_is_lifetime")
    if isLifetime { return true }
    
    guard defaults.bool(forKey: "watch_is_subscribed") else { return false }
    guard let expiration = defaults.object(forKey: "watch_subscription_expiration") as? Date else { return false }
    return expiration > Date()
  }
}

struct CircularComplicationView: View {
  let entry: WaterComplicationEntry

  var body: some View {
    if entry.isSubscribed {
      Gauge(value: entry.progress) {
        Image(systemName: "drop.fill")
      } currentValueLabel: {
        Text("\(entry.progressPercent)%")
          .font(.system(size: 12, weight: .semibold, design: .rounded))
      }
      .gaugeStyle(.accessoryCircular)
      .tint(.blue)
    } else {
      Gauge(value: 0) {
        Image(systemName: "lock.fill")
      } currentValueLabel: {
        Text("--")
          .font(.system(size: 12, weight: .semibold, design: .rounded))
      }
      .gaugeStyle(.accessoryCircular)
      .tint(.gray)
    }
  }
}

struct RectangularComplicationView: View {
  let entry: WaterComplicationEntry

  var body: some View {
    if entry.isSubscribed {
      HStack(spacing: 8) {
        Gauge(value: entry.progress) {
          EmptyView()
        }
        .gaugeStyle(.accessoryLinearCapacity)
        .tint(.blue)

        VStack(alignment: .trailing, spacing: 0) {
          Text("\(entry.todayWater)")
            .font(.system(size: 14, weight: .bold, design: .rounded))
          Text("/ \(entry.goal)ml")
            .font(.system(size: 10))
            .foregroundStyle(.secondary)
        }
      }
    } else {
      HStack(spacing: 8) {
        Image(systemName: "lock.fill")
          .foregroundStyle(.gray)
        Text(String(localized: "watch.locked.title"))
          .font(.system(size: 12, design: .rounded))
          .foregroundStyle(.secondary)
      }
    }
  }
}

struct CornerComplicationView: View {
  let entry: WaterComplicationEntry

  var body: some View {
    if entry.isSubscribed {
      ZStack {
        AccessoryWidgetBackground()
        VStack(spacing: 0) {
          Image(systemName: "drop.fill")
            .font(.system(size: 16))
          Text("\(entry.progressPercent)%")
            .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(.blue)
      }
      .widgetLabel {
        Text("\(entry.todayWater)ml")
      }
    } else {
      ZStack {
        AccessoryWidgetBackground()
        Image(systemName: "lock.fill")
          .font(.system(size: 20))
          .foregroundStyle(.gray)
      }
      .widgetLabel {
        Text("--")
      }
    }
  }
}

struct WaterComplication: Widget {
  let kind: String = "WaterComplication"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: WaterComplicationProvider()) { entry in
      ComplicationEntryView(entry: entry)
    }
    .configurationDisplayName(String(localized: "complication.displayname"))
    .description(String(localized: "complication.description"))
    .supportedFamilies([
      .accessoryCircular,
      .accessoryRectangular,
      .accessoryCorner,
      .accessoryInline
    ])
  }
}

struct ComplicationEntryView: View {
  @Environment(\.widgetFamily) var family
  let entry: WaterComplicationEntry

  var body: some View {
    switch family {
    case .accessoryCircular:
      CircularComplicationView(entry: entry)
    case .accessoryRectangular:
      RectangularComplicationView(entry: entry)
    case .accessoryCorner:
      CornerComplicationView(entry: entry)
    case .accessoryInline:
      if entry.isSubscribed {
        Text("\(entry.todayWater)ml / \(entry.goal)ml")
      } else {
        Text("🔒 --")
      }
    default:
      CircularComplicationView(entry: entry)
    }
  }
}

#Preview("Circular", as: .accessoryCircular) {
  WaterComplication()
} timeline: {
  WaterComplicationEntry(date: Date(), todayWater: 1200, goal: 2000, isSubscribed: true)
}

#Preview("Rectangular", as: .accessoryRectangular) {
  WaterComplication()
} timeline: {
  WaterComplicationEntry(date: Date(), todayWater: 1200, goal: 2000, isSubscribed: true)
}
