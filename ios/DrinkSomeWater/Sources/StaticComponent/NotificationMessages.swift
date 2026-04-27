import Foundation

enum NotificationMessages {

  static let messages: [String] = [
     L.NotificationMessage.message1,
     L.NotificationMessage.message2,
     L.NotificationMessage.message3,
     L.NotificationMessage.message4,
     L.NotificationMessage.message5,
     L.NotificationMessage.message6,
     L.NotificationMessage.message7,
     L.NotificationMessage.message8,
     L.NotificationMessage.message9,
     L.NotificationMessage.message10,
     L.NotificationMessage.message11,
     L.NotificationMessage.message12,
     L.NotificationMessage.message13,
     L.NotificationMessage.message14,
     L.NotificationMessage.message15,
     L.NotificationMessage.message16,
     L.NotificationMessage.message17,
     L.NotificationMessage.message18,
     L.NotificationMessage.message19,
     L.NotificationMessage.message20
   ]

  static var random: String {
    messages.randomElement() ?? messages[0]
  }
}
