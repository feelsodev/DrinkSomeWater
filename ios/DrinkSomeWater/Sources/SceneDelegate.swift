import UIKit
import SwiftUI
import WidgetKit

extension Notification.Name {
  static let cloudDataDidChange = Notification.Name("cloudDataDidChange")
}

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
    
    setupCloudSyncObserver()

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
    
    if let rootVC = window?.rootViewController {
      serviceProvider.rewardedAdCoordinator.setRootViewController(rootVC)
    }
  }
  
  private func setupCloudSyncObserver() {
    serviceProvider.cloudSyncService.startObservingChanges { [weak self] in
      guard let self else { return }
      Task { @MainActor in
        await self.handleCloudDataChange()
      }
    }
    
    serviceProvider.cloudSyncService.startObservingErrors { [weak self] error in
      guard let self else { return }
      self.handleCloudSyncError(error)
    }
  }
  
  private var lastErrorAlertTime: Date?
  private let errorAlertThrottleInterval: TimeInterval = 60
  
  private func handleCloudSyncError(_ error: CloudSyncError) {
    if let lastTime = lastErrorAlertTime,
       Date().timeIntervalSince(lastTime) < errorAlertThrottleInterval {
      return
    }
    
    let title: String
    let message: String
    
     switch error {
     case .quotaViolation:
       title = L.ICloud.errorQuotaTitle
       message = L.ICloud.errorQuotaMessage
     case .accountChanged:
       title = L.ICloud.errorAccountTitle
       message = L.ICloud.errorAccountMessage
     }
    
    guard let windowScene = window?.windowScene,
          let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
      return
    }
    
    var presentingVC = rootVC
    while let presented = presentingVC.presentedViewController {
      if presented is UIAlertController {
        return
      }
      presentingVC = presented
    }
    
     lastErrorAlertTime = Date()
     
     let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
     alert.addAction(UIAlertAction(title: L.Common.confirm, style: .default))
     presentingVC.present(alert, animated: true)
  }
  
  private func handleCloudDataChange() async {
    let cloudGoal = serviceProvider.cloudSyncService.loadGoal()
    let cloudTodayRecord = serviceProvider.cloudSyncService.loadTodayRecord()
    
    let goal = cloudGoal ?? (serviceProvider.userDefaultsService.value(forkey: .goal) ?? 2000)
    let todayWater = cloudTodayRecord?.value ?? 0
    
    WidgetDataManager.shared.syncFromMainApp(todayWater: todayWater, goal: goal)
    serviceProvider.watchConnectivityService.syncToWatch(todayWater: todayWater, goal: goal)
    
    NotificationCenter.default.post(name: .cloudDataDidChange, object: nil)
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
  
  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    guard let url = URLContexts.first?.url,
          url.scheme == "drinksomewater",
          url.host == "paywall" else { return }
    presentPaywall()
  }
  
  private func presentPaywall() {
    guard let rootVC = window?.rootViewController else { return }
    
    var topVC = rootVC
    while let presented = topVC.presentedViewController {
      topVC = presented
    }
    
    let premiumStore = PremiumStore(storeKitService: serviceProvider.storeKitService)
    let paywallView = PaywallView(premiumStore: premiumStore, triggerPoint: "deeplink")
    let hostingController = UIHostingController(rootView: paywallView)
    topVC.present(hostingController, animated: true)
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


