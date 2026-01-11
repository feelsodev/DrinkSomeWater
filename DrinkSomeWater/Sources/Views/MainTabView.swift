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
      Tab("오늘", systemImage: "drop.fill") {
        HomeView(store: HomeStore(provider: serviceProvider))
      }

      Tab("기록", systemImage: "calendar") {
        HistoryView(store: HistoryStore(provider: serviceProvider))
      }

      Tab("설정", systemImage: "gearshape") {
        SettingsViewControllerRepresentable(store: SettingsStore(provider: serviceProvider))
          .ignoresSafeArea()
      }
    }
    .tint(Color(red: 0.259, green: 0.757, blue: 0.969))
  }

  private func configureTabBarAppearance() {
    let appearance = UITabBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
    UITabBar.appearance().unselectedItemTintColor = .darkGray
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
