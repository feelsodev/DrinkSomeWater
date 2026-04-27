import SwiftUI
import UIKit

struct MainTabView: View {

  private let serviceProvider: ServiceProviderProtocol

  init(serviceProvider: ServiceProviderProtocol) {
    self.serviceProvider = serviceProvider
    configureTabBarAppearance()
  }

  var body: some View {
    TabView {
      Tab(L.Tab.today, systemImage: "drop.fill") {
        HomeView(store: HomeStore(provider: serviceProvider))
      }

      Tab(L.Tab.history, systemImage: "calendar") {
        HistoryView(store: HistoryStore(provider: serviceProvider))
      }

      Tab(L.Tab.settings, systemImage: "gearshape") {
        SettingsViewControllerRepresentable(store: SettingsStore(provider: serviceProvider))
          .ignoresSafeArea()
      }
    }
    .tint(Color(red: 0.259, green: 0.757, blue: 0.969))
  }

  private func configureTabBarAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithDefaultBackground()
    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
    UITabBar.appearance().unselectedItemTintColor = .gray
  }
}

struct SettingsViewControllerRepresentable: UIViewControllerRepresentable {

  let store: SettingsStore

  func makeUIViewController(context: Context) -> UINavigationController {
    let vc = SettingsViewController(store: store)
    let nav = UINavigationController(rootViewController: vc)
    nav.isNavigationBarHidden = true
    return nav
  }

  func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
  }
}
