import UIKit

/// Minimal AppDelegate for test environment.
/// Does not initialize Firebase, AdMob, Analytics, or other services
/// that may cause crashes in CI environments.
@MainActor
class TestAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Create minimal window for tests
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIViewController()
        window?.makeKeyAndVisible()
        return true
    }
}
