import Testing
import Foundation
@testable import DrinkSomeWater

@Suite("ReviewEligibilityService")
@MainActor
struct ReviewEligibilityServiceTests {
    
    @Test func recordGoalCompletionIncrementsCount() {
        let mockDefaults = MockUserDefaultsService()
        let service = ReviewEligibilityService(userDefaultsService: mockDefaults)
        
        service.recordGoalCompletion()
        #expect(service.goalCompletionCount == 1)
        
        service.recordGoalCompletion()
        #expect(service.goalCompletionCount == 2)
    }
    
    @Test func setInstallDateOnFirstInit() {
        let mockDefaults = MockUserDefaultsService()
        #expect(mockDefaults.value(forkey: .reviewInstallDate) == nil)
        
        _ = ReviewEligibilityService(userDefaultsService: mockDefaults)
        
        let installDate: Double? = mockDefaults.value(forkey: .reviewInstallDate)
        #expect(installDate != nil)
    }
    
    @Test func setInstallDateOnlyOnce() {
        let mockDefaults = MockUserDefaultsService()
        let earlyTimestamp: Double = Date().timeIntervalSince1970 - 86400 * 30
        mockDefaults.set(value: earlyTimestamp, forkey: .reviewInstallDate)
        
        _ = ReviewEligibilityService(userDefaultsService: mockDefaults)
        
        let storedTimestamp: Double? = mockDefaults.value(forkey: .reviewInstallDate)
        #expect(storedTimestamp == earlyTimestamp)
    }
    
    @Test func shouldRequestReviewReturnsFalseWhenCountBelowThreshold() {
        let mockDefaults = MockUserDefaultsService()
        mockDefaults.set(value: Date().timeIntervalSince1970 - 86400 * 30, forkey: .reviewInstallDate)
        mockDefaults.set(value: 2, forkey: .reviewGoalCompletionCount)
        
        let service = ReviewEligibilityService(userDefaultsService: mockDefaults)
        
        #expect(service.shouldRequestReview() == false)
    }
    
    @Test func shouldRequestReviewReturnsFalseWhenInstallTooRecent() {
        let mockDefaults = MockUserDefaultsService()
        mockDefaults.set(value: Date().timeIntervalSince1970 - 86400 * 3, forkey: .reviewInstallDate)
        mockDefaults.set(value: 5, forkey: .reviewGoalCompletionCount)
        
        let service = ReviewEligibilityService(userDefaultsService: mockDefaults)
        
        #expect(service.shouldRequestReview() == false)
    }
    
    @Test func shouldRequestReviewReturnsFalseWhenCooldownNotElapsed() {
        let mockDefaults = MockUserDefaultsService()
        mockDefaults.set(value: Date().timeIntervalSince1970 - 86400 * 30, forkey: .reviewInstallDate)
        mockDefaults.set(value: 5, forkey: .reviewGoalCompletionCount)
        mockDefaults.set(value: Date().timeIntervalSince1970 - 86400 * 5, forkey: .reviewLastRequestDate)
        
        let service = ReviewEligibilityService(userDefaultsService: mockDefaults)
        
        #expect(service.shouldRequestReview() == false)
    }
    
    @Test func shouldRequestReviewReturnsFalseWhenSameVersionAlreadyPrompted() {
        let mockDefaults = MockUserDefaultsService()
        mockDefaults.set(value: Date().timeIntervalSince1970 - 86400 * 30, forkey: .reviewInstallDate)
        mockDefaults.set(value: 5, forkey: .reviewGoalCompletionCount)
        mockDefaults.set(value: "1.0.0", forkey: .reviewLastPromptedVersion)
        
        let service = ReviewEligibilityService(userDefaultsService: mockDefaults, currentVersion: "1.0.0")
        
        #expect(service.shouldRequestReview() == false)
    }
    
    @Test func shouldRequestReviewReturnsTrueWhenAllConditionsMet() {
        let mockDefaults = MockUserDefaultsService()
        mockDefaults.set(value: Date().timeIntervalSince1970 - 86400 * 30, forkey: .reviewInstallDate)
        mockDefaults.set(value: 5, forkey: .reviewGoalCompletionCount)
        
        let service = ReviewEligibilityService(userDefaultsService: mockDefaults, currentVersion: "2.0.0")
        
        #expect(service.shouldRequestReview() == true)
    }
    
    @Test func shouldRequestReviewReturnsTrueWhenCooldownElapsed() {
        let mockDefaults = MockUserDefaultsService()
        mockDefaults.set(value: Date().timeIntervalSince1970 - 86400 * 30, forkey: .reviewInstallDate)
        mockDefaults.set(value: 5, forkey: .reviewGoalCompletionCount)
        mockDefaults.set(value: Date().timeIntervalSince1970 - 86400 * 15, forkey: .reviewLastRequestDate)
        mockDefaults.set(value: "1.0.0", forkey: .reviewLastPromptedVersion)
        
        let service = ReviewEligibilityService(userDefaultsService: mockDefaults, currentVersion: "2.0.0")
        
        #expect(service.shouldRequestReview() == true)
    }
    
    @Test func markReviewRequestedSetsDateAndVersion() {
        let mockDefaults = MockUserDefaultsService()
        let service = ReviewEligibilityService(userDefaultsService: mockDefaults, currentVersion: "3.0.0")
        
        service.markReviewRequested()
        
        let lastDate: Double? = mockDefaults.value(forkey: .reviewLastRequestDate)
        let lastVersion: String? = mockDefaults.value(forkey: .reviewLastPromptedVersion)
        #expect(lastDate != nil)
        #expect(lastVersion == "3.0.0")
    }
}
