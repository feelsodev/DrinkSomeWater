import Foundation
import FirebaseRemoteConfig

enum RemoteConfigKey: String {
  case appUpdate = "app_update"
}

protocol RemoteConfigServiceProtocol: Sendable {
  func fetchConfig() async throws
  func getAppUpdateConfig() -> AppUpdateConfig
}

final class RemoteConfigService: RemoteConfigServiceProtocol, @unchecked Sendable {

  static let shared = RemoteConfigService()

  private let remoteConfig: RemoteConfig
  private let decoder = JSONDecoder()

  private init() {
    self.remoteConfig = RemoteConfig.remoteConfig()

    let settings = RemoteConfigSettings()
    #if DEBUG
    settings.minimumFetchInterval = 0
    #else
    settings.minimumFetchInterval = 3600
    #endif
    remoteConfig.configSettings = settings

    let defaultJson = """
    {
      "minimum_version": "1.0.0",
      "latest_version": "1.0.0",
      "force_update_message": null,
      "optional_update_message": null,
      "app_store_url": "https://apps.apple.com"
    }
    """
    remoteConfig.setDefaults([
      RemoteConfigKey.appUpdate.rawValue: defaultJson as NSObject
    ])
  }

  func fetchConfig() async throws {
    let status = try await remoteConfig.fetch()
    if status == .success {
      try await remoteConfig.activate()
    }
  }

  func getAppUpdateConfig() -> AppUpdateConfig {
    let jsonString = remoteConfig.configValue(forKey: RemoteConfigKey.appUpdate.rawValue).stringValue

    guard let data = jsonString.data(using: .utf8),
          let config = try? decoder.decode(AppUpdateConfig.self, from: data) else {
      return .default
    }

    return config
  }
}
