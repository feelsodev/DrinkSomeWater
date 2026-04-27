import WidgetKit
import SwiftUI

struct DrinkSomeWaterWidget: Widget {
  let kind: String = "DrinkSomeWaterWidget"
  
  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: WaterProvider()) { entry in
      DrinkSomeWaterWidgetEntryView(entry: entry)
    }
    .configurationDisplayName(String(localized: "widget.configuration.name"))
    .description(String(localized: "widget.configuration.description"))
    .supportedFamilies([
      .systemSmall,
      .systemMedium,
      .systemLarge,
      .accessoryCircular,
      .accessoryRectangular,
      .accessoryInline
    ])
  }
}

struct DrinkSomeWaterWidgetEntryView: View {
  @Environment(\.widgetFamily) var family
  let entry: WaterEntry
  
  var body: some View {
    if entry.hasWidgetAccess {
      switch family {
      case .systemSmall:
        SmallWidgetView(entry: entry)
      case .systemMedium:
        MediumWidgetView(entry: entry)
      case .systemLarge:
        LargeWidgetView(entry: entry)
      case .accessoryCircular:
        LockScreenCircularView(entry: entry)
      case .accessoryRectangular:
        LockScreenRectangularView(entry: entry)
      case .accessoryInline:
        LockScreenInlineView(entry: entry)
      default:
        SmallWidgetView(entry: entry)
      }
    } else {
      WidgetLockedView()
    }
  }
}

@main
struct DrinkSomeWaterWidgetBundle: WidgetBundle {
  var body: some Widget {
    DrinkSomeWaterWidget()
  }
}
