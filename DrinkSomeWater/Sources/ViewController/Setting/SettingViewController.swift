//
//  SettingViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/30.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift

final class SettingViewController: BaseViewController, View {
  
  let goalWater = UILabel().then {
    $0.font = .systemFont(ofSize: 20, weight: .medium)
    $0.textColor = .darkGray
  }
  let slider = UISlider().then {
    $0.maximumValue = 3000
    $0.minimumValue = 1500
    $0.tintColor = .darkGray
  }
  let setButton = UIButton().then {
    $0.setTitle("Set", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .black
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
  }
  
  init(reactor: SettingViewReactor) {
    super.init()
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bind(reactor: SettingViewReactor) {
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.loadGoal }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.slider.rx.value
      .map { Int($0) }
      .map { Reactor.Action.changeGoalWater($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.setButton.rx.tap
      .map { Reactor.Action.setGoal }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.asObservable()
      .map { "\($0.value) ml" }
      .distinctUntilChanged()
      .bind(to: self.goalWater.rx.text)
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable()
      .map { $0.shouldDismissed }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe { [weak self] _ in
        self?.dismiss(animated: true, completion: nil)
      }
      .disposed(by: self.disposeBag)
  }
  
  override func setupConstraints() {
    [self.goalWater, self.slider, self.setButton].forEach { self.view.addSubview($0) }
    
    self.goalWater.snp.makeConstraints {
      $0.top.equalToSuperview().offset(100)
      $0.centerX.equalToSuperview()
    }
    self.slider.snp.makeConstraints {
      $0.top.equalTo(self.goalWater.snp.bottom).offset(50)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(230)
      $0.height.equalTo(40)
    }
    self.setButton.snp.makeConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(100)
      $0.height.equalTo(40)
    }
  }
}
