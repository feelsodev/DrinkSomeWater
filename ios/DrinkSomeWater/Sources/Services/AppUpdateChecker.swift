import UIKit

enum UpdateType {
  case none
  case optional(message: String, storeUrl: String)
  case force(message: String, storeUrl: String)
}

@MainActor
final class AppUpdateChecker {

  private let remoteConfigService: RemoteConfigServiceProtocol

  init(remoteConfigService: RemoteConfigServiceProtocol = RemoteConfigService.shared) {
    self.remoteConfigService = remoteConfigService
  }

  func checkForUpdate() async -> UpdateType {
    do {
      try await remoteConfigService.fetchConfig()
    } catch {
      print("Failed to fetch remote config: \(error)")
      return .none
    }

    guard let currentVersion = AppVersion.current else {
      return .none
    }

    let config = remoteConfigService.getAppUpdateConfig()

    guard let minimumVersion = AppVersion(string: config.minimumVersion),
          let latestVersion = AppVersion(string: config.latestVersion) else {
      return .none
    }

    if currentVersion < minimumVersion {
       let defaultMessage = L.Update.requiredMessage
       return .force(
         message: config.forceUpdateMessage ?? defaultMessage,
         storeUrl: config.appStoreUrl
       )
     }

     if currentVersion < latestVersion {
       let defaultMessage = L.Update.availableMessage
       return .optional(
         message: config.optionalUpdateMessage ?? defaultMessage,
         storeUrl: config.appStoreUrl
       )
     }

    return .none
  }

  func showUpdateAlertIfNeeded(on viewController: UIViewController) async {
    let updateType = await checkForUpdate()

    switch updateType {
    case .none:
      break

    case .optional(let message, let storeUrl):
      showOptionalUpdateAlert(on: viewController, message: message, storeUrl: storeUrl)

    case .force(let message, let storeUrl):
      showForceUpdateAlert(on: viewController, message: message, storeUrl: storeUrl)
    }
  }

   private func showOptionalUpdateAlert(on viewController: UIViewController, message: String, storeUrl: String) {
     let alert = UIAlertController(
       title: L.Update.availableTitle,
       message: message,
       preferredStyle: .alert
     )

     alert.addAction(UIAlertAction(
       title: L.Update.later,
       style: .cancel
     ))

     alert.addAction(UIAlertAction(
       title: L.Update.now,
       style: .default
     ) { _ in
       self.openAppStore(urlString: storeUrl)
     })

     viewController.present(alert, animated: true)
   }

   private func showForceUpdateAlert(on viewController: UIViewController, message: String, storeUrl: String) {
     let alert = UIAlertController(
       title: L.Update.requiredTitle,
       message: message,
       preferredStyle: .alert
     )

     alert.addAction(UIAlertAction(
       title: L.Update.now,
       style: .default
     ) { _ in
       self.openAppStore(urlString: storeUrl)
       self.showForceUpdateAlert(on: viewController, message: message, storeUrl: storeUrl)
     })

     viewController.present(alert, animated: true)
   }

  private func openAppStore(urlString: String) {
    guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else {
      return
    }
    UIApplication.shared.open(url)
  }
}
