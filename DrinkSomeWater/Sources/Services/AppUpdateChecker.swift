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
      let defaultMessage = NSLocalizedString(
        "update.force.message",
        value: "새로운 버전이 출시되었습니다. 계속 사용하려면 업데이트가 필요합니다.",
        comment: "Force update message"
      )
      return .force(
        message: config.forceUpdateMessage ?? defaultMessage,
        storeUrl: config.appStoreUrl
      )
    }

    if currentVersion < latestVersion {
      let defaultMessage = NSLocalizedString(
        "update.optional.message",
        value: "새로운 버전이 출시되었습니다. 지금 업데이트하시겠습니까?",
        comment: "Optional update message"
      )
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
      title: NSLocalizedString("update.available.title", value: "업데이트 안내", comment: "Update available title"),
      message: message,
      preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(
      title: NSLocalizedString("update.later", value: "나중에", comment: "Later button"),
      style: .cancel
    ))

    alert.addAction(UIAlertAction(
      title: NSLocalizedString("update.now", value: "업데이트", comment: "Update button"),
      style: .default
    ) { _ in
      self.openAppStore(urlString: storeUrl)
    })

    viewController.present(alert, animated: true)
  }

  private func showForceUpdateAlert(on viewController: UIViewController, message: String, storeUrl: String) {
    let alert = UIAlertController(
      title: NSLocalizedString("update.required.title", value: "업데이트 필요", comment: "Update required title"),
      message: message,
      preferredStyle: .alert
    )

    alert.addAction(UIAlertAction(
      title: NSLocalizedString("update.now", value: "업데이트", comment: "Update button"),
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
