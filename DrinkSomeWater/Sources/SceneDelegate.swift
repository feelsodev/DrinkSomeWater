import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        let serviceProvider = ServiceProvider()
        
        if serviceProvider.userDefaultsService.value(forkey: .goal) == nil {
            serviceProvider.userDefaultsService.set(value: 1500, forkey: .goal)
        }
        
        let settings = serviceProvider.notificationService.loadSettings()
        serviceProvider.notificationService.scheduleNotifications(with: settings)
        
        let intro = IntroViewController()
        let navIntro = UINavigationController(rootViewController: intro)
        window?.rootViewController = navIntro
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}


