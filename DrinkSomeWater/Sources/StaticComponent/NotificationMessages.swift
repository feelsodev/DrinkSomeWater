import Foundation

enum NotificationMessages {
    
    static let messages: [String] = [
        "물 마실 시간이에요! 💧",
        "수분 보충 잊지 마세요~ 🌊",
        "건강한 하루의 시작, 물 한잔! ☀️",
        "목이 마르기 전에 마셔요 🥤",
        "오늘도 벌컥벌컥! 💪",
        "물 한 잔이 피로를 씻어줘요 🧘",
        "촉촉한 피부의 비결, 물! ✨",
        "집중력 UP! 물 한 잔 어때요? 🧠",
        "잠깐! 물 마시고 하세요 🚰",
        "당신의 몸이 물을 기다려요 🌿"
    ]
    
    static var random: String {
        messages.randomElement() ?? messages[0]
    }
}
