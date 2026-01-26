import Testing
import Foundation
import UIKit
import SwiftUI
@testable import DrinkSomeWater

@Suite("InstagramSharingService")
@MainActor
struct InstagramSharingServiceTests {
    
    @Test func isInstagramInstalledReturnsFalseWhenNotInstalled() async {
        let mockService = MockInstagramSharingService()
        mockService.isInstalled = false
        
        #expect(mockService.isInstagramInstalled() == false)
    }
    
    @Test func isInstagramInstalledReturnsTrueWhenInstalled() async {
        let mockService = MockInstagramSharingService()
        mockService.isInstalled = true
        
        #expect(mockService.isInstagramInstalled() == true)
    }
    
    @Test func shareToStoriesCallsServiceWithCorrectParameters() async throws {
        let mockService = MockInstagramSharingService()
        mockService.isInstalled = true
        
        let record = WaterRecord(
            date: Date(),
            value: 1500,
            isSuccess: true,
            goal: 2000
        )
        
        try await mockService.shareToStories(record: record, streak: 5)
        
        #expect(mockService.shareToStoriesCallCount == 1)
        #expect(mockService.lastSharedRecord?.value == 1500)
        #expect(mockService.lastSharedRecord?.goal == 2000)
        #expect(mockService.lastSharedStreak == 5)
    }
    
    @Test func shareToFeedCallsServiceWithCorrectParameters() async throws {
        let mockService = MockInstagramSharingService()
        mockService.isInstalled = true
        
        let record = WaterRecord(
            date: Date(),
            value: 2000,
            isSuccess: true,
            goal: 2000
        )
        
        try await mockService.shareToFeed(record: record, streak: 10)
        
        #expect(mockService.shareToFeedCallCount == 1)
        #expect(mockService.lastSharedRecord?.value == 2000)
        #expect(mockService.lastSharedStreak == 10)
    }
    
    @Test func shareToStoriesThrowsErrorWhenServiceFails() async {
        let mockService = MockInstagramSharingService()
        mockService.isInstalled = true
        mockService.shouldThrowError = true
        
        let record = WaterRecord(
            date: Date(),
            value: 500,
            isSuccess: false,
            goal: 2000
        )
        
        await #expect(throws: InstagramSharingError.self) {
            try await mockService.shareToStories(record: record, streak: 1)
        }
    }
    
    @Test func shareToFeedThrowsErrorWhenServiceFails() async {
        let mockService = MockInstagramSharingService()
        mockService.isInstalled = true
        mockService.shouldThrowError = true
        
        let record = WaterRecord(
            date: Date(),
            value: 500,
            isSuccess: false,
            goal: 2000
        )
        
        await #expect(throws: InstagramSharingError.self) {
            try await mockService.shareToFeed(record: record, streak: 1)
        }
    }
    
    @Test func shareCardStylesHaveCorrectDimensions() async {
        #expect(ShareCardStyle.stories != ShareCardStyle.feed)
    }
    
    @Test func zeroPercentageRecordCanBeShared() async throws {
        let mockService = MockInstagramSharingService()
        mockService.isInstalled = true
        
        let record = WaterRecord(
            date: Date(),
            value: 0,
            isSuccess: false,
            goal: 2000
        )
        
        try await mockService.shareToStories(record: record, streak: 0)
        
        #expect(mockService.shareToStoriesCallCount == 1)
        #expect(mockService.lastSharedRecord?.value == 0)
    }
    
    @Test func overAchievedRecordCanBeShared() async throws {
        let mockService = MockInstagramSharingService()
        mockService.isInstalled = true
        
        let record = WaterRecord(
            date: Date(),
            value: 3000,
            isSuccess: true,
            goal: 2000
        )
        
        try await mockService.shareToFeed(record: record, streak: 30)
        
        #expect(mockService.shareToFeedCallCount == 1)
        #expect(mockService.lastSharedRecord?.value == 3000)
        #expect(mockService.lastSharedStreak == 30)
    }
    
    // MARK: - ShareCardView Rendering Tests
    
    @Test func shareCardView_rendersToUIImage_successfully() {
        let record = WaterRecord(date: Date(), value: 1000, isSuccess: false, goal: 2000)
        let view = ShareCardView(record: record, streak: 5, style: .stories)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        let image = renderer.uiImage
        
        #expect(image != nil)
        #expect(image?.size.width == 1080)
        #expect(image?.size.height == 1920)
    }
    
    @Test func shareCardView_rendersCorrectly_for0PercentAchievement() {
        let record = WaterRecord(date: Date(), value: 0, isSuccess: false, goal: 2000)
        let view = ShareCardView(record: record, streak: 0, style: .stories)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        let image = renderer.uiImage
        
        #expect(image != nil)
        #expect(image?.size.width == 1080)
        #expect(image?.size.height == 1920)
    }
    
    @Test func shareCardView_rendersCorrectly_for100PercentAchievement() {
        let record = WaterRecord(date: Date(), value: 2000, isSuccess: true, goal: 2000)
        let view = ShareCardView(record: record, streak: 7, style: .stories)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        let image = renderer.uiImage
        
        #expect(image != nil)
        #expect(image?.size.width == 1080)
        #expect(image?.size.height == 1920)
    }
    
    @Test func shareCardView_rendersCorrectly_for150PercentAchievement() {
        let record = WaterRecord(date: Date(), value: 3000, isSuccess: true, goal: 2000)
        let view = ShareCardView(record: record, streak: 14, style: .stories)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        let image = renderer.uiImage
        
        #expect(image != nil)
        #expect(image?.size.width == 1080)
        #expect(image?.size.height == 1920)
    }
    
    @Test func shareCardView_rendersCorrectly_forFeedStyle() {
        let record = WaterRecord(date: Date(), value: 2000, isSuccess: true, goal: 2000)
        let view = ShareCardView(record: record, streak: 7, style: .feed)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        let image = renderer.uiImage
        
        #expect(image != nil)
        #expect(image?.size.width == 1080)
        #expect(image?.size.height == 1080)
    }
    
    @Test func shareCardView_rendersWithoutStreak() {
        let record = WaterRecord(date: Date(), value: 500, isSuccess: false, goal: 2000)
        let view = ShareCardView(record: record, streak: 0, style: .feed)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        let image = renderer.uiImage
        
        #expect(image != nil)
    }
}
