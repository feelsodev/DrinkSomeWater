import WidgetKit
import SwiftUI

struct DrinkSomeWaterWidget: Widget {
    let kind: String = "DrinkSomeWaterWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WaterProvider()) { entry in
            DrinkSomeWaterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Water Intake")
        .description("Track your daily water intake")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
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
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            LockScreenCircularView(entry: entry)
        case .accessoryRectangular:
            LockScreenRectangularView(entry: entry)
        case .accessoryInline:
            LockScreenInlineView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

@main
struct DrinkSomeWaterWidgetBundle: WidgetBundle {
    var body: some Widget {
        DrinkSomeWaterWidget()
    }
}
