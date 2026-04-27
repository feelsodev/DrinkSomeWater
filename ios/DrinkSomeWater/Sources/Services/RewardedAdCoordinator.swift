import UIKit

@MainActor
protocol RewardedAdCoordinatorProtocol: AnyObject {
    func showRewardedAd() async -> Bool
    func setRootViewController(_ viewController: UIViewController)
}

@MainActor
final class RewardedAdCoordinator: RewardedAdCoordinatorProtocol {
    private weak var rootViewController: UIViewController?
    
    func setRootViewController(_ viewController: UIViewController) {
        self.rootViewController = viewController
    }
    
    func showRewardedAd() async -> Bool {
        guard let vc = rootViewController else { return true }
        return await withCheckedContinuation { continuation in
            AdMobService.shared.showRewardedAd(from: vc) { success in
                continuation.resume(returning: success)
            }
        }
    }
}
