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
    $0.textColor = .black
  }
  lazy var slider = UISlider().then {
    $0.maximumValue = 3000
    $0.minimumValue = 1500
    $0.tintColor = .darkGray
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
    
    // State
    reactor.state.asObservable()
      .map { "\($0.value)" }
      .distinctUntilChanged()
      .bind(to: self.goalWater.rx.text)
      .disposed(by: self.disposeBag)
  }
  
  override func setupConstraints() {
    [self.goalWater, self.slider].forEach { self.view.addSubview($0) }
    
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
  }
}
