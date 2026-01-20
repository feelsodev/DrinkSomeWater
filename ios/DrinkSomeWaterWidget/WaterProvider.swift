import WidgetKit
import Foundation

struct WaterProvider: TimelineProvider {
  
  func placeholder(in context: Context) -> WaterEntry {
    WaterEntry.placeholder
  }
  
  func getSnapshot(in context: Context, completion: @escaping (WaterEntry) -> Void) {
    let entry = createEntry()
    completion(entry)
  }
  
  func getTimeline(in context: Context, completion: @escaping (Timeline<WaterEntry>) -> Void) {
    let entry = createEntry()
    let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
    let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
    completion(timeline)
  }
  
  private func createEntry() -> WaterEntry {
    let manager = WidgetDataManager.shared
    return WaterEntry(
      date: Date(),
      todayWater: manager.todayWater,
      goal: manager.goal
    )
  }
}
