import UIKit
import GoogleMobileAds
import Analytics

@MainActor
final class AdMobService: NSObject {
  
  static var shared: AdMobService!
  
  static func configure(storeKitService: StoreKitServiceProtocol) {
    shared = AdMobService(storeKitService: storeKitService)
  }
  
  private enum AdUnitID {
    static var banner: String {
      Bundle.main.object(forInfoDictionaryKey: "ADMOB_BANNER_ID") as? String ?? ""
    }
    static var rewarded: String {
      Bundle.main.object(forInfoDictionaryKey: "ADMOB_REWARDED_ID") as? String ?? ""
    }
    static var native: String {
      Bundle.main.object(forInfoDictionaryKey: "ADMOB_NATIVE_ID") as? String ?? ""
    }
  }
  
  private let storeKitService: StoreKitServiceProtocol
  private var rewardedAd: GADRewardedAd?
  private var isRewardedAdLoading = false
  
  private var nativeAdLoader: NativeAdLoader?
  private var rewardedCompletion: (@MainActor (Bool) -> Void)?
  private var didEarnReward = false
  
  init(storeKitService: StoreKitServiceProtocol) {
    self.storeKitService = storeKitService
  }
  
  func configure() {
    GADMobileAds.sharedInstance().start { status in
      print("[AdMob] SDK initialized: \(status.adapterStatusesByClassName)")
    }
    loadRewardedAd()
    preloadNativeAds(count: 3)
  }
  
  func createBannerView(rootViewController: UIViewController) -> GADBannerView {
    let bannerView = GADBannerView(adSize: GADAdSizeBanner)
    bannerView.adUnitID = AdUnitID.banner
    bannerView.rootViewController = rootViewController
    
    guard !storeKitService.isPremium else {
      print("[AdMob] Skipping banner - user is premium")
      return bannerView
    }
    
    bannerView.load(GADRequest())
    return bannerView
  }
  
  func loadRewardedAd() {
    guard !isRewardedAdLoading else { return }
    isRewardedAdLoading = true
    
    Task {
      do {
        rewardedAd = try await GADRewardedAd.load(withAdUnitID: AdUnitID.rewarded, request: GADRequest())
        print("[AdMob] Rewarded ad loaded successfully")
      } catch {
        print("[AdMob] Failed to load rewarded ad: \(error.localizedDescription)")
      }
      isRewardedAdLoading = false
    }
  }
  
  var isRewardedAdReady: Bool {
    rewardedAd != nil
  }
  
  func showRewardedAd(from viewController: UIViewController, completion: @escaping @MainActor (Bool) -> Void) {
    guard !storeKitService.isPremium else {
      print("[AdMob] Skipping rewarded ad - user is premium")
      completion(false)
      return
    }
    
    guard let rewardedAd = rewardedAd else {
      print("[AdMob] Rewarded ad not ready")
      completion(false)
      loadRewardedAd()
      return
    }
    
    didEarnReward = false
    rewardedCompletion = completion
    
    Analytics.shared.log(.rewardedAdStarted(rewardType: "support"))
    rewardedAd.fullScreenContentDelegate = self
    rewardedAd.present(fromRootViewController: viewController) { [weak self] in
      let reward = rewardedAd.adReward
      print("[AdMob] User earned reward: \(reward.amount) \(reward.type)")
      Analytics.shared.log(.rewardedAdCompleted(rewardType: reward.type, rewardAmount: reward.amount.intValue))
      self?.didEarnReward = true
    }
  }
  
  func preloadNativeAds(count: Int) {
    nativeAdLoader = NativeAdLoader(adUnitID: AdUnitID.native, numberOfAds: count)
    nativeAdLoader?.load()
  }
  
  func getNativeAd() -> GADNativeAd? {
    guard !storeKitService.isPremium else {
      print("[AdMob] Skipping native ad - user is premium")
      return nil
    }
    
    guard let ad = nativeAdLoader?.getAd() else {
      preloadNativeAds(count: 2)
      return nil
    }
    if (nativeAdLoader?.adCount ?? 0) < 2 {
      preloadNativeAds(count: 2)
    }
    return ad
  }
  
  var hasNativeAd: Bool {
    (nativeAdLoader?.adCount ?? 0) > 0
  }
}

extension AdMobService: GADFullScreenContentDelegate {
  nonisolated func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
    Task { @MainActor in
      rewardedCompletion?(didEarnReward)
      rewardedCompletion = nil
      rewardedAd = nil
      loadRewardedAd()
    }
  }
  
  nonisolated func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
    Task { @MainActor in
      print("[AdMob] Rewarded ad failed to present: \(error.localizedDescription)")
      rewardedCompletion?(false)
      rewardedCompletion = nil
      rewardedAd = nil
      loadRewardedAd()
    }
  }
}

final class NativeAdLoader: NSObject, GADNativeAdLoaderDelegate {
  private var adLoader: GADAdLoader?
  private var loadedAds: [GADNativeAd] = []
  private let adUnitID: String
  private let numberOfAds: Int
  
  init(adUnitID: String, numberOfAds: Int) {
    self.adUnitID = adUnitID
    self.numberOfAds = numberOfAds
    super.init()
  }
  
  func load() {
    let options = GADMultipleAdsAdLoaderOptions()
    options.numberOfAds = numberOfAds
    
    adLoader = GADAdLoader(
      adUnitID: adUnitID,
      rootViewController: nil,
      adTypes: [.native],
      options: [options]
    )
    adLoader?.delegate = self
    adLoader?.load(GADRequest())
  }
  
  func getAd() -> GADNativeAd? {
    guard !loadedAds.isEmpty else { return nil }
    return loadedAds.removeFirst()
  }
  
  var adCount: Int {
    loadedAds.count
  }
  
  func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
    loadedAds.append(nativeAd)
    print("[AdMob] Native ad loaded. Total: \(loadedAds.count)")
    let adUnitIDCopy = adUnitID
    Task { @MainActor in
      Analytics.shared.log(.adImpression(adType: .native, adUnitId: adUnitIDCopy, screen: "preload"))
    }
  }
  
  func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
    print("[AdMob] Failed to load native ad: \(error.localizedDescription)")
    let adUnitIDCopy = adUnitID
    Task { @MainActor in
      Analytics.shared.recordError(error, context: ["ad_type": "native", "ad_unit_id": adUnitIDCopy])
    }
  }
}
