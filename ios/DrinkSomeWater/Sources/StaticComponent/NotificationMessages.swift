import Foundation

enum NotificationMessages {

  static let messages: [String] = [
    String(localized: "notification.message.1"),
    String(localized: "notification.message.2"),
    String(localized: "notification.message.3"),
    String(localized: "notification.message.4"),
    String(localized: "notification.message.5"),
    String(localized: "notification.message.6"),
    String(localized: "notification.message.7"),
    String(localized: "notification.message.8"),
    String(localized: "notification.message.9"),
    String(localized: "notification.message.10")
  ]

  static var random: String {
    messages.randomElement() ?? messages[0]
  }
}
