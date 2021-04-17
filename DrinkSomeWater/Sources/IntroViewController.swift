//
//  IntroViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/18.
//

import UIKit

class IntroViewController: UIViewController {
  let imageView = UIImageView().then {
    $0.image = UIImage(named: "bang")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = #colorLiteral(red: 0.5876787901, green: 0.8308961987, blue: 0.9025848508, alpha: 1)
    self.setupConstraints()
    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
      self.animate()
    }
  }
  
  private func setupConstraints() {
    self.view.addSubview(self.imageView)
    self.imageView.snp.makeConstraints {
      $0.centerX.equalTo(self.view.safeAreaLayoutGuide.snp.centerX)
      $0.centerY.equalTo(self.view.safeAreaLayoutGuide.snp.centerY)
      $0.height.width.equalTo(240)
    }
  }
  
  private func animate() {
    self.imageView.snp.remakeConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(self.view.frame.height / 8)
    }
    
    UIView.animate(withDuration: 2, delay: 1, options: .curveEaseInOut) {
      self.view.layoutIfNeeded()
    } completion: { done in
      if done {
        let serviceProvider = ServiceProvider()
        let mainReactor = MainViewReactor(provider: serviceProvider)
        let mainView = MainViewController(reactor: mainReactor)
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: false, completion: nil)
      }
    }
  }
}
