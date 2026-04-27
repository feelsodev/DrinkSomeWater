import WidgetKit
import Foundation

struct WaterEntry: TimelineEntry {
  let date: Date
  let todayWater: Int
  let goal: Int
  let hasWidgetAccess: Bool
  
  var progress: Float {
    guard goal > 0 else { return 0 }
    return min(Float(todayWater) / Float(goal), 1.0)
  }
  
  var progressPercent: Int {
    Int(progress * 100)
  }
  
  var isGoalAchieved: Bool {
    todayWater >= goal
  }
  
  static var placeholder: WaterEntry {
    WaterEntry(date: Date(), todayWater: 1200, goal: 2000, hasWidgetAccess: true)
  }
  
  static var snapshot: WaterEntry {
    WaterEntry(date: Date(), todayWater: 1200, goal: 2000, hasWidgetAccess: true)
  }
}
