//
//  SceneDelegate.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/16.
//

import UIKit
import RxViewController

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }
    
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.setNotification()
    let serviceProvider = ServiceProvider()
    
    // 최초 앱 설치시 값이 목표 용량치가 없을 경우 1500으로 초기화
    if serviceProvider.userDefaultsService.value(forkey: .goal) == nil {
      serviceProvider.userDefaultsService.set(value: 1500, forkey: .goal)
    }
    let intro = IntroViewController()
    window?.rootViewController = intro
    window?.windowScene = scene
    window?.makeKeyAndVisible()
  }
  
  func sceneDidDisconnect(_ scene: UIScene) {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
  }
  
  func sceneDidBecomeActive(_ scene: UIScene) {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
  }
  
  func sceneWillResignActive(_ scene: UIScene) {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
  }
  
  func sceneWillEnterForeground(_ scene: UIScene) {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
  }
  
  func sceneDidEnterBackground(_ scene: UIScene) {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
  }
}

extension SceneDelegate {
  private func setNotification() {
    let userNotificationCenter = UNUserNotificationCenter.current()
    let notificationContent = UNMutableNotificationContent()
    
    notificationContent.title = "벌컥벌컥"
    notificationContent.body = "오늘 하루 물 마시면서 건강을 찾아봐요!!"
        
    var dateComponents = DateComponents()
    dateComponents.calendar = Calendar.current
    dateComponents.hour = 9
    dateComponents.minute = 30
    
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents,
                                                repeats: true)
    
    let request = UNNotificationRequest(identifier: "drink",
                                        content: notificationContent,
                                        trigger: trigger)

    userNotificationCenter.add(request) { error in
      if let error = error {
        print("Notification Error: ", error)
      }
    }
  }
}
