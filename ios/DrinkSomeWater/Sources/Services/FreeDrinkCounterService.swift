import Foundation

@MainActor
protocol FreeDrinkCounterServiceProtocol: AnyObject {
    /// Records a drink action. Returns true if an ad should be shown (every Nth drink).
    func recordDrink() -> Bool
    /// Resets the counter (for testing or manual reset)
    func reset()
    /// Current drink count today
    var drinksToday: Int { get }
    /// How often to show ads (every N drinks)
    var adFrequency: Int { get }
}

@MainActor
final class FreeDrinkCounterService: FreeDrinkCounterServiceProtocol {
    private enum Keys {
        static let counterDate = "drink_counter_date"
        static let counterCount = "drink_counter_count"
        static let adFrequencyThreshold = "ad_frequency_threshold"
    }
    
    private let defaults: UserDefaults
    
    var drinksToday: Int {
        resetIfNewDay()
        return defaults.integer(forKey: Keys.counterCount)
    }
    
    var adFrequency: Int {
        let stored = defaults.integer(forKey: Keys.adFrequencyThreshold)
        return stored > 0 ? stored : 3  // default 3
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func recordDrink() -> Bool {
        resetIfNewDay()
        let newCount = defaults.integer(forKey: Keys.counterCount) + 1
        defaults.set(newCount, forKey: Keys.counterCount)
        return newCount % adFrequency == 0
    }
    
    func reset() {
        defaults.set(todayDateString(), forKey: Keys.counterDate)
        defaults.set(0, forKey: Keys.counterCount)
    }
    
    private func resetIfNewDay() {
        let storedDate = defaults.string(forKey: Keys.counterDate) ?? ""
        let today = todayDateString()
        if storedDate != today {
            defaults.set(today, forKey: Keys.counterDate)
            defaults.set(0, forKey: Keys.counterCount)
        }
    }
    
    private func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: Date())
    }
}
