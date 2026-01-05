import UIKit
import GoogleMobileAds

@MainActor
final class AdMobService {
  
  static let shared = AdMobService()
  
  // MARK: - Test Ad Unit IDs (Replace with real IDs for production)
  private enum AdUnitID {
    static let banner = "ca-app-pub-3940256099942544/2934735716"
    static let rewarded = "ca-app-pub-3940256099942544/1712485313"
  }
  
  private var rewardedAd: GADRewardedAd?
  private var isRewardedAdLoading = false
  
  private init() {}
  
  // MARK: - SDK Initialization
  
  func configure() {
    GADMobileAds.sharedInstance().start { status in
      print("[AdMob] SDK initialized: \(status.adapterStatusesByClassName)")
    }
    loadRewardedAd()
  }
  
  // MARK: - Banner Ad
  
  func createBannerView(rootViewController: UIViewController) -> GADBannerView {
    let bannerView = GADBannerView(adSize: GADAdSizeBanner)
    bannerView.adUnitID = AdUnitID.banner
    bannerView.rootViewController = rootViewController
    bannerView.load(GADRequest())
    return bannerView
  }
  
  // MARK: - Rewarded Ad
  
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
    guard let rewardedAd = rewardedAd else {
      print("[AdMob] Rewarded ad not ready")
      completion(false)
      loadRewardedAd()
      return
    }
    
    rewardedAd.present(fromRootViewController: viewController) { [weak self] in
      let reward = rewardedAd.adReward
      print("[AdMob] User earned reward: \(reward.amount) \(reward.type)")
      completion(true)
      self?.rewardedAd = nil
      self?.loadRewardedAd()
    }
  }
}
