import Testing
import UIKit
@testable import DrinkSomeWater

@Suite("AdMobService Premium Gating Tests")
@MainActor
final class AdMobServiceTests {
  
  @Test("adService_whenPremium_doesNotLoadBanner")
  func adService_whenPremium_doesNotLoadBanner() async {
    let mockStoreKit = MockStoreKitService()
    mockStoreKit.mockIsPremium = true
    let adService = AdMobService(storeKitService: mockStoreKit)
    
    let mockViewController = UIViewController()
    let bannerView = adService.createBannerView(rootViewController: mockViewController)
    
    #expect(bannerView != nil)
  }
  
  @Test("adService_whenFree_loadsNormallyBanner")
  func adService_whenFree_loadsNormallyBanner() async {
    let mockStoreKit = MockStoreKitService()
    mockStoreKit.mockIsPremium = false
    let adService = AdMobService(storeKitService: mockStoreKit)
    
    let mockViewController = UIViewController()
    let bannerView = adService.createBannerView(rootViewController: mockViewController)
    
    #expect(bannerView != nil)
  }
  
  @Test("adService_whenPremium_doesNotShowRewardedAd")
  func adService_whenPremium_doesNotShowRewardedAd() async {
    let mockStoreKit = MockStoreKitService()
    mockStoreKit.mockIsPremium = true
    let adService = AdMobService(storeKitService: mockStoreKit)
    
    let mockViewController = UIViewController()
    var completionCalled = false
    var completionValue = false
    
    adService.showRewardedAd(from: mockViewController) { result in
      completionCalled = true
      completionValue = result
    }
    
    #expect(completionCalled == true)
    #expect(completionValue == false)
  }
  
  @Test("adService_whenFree_canShowRewardedAd")
  func adService_whenFree_canShowRewardedAd() async {
    let mockStoreKit = MockStoreKitService()
    mockStoreKit.mockIsPremium = false
    let adService = AdMobService(storeKitService: mockStoreKit)
    
    let mockViewController = UIViewController()
    var completionCalled = false
    
    adService.showRewardedAd(from: mockViewController) { result in
      completionCalled = true
    }
    
    #expect(completionCalled == true)
  }
  
  @Test("adService_whenPremium_getNativeAdReturnsNil")
  func adService_whenPremium_getNativeAdReturnsNil() async {
    let mockStoreKit = MockStoreKitService()
    mockStoreKit.mockIsPremium = true
    let adService = AdMobService(storeKitService: mockStoreKit)
    
    let nativeAd = adService.getNativeAd()
    
    #expect(nativeAd == nil)
  }
  
  @Test("adService_whenFree_getNativeAdCanReturnAd")
  func adService_whenFree_getNativeAdCanReturnAd() async {
    let mockStoreKit = MockStoreKitService()
    mockStoreKit.mockIsPremium = false
    let adService = AdMobService(storeKitService: mockStoreKit)
    
    let nativeAd = adService.getNativeAd()
    
    #expect(nativeAd == nil)
  }
  
  @Test("adService_hasNativeAd_whenPremium_returnsFalse")
  func adService_hasNativeAd_whenPremium_returnsFalse() async {
    let mockStoreKit = MockStoreKitService()
    mockStoreKit.mockIsPremium = true
    let adService = AdMobService(storeKitService: mockStoreKit)
    
    let hasAd = adService.hasNativeAd
    
    #expect(hasAd == false)
  }
  
  @Test("adService_isRewardedAdReady_whenPremium_stillReturnsState")
  func adService_isRewardedAdReady_whenPremium_stillReturnsState() async {
    let mockStoreKit = MockStoreKitService()
    mockStoreKit.mockIsPremium = true
    let adService = AdMobService(storeKitService: mockStoreKit)
    
    let isReady = adService.isRewardedAdReady
    
    #expect(isReady == false)
  }
  
  @Test("adService_switchPremiumStatus_affectsAdDisplay")
  func adService_switchPremiumStatus_affectsAdDisplay() async {
    let mockStoreKit = MockStoreKitService()
    mockStoreKit.mockIsPremium = false
    let adService = AdMobService(storeKitService: mockStoreKit)
    
    let nativeAd1 = adService.getNativeAd()
    #expect(nativeAd1 == nil)
    
    mockStoreKit.mockIsPremium = true
    let nativeAd2 = adService.getNativeAd()
    #expect(nativeAd2 == nil)
    
    mockStoreKit.mockIsPremium = false
    let nativeAd3 = adService.getNativeAd()
    #expect(nativeAd3 == nil)
  }
}
