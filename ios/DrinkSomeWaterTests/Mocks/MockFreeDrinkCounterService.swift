import Foundation
@testable import DrinkSomeWater

@MainActor
final class MockFreeDrinkCounterService: FreeDrinkCounterServiceProtocol {
    var mockDrinksToday: Int = 0
    var mockAdFrequency: Int = 3
    var mockShouldShowAd: Bool = false
    var recordDrinkCalled = false
    var resetCalled = false
    
    var drinksToday: Int { mockDrinksToday }
    var adFrequency: Int { mockAdFrequency }
    
    func recordDrink() -> Bool {
        recordDrinkCalled = true
        mockDrinksToday += 1
        return mockShouldShowAd
    }
    
    func reset() {
        resetCalled = true
        mockDrinksToday = 0
    }
}
