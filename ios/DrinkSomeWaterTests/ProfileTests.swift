import XCTest
@testable import DrinkSomeWater

final class ProfileTests: XCTestCase {
    
    func testUserProfileRecommendedIntake() {
        // given
        let profile1 = UserProfile(weight: 70, useHealthKitWeight: false)
        let profile2 = UserProfile(weight: 50, useHealthKitWeight: false)
        let profile3 = UserProfile(weight: 100, useHealthKitWeight: false)
        
        // then
        XCTAssertEqual(profile1.recommendedIntake, 2310)
        XCTAssertEqual(profile2.recommendedIntake, 1650)
        XCTAssertEqual(profile3.recommendedIntake, 3300)
    }
    
    func testUserProfileDefault() {
        // given
        let profile = UserProfile.default
        
        // then
        XCTAssertEqual(profile.weight, 65)
        XCTAssertEqual(profile.useHealthKitWeight, false)
        XCTAssertEqual(profile.recommendedIntake, 2145)
    }
    
    func testNotificationMessagesNotEmpty() {
        // then
        XCTAssertFalse(NotificationMessages.messages.isEmpty)
        XCTAssertEqual(NotificationMessages.messages.count, 10)
    }
    
    func testNotificationMessagesRandomReturnsValidMessage() {
        // when
        let randomMessage = NotificationMessages.random
        
        // then
        XCTAssertTrue(NotificationMessages.messages.contains(randomMessage))
    }
}
