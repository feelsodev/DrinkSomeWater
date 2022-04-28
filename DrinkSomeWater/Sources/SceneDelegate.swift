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
  
  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let scene = (scene as? UIWindowScene) else { return }
    
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.setNotification()
    let serviceProvider = ServiceProvider()
    
    // 최초 앱 설치시 값이 목표 용량치가 없을 경우 1500으로 초기화
    if serviceProvider.userDefaultsService.value(forkey: .goal) == nil {
      serviceProvider.userDefaultsService.set(value: 1500, forkey: .goal)
    }
    
    let intro = IntroViewController()
    let navIntro = UINavigationController(rootViewController: intro)
    window?.rootViewController = navIntro
    window?.windowScene = scene
    window?.makeKeyAndVisible()
  }
  
  func sceneDidDisconnect(_ scene: UIScene) { }
  
  func sceneDidBecomeActive(_ scene: UIScene) { }
  
  func sceneWillResignActive(_ scene: UIScene) { }
  
  func sceneWillEnterForeground(_ scene: UIScene) { }
  
  func sceneDidEnterBackground(_ scene: UIScene) { }
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
