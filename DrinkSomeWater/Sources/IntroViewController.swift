//
//  IntroViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/18.
//

import UIKit
import SwiftUI

class IntroViewController: UIViewController {
 
 // MARK: - UI
 
 lazy var imageView: UIImageView = {
  let imageView = UIImageView()
  imageView.image = UIImage(named: "bang")
  return imageView
 }()
 
 
 // MARK: - LifeCycle
 
 override func viewDidLoad() {
  super.viewDidLoad()
  self.view.backgroundColor = #colorLiteral(red: 0.5876787901, green: 0.8308961987, blue: 0.9025848508, alpha: 1)
  self.setupConstraints()
  DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
   self.animate()
  }
 }
 
 override func viewWillAppear(_ animated: Bool) {
  super.viewWillAppear(animated)
  self.navigationController?.isNavigationBarHidden = true
 }
 
 override func viewWillDisappear(_ animated: Bool) {
  super.viewWillDisappear(animated)
  self.navigationController?.isNavigationBarHidden = false
 }
 
 
 // MARK: - SetupConstraints
 
 private func setupConstraints() {
  self.view.addSubview(self.imageView)
  self.imageView.snp.makeConstraints {
   $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
   $0.centerY.equalTo(self.view.safeAreaLayoutGuide.snp.centerY)
   $0.height.width.equalTo(240)
  }
 }
 
 
 // MARK: - Animate

 private func animate() {
  self.imageView.snp.remakeConstraints {
   $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
   $0.centerX.equalToSuperview()
   $0.width.height.equalTo(self.view.frame.height / 8)
  }

  UIView.animate(withDuration: 1.2, delay: 0.2, options: .curveEaseInOut) {
   self.view.layoutIfNeeded()
  } completion: { done in
   if done {
    Task {
     await self.checkUpdateAndProceed()
    }
   }
  }
 }

 private func checkUpdateAndProceed() async {
  let updateChecker = AppUpdateChecker()
  let updateType = await updateChecker.checkForUpdate()

  switch updateType {
  case .force(let message, let storeUrl):
   showForceUpdateAlert(message: message, storeUrl: storeUrl)

  case .optional(let message, let storeUrl):
   showOptionalUpdateAlert(message: message, storeUrl: storeUrl)

  case .none:
   navigateToMain()
  }
 }

 private func showForceUpdateAlert(message: String, storeUrl: String) {
  let alert = UIAlertController(
   title: String(localized: "update.required.title"),
   message: message,
   preferredStyle: .alert
  )

  alert.addAction(UIAlertAction(
   title: String(localized: "update.now"),
   style: .default
  ) { [weak self] _ in
   self?.openAppStore(urlString: storeUrl)
   self?.showForceUpdateAlert(message: message, storeUrl: storeUrl)
  })

  present(alert, animated: true)
 }

 private func showOptionalUpdateAlert(message: String, storeUrl: String) {
  let alert = UIAlertController(
   title: String(localized: "update.available.title"),
   message: message,
   preferredStyle: .alert
  )

  alert.addAction(UIAlertAction(
   title: String(localized: "update.later"),
   style: .cancel
  ) { [weak self] _ in
   self?.navigateToMain()
  })

  alert.addAction(UIAlertAction(
   title: String(localized: "update.now"),
   style: .default
  ) { [weak self] _ in
   self?.openAppStore(urlString: storeUrl)
   self?.navigateToMain()
  })

  present(alert, animated: true)
 }

 private func openAppStore(urlString: String) {
  guard let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) else { return }
  UIApplication.shared.open(url)
 }

 private func navigateToMain() {
  DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
   let serviceProvider = ServiceProvider()
   let mainTabView = MainTabView(serviceProvider: serviceProvider)
   let hostingController = UIHostingController(rootView: mainTabView)
   hostingController.modalPresentationStyle = .fullScreen

   if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
    let window = windowScene.windows.first {
    window.rootViewController = hostingController
    window.makeKeyAndVisible()
    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
   }
  }
 }
}
