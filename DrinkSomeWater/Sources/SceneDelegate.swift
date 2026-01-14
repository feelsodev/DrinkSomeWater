import UIKit
import WidgetKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  private var serviceProvider: ServiceProvider!
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    self.window = UIWindow(windowScene: windowScene)
    self.window?.overrideUserInterfaceStyle = .light
    self.serviceProvider = ServiceProvider()
    
    if serviceProvider.userDefaultsService.value(forkey: .goal) == nil {
      serviceProvider.userDefaultsService.set(value: 2000, forkey: .goal)
    }
    
    let settings = serviceProvider.notificationService.loadSettings()
    serviceProvider.notificationService.scheduleNotifications(with: settings)

    serviceProvider.watchConnectivityService.activate()

    syncWidgetDataOnLaunch(serviceProvider: serviceProvider)
    
    let isOnboardingCompleted = serviceProvider.userDefaultsService.value(forkey: .onboardingCompleted) ?? false
    
    if isOnboardingCompleted {
      let intro = IntroViewController(serviceProvider: serviceProvider)
      let navIntro = UINavigationController(rootViewController: intro)
      window?.rootViewController = navIntro
    } else {
      let onboardingStore = OnboardingStore(provider: serviceProvider)
      let onboardingVC = OnboardingViewController(store: onboardingStore)
      window?.rootViewController = onboardingVC
    }
    
    window?.makeKeyAndVisible()
  }
  
  private func syncWidgetDataOnLaunch(serviceProvider: ServiceProvider) {
    Task {
      if let pendingWater = WidgetDataManager.shared.checkPendingWaterFromWidget() {
        _ = await serviceProvider.waterService.updateWater(by: Float(pendingWater))
      }

      let records = await serviceProvider.waterService.fetchWater()
      let goal = await serviceProvider.waterService.fetchGoal()
      let todayWater = records.first(where: { $0.date.checkToday })?.value ?? 0

      WidgetDataManager.shared.syncFromMainApp(todayWater: todayWater, goal: goal)
      serviceProvider.watchConnectivityService.syncToWatch(todayWater: todayWater, goal: goal)
    }
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
  }
}


