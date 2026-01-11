import Foundation

struct AppUpdateConfig: Codable {
  let minimumVersion: String
  let latestVersion: String
  let forceUpdateMessage: String?
  let optionalUpdateMessage: String?
  let appStoreUrl: String

  enum CodingKeys: String, CodingKey {
    case minimumVersion = "minimum_version"
    case latestVersion = "latest_version"
    case forceUpdateMessage = "force_update_message"
    case optionalUpdateMessage = "optional_update_message"
    case appStoreUrl = "app_store_url"
  }

  static let `default` = AppUpdateConfig(
    minimumVersion: "1.0.0",
    latestVersion: "1.0.0",
    forceUpdateMessage: nil,
    optionalUpdateMessage: nil,
    appStoreUrl: "https://apps.apple.com"
  )
}
