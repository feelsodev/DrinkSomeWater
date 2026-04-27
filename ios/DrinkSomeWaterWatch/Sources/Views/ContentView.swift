import SwiftUI

struct ContentView: View {
  @Environment(WatchStore.self) private var store

  var body: some View {
    if store.isSubscribed {
      NavigationStack {
        TabView {
          HomeView()
          QuickAddView()
        }
        .tabViewStyle(.verticalPage)
      }
    } else {
      WatchLockedView()
    }
  }
}

#Preview {
  ContentView()
    .environment(WatchStore())
}
