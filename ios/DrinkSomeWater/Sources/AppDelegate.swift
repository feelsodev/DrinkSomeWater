import UIKit
import GoogleMobileAds
import Analytics
import StoreKit

#if canImport(FirebaseCore)
import FirebaseCore
#endif

@MainActor
class AppDelegate: UIResponder, UIApplicationDelegate {
  var transactionListenerTask: Task<Void, Error>?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    #if canImport(FirebaseCore)
    FirebaseApp.configure()
    #endif
    Analytics.shared.configure()
    Analytics.shared.logAppOpen()
    AdMobService.shared.configure()
    
    let center = UNUserNotificationCenter.current()
    center.delegate = self
    
    // Start transaction listener for external purchases/renewals/cancellations
    transactionListenerTask = listenForTransactions()
    print("[StoreKit] Transaction listener started")
    
    return true
  }
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
  }
  
  private func listenForTransactions() -> Task<Void, Error> {
    Task.detached {
      for await result in Transaction.updates {
        await self.handleTransactionUpdate(result)
      }
    }
  }
  
  @MainActor
  private func handleTransactionUpdate(_ result: VerificationResult<Transaction>) async {
    switch result {
    case .verified(let transaction):
      NotificationCenter.default.post(name: NSNotification.Name("TransactionUpdated"), object: nil)
      await transaction.finish()
    case .unverified:
      break
    @unknown default:
      break
    }
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    transactionListenerTask?.cancel()
  }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    completionHandler([.banner, .list, .badge, .sound])
  }
}
