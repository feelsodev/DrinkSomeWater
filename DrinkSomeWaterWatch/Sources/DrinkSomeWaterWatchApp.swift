import SwiftUI
import WatchConnectivity

@main
struct DrinkSomeWaterWatchApp: App {
  @State private var store = WatchStore()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environment(store)
    }
  }
}
