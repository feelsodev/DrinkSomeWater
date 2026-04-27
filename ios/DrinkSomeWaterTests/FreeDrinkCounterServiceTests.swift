import Foundation
import Testing
@testable import DrinkSomeWater

@Suite("FreeDrinkCounterService")
@MainActor
struct FreeDrinkCounterServiceTests {
    private let testSuiteName = "test.drinkCounter"
    
    private func makeTestDefaults() -> UserDefaults {
        UserDefaults(suiteName: testSuiteName)!
    }
    
    private func cleanupDefaults() {
        if let defaults = UserDefaults(suiteName: testSuiteName) {
            defaults.removePersistentDomain(forName: testSuiteName)
        }
    }
    
    @Test
    func test_initialState_zeroCount() {
        defer { cleanupDefaults() }
        let defaults = makeTestDefaults()
        let service = FreeDrinkCounterService(defaults: defaults)
        
        #expect(service.drinksToday == 0)
    }
    
    @Test
    func test_recordDrink_incrementsCount() {
        defer { cleanupDefaults() }
        let defaults = makeTestDefaults()
        let service = FreeDrinkCounterService(defaults: defaults)
        
        service.recordDrink()
        #expect(service.drinksToday == 1)
        
        service.recordDrink()
        #expect(service.drinksToday == 2)
        
        service.recordDrink()
        #expect(service.drinksToday == 3)
    }
    
    @Test
    func test_recordDrink_returnsTrueEveryThirdDrink() {
        defer { cleanupDefaults() }
        let defaults = makeTestDefaults()
        let service = FreeDrinkCounterService(defaults: defaults)
        
        let result1 = service.recordDrink()
        #expect(result1 == false)
        
        let result2 = service.recordDrink()
        #expect(result2 == false)
        
        let result3 = service.recordDrink()
        #expect(result3 == true)
        
        let result4 = service.recordDrink()
        #expect(result4 == false)
        
        let result5 = service.recordDrink()
        #expect(result5 == false)
        
        let result6 = service.recordDrink()
        #expect(result6 == true)
    }
    
    @Test
    func test_reset_clearsCount() {
        defer { cleanupDefaults() }
        let defaults = makeTestDefaults()
        let service = FreeDrinkCounterService(defaults: defaults)
        
        service.recordDrink()
        service.recordDrink()
        #expect(service.drinksToday == 2)
        
        service.reset()
        #expect(service.drinksToday == 0)
    }
    
    @Test
    func test_dailyReset_newDay() {
        defer { cleanupDefaults() }
        let defaults = makeTestDefaults()
        let service = FreeDrinkCounterService(defaults: defaults)
        
        service.recordDrink()
        service.recordDrink()
        #expect(service.drinksToday == 2)
        
        let yesterday = Date(timeIntervalSinceNow: -86400)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let yesterdayString = formatter.string(from: yesterday)
        defaults.set(yesterdayString, forKey: "drink_counter_date")
        
        #expect(service.drinksToday == 0)
    }
    
    @Test
    func test_configurableAdFrequency() {
        defer { cleanupDefaults() }
        let defaults = makeTestDefaults()
        defaults.set(5, forKey: "ad_frequency_threshold")
        let service = FreeDrinkCounterService(defaults: defaults)
        
        #expect(service.adFrequency == 5)
        
        let result1 = service.recordDrink()
        #expect(result1 == false)
        
        let result2 = service.recordDrink()
        #expect(result2 == false)
        
        let result3 = service.recordDrink()
        #expect(result3 == false)
        
        let result4 = service.recordDrink()
        #expect(result4 == false)
        
        let result5 = service.recordDrink()
        #expect(result5 == true)
    }
    
    @Test
    func test_defaultAdFrequency_isThree() {
        defer { cleanupDefaults() }
        let defaults = makeTestDefaults()
        let service = FreeDrinkCounterService(defaults: defaults)
        
        #expect(service.adFrequency == 3)
    }
}
