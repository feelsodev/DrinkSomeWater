import UIKit

final class MainTabBarController: UITabBarController {
    
    private let serviceProvider: ServiceProviderProtocol
    
    init(serviceProvider: ServiceProviderProtocol) {
        self.serviceProvider = serviceProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        tabBar.unselectedItemTintColor = .darkGray
        
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupViewControllers() {
        let homeVC = createHomeTab()
        let historyVC = createHistoryTab()
        let settingsVC = createSettingsTab()
        
        viewControllers = [homeVC, historyVC, settingsVC]
    }
    
    private func createHomeTab() -> UINavigationController {
        let store = HomeStore(provider: serviceProvider)
        let vc = HomeViewController(store: store)
        vc.tabBarItem = UITabBarItem(
            title: "오늘",
            image: UIImage(systemName: "drop"),
            selectedImage: UIImage(systemName: "drop.fill")
        )
        return UINavigationController(rootViewController: vc)
    }
    
    private func createHistoryTab() -> UINavigationController {
        let store = HistoryStore(provider: serviceProvider)
        let vc = HistoryViewController(store: store)
        vc.tabBarItem = UITabBarItem(
            title: "기록",
            image: UIImage(systemName: "calendar"),
            selectedImage: UIImage(systemName: "calendar.circle.fill")
        )
        return UINavigationController(rootViewController: vc)
    }
    
    private func createSettingsTab() -> UINavigationController {
        let store = SettingsStore(provider: serviceProvider)
        let vc = SettingsViewController(store: store)
        vc.tabBarItem = UITabBarItem(
            title: "설정",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        return UINavigationController(rootViewController: vc)
    }
}
