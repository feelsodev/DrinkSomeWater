import Testing
import Foundation
import UIKit
import SwiftUI
@testable import DrinkSomeWater

@Suite("SocialSharingService")
@MainActor
struct SocialSharingServiceTests {
    
    @Test func shareViaSystemSheetCallsServiceWithCorrectParameters() async throws {
        let mockService = MockSocialSharingService()
        
        let record = WaterRecord(
            date: Date(),
            value: 1500,
            isSuccess: true,
            goal: 2000
        )
        
        let viewController = UIViewController()
        try await mockService.shareViaSystemSheet(record: record, streak: 5, source: .home, from: viewController)
        
        #expect(mockService.shareViaSystemSheetCalled == true)
        #expect(mockService.lastSharedRecord?.value == 1500)
        #expect(mockService.lastSharedRecord?.goal == 2000)
        #expect(mockService.lastSharedStreak == 5)
        #expect(mockService.lastSharedSource == .home)
    }
    
    @Test func shareViaSystemSheetWithZeroPercentage() async throws {
        let mockService = MockSocialSharingService()
        
        let record = WaterRecord(
            date: Date(),
            value: 0,
            isSuccess: false,
            goal: 2000
        )
        
        let viewController = UIViewController()
        try await mockService.shareViaSystemSheet(record: record, streak: 0, source: .home, from: viewController)
        
        #expect(mockService.shareViaSystemSheetCalled == true)
        #expect(mockService.lastSharedRecord?.value == 0)
        #expect(mockService.lastSharedStreak == 0)
    }
    
    @Test func shareViaSystemSheetWithOverAchievedRecord() async throws {
        let mockService = MockSocialSharingService()
        
        let record = WaterRecord(
            date: Date(),
            value: 3000,
            isSuccess: true,
            goal: 2000
        )
        
        let viewController = UIViewController()
        try await mockService.shareViaSystemSheet(record: record, streak: 30, source: .history, from: viewController)
        
        #expect(mockService.shareViaSystemSheetCalled == true)
        #expect(mockService.lastSharedRecord?.value == 3000)
        #expect(mockService.lastSharedStreak == 30)
        #expect(mockService.lastSharedSource == .history)
    }
    
    @Test func shareViaSystemSheetThrowsErrorWhenConfigured() async {
        let mockService = MockSocialSharingService()
        mockService.shouldThrow = true
        
        let record = WaterRecord(
            date: Date(),
            value: 500,
            isSuccess: false,
            goal: 2000
        )
        
        let viewController = UIViewController()
        
        await #expect(throws: SocialSharingError.self) {
            try await mockService.shareViaSystemSheet(record: record, streak: 1, source: .home, from: viewController)
        }
    }
    
    @Test func shareViaSystemSheetThrowsImageRenderingError() async {
        let mockService = MockSocialSharingService()
        mockService.shouldThrow = true
        
        let record = WaterRecord(
            date: Date(),
            value: 1000,
            isSuccess: false,
            goal: 2000
        )
        
        let viewController = UIViewController()
        
        await #expect(throws: SocialSharingError.imageRenderingFailed) {
            try await mockService.shareViaSystemSheet(record: record, streak: 5, source: .home, from: viewController)
        }
    }
    
    @Test func shareViaSystemSheetMultipleCallsTrackingCorrectly() async throws {
        let mockService = MockSocialSharingService()
        
        let record1 = WaterRecord(date: Date(), value: 1000, isSuccess: false, goal: 2000)
        let record2 = WaterRecord(date: Date(), value: 2000, isSuccess: true, goal: 2000)
        
        let viewController = UIViewController()
        
        try await mockService.shareViaSystemSheet(record: record1, streak: 3, source: .home, from: viewController)
        #expect(mockService.lastSharedRecord?.value == 1000)
        #expect(mockService.lastSharedStreak == 3)
        
        try await mockService.shareViaSystemSheet(record: record2, streak: 7, source: .history, from: viewController)
        #expect(mockService.lastSharedRecord?.value == 2000)
        #expect(mockService.lastSharedStreak == 7)
        #expect(mockService.lastSharedSource == .history)
    }
    
    @Test func shareCardView_rendersToUIImage_successfully() {
        let record = WaterRecord(date: Date(), value: 1000, isSuccess: false, goal: 2000)
        let view = ShareCardView(record: record, streak: 5, style: .feed)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        let image = renderer.uiImage
        
        #expect(image != nil)
        #expect(image?.size.width == 1080)
        #expect(image?.size.height == 1080)
    }
    
    @Test func shareCardView_rendersCorrectly_for0PercentAchievement() {
        let record = WaterRecord(date: Date(), value: 0, isSuccess: false, goal: 2000)
        let view = ShareCardView(record: record, streak: 0, style: .feed)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        let image = renderer.uiImage
        
        #expect(image != nil)
        #expect(image?.size.width == 1080)
        #expect(image?.size.height == 1080)
    }
    
    @Test func shareCardView_rendersCorrectly_for100PercentAchievement() {
        let record = WaterRecord(date: Date(), value: 2000, isSuccess: true, goal: 2000)
        let view = ShareCardView(record: record, streak: 7, style: .feed)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        let image = renderer.uiImage
        
        #expect(image != nil)
        #expect(image?.size.width == 1080)
        #expect(image?.size.height == 1080)
    }
    
    @Test func shareCardView_rendersCorrectly_for150PercentAchievement() {
        let record = WaterRecord(date: Date(), value: 3000, isSuccess: true, goal: 2000)
        let view = ShareCardView(record: record, streak: 14, style: .feed)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        let image = renderer.uiImage
        
        #expect(image != nil)
        #expect(image?.size.width == 1080)
        #expect(image?.size.height == 1080)
    }
}
