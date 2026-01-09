import SwiftUI

struct ContentView: View {
  @Environment(WatchStore.self) private var store

  var body: some View {
    NavigationStack {
      TabView {
        HomeView()
        QuickAddView()
      }
      .tabViewStyle(.verticalPage)
    }
  }
}

#Preview {
  ContentView()
    .environment(WatchStore())
}
