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
import WaveAnimationView

final class SettingViewController: BaseViewController, View {
  deinit { self.waveBackground.stopAnimation() }
  
  
  // MARK: - UI
  
  let firstBeakerLine = Beaker(ml: "2000")
  let secondBeakerLine = Beaker(ml: "2500")
  let thirdBeakerLine = Beaker(ml: "3000")
  let backButton = UIButton().then {
    $0.tintColor = .black
    $0.setImage(UIImage(systemName: "arrow.left")?
                  .withConfiguration(UIImage.SymbolConfiguration(weight: .regular)), for: .normal)
    $0.contentVerticalAlignment = .fill
    $0.contentHorizontalAlignment = .fill
    $0.imageEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
    $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    $0.layer.shadowOpacity = 1.0
    $0.layer.shadowRadius = 0.0
    $0.layer.masksToBounds = false
    $0.layer.cornerRadius = 4.0
  }
  
  let moreButton = UIButton().then {
    $0.tintColor = .white
    $0.setImage(UIImage(systemName: "exclamationmark.circle.fill")?
                  .withConfiguration(UIImage.SymbolConfiguration(weight: .regular)), for: .normal)
    $0.contentVerticalAlignment = .fill
    $0.contentHorizontalAlignment = .fill
    $0.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
    $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    $0.layer.shadowOpacity = 1.0
    $0.layer.shadowRadius = 0.0
    $0.layer.masksToBounds = false
    $0.layer.cornerRadius = 4.0
  }
  
  let lineView = UIView().then {
    $0.backgroundColor = .black
  }
  
  let goalWater = UILabel().then {
    $0.font = .systemFont(ofSize: 40, weight: .medium)
    $0.textColor = .darkGray
  }
  
  let slider = UISlider().then {
    $0.maximumValue = 3000
    $0.minimumValue = 1500
    $0.tintColor = .darkGray
  }
  
  let setButton = UIButton().then {
    $0.setTitle("SET", for: .normal)
    $0.setTitleColor(.white, for: .normal)
    $0.backgroundColor = .black
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
  }
  
  let waveBackground = WaveAnimationView(
    frame: CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width,
      height: UIScreen.main.bounds.height
    ),
    frontColor: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),
    backColor: #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
  ).then {
    $0.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    $0.startAnimation()
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
    
    self.backButton.rx.tap
      .map { Reactor.Action.cancel }
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
      .map { $0.progress }
      .distinctUntilChanged()
      .bind(to: self.waveBackground.rx.setProgress)
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable()
      .map { Float($0.value) }
      .distinctUntilChanged()
      .subscribe(onNext: { [weak self] value in
        guard let `self` = self else { return }
        self.slider.value = value
      })
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable()
      .map { $0.shouldDismissed }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe { [weak self] _ in
        guard let `self` = self else { return }
        self.dismiss(animated: true, completion: nil)
      }
      .disposed(by: self.disposeBag)
  }
  
  override func setupConstraints() {
    self.view.addSubview(self.waveBackground)
    [self.backButton, self.moreButton, self.firstBeakerLine, self.secondBeakerLine, self.thirdBeakerLine,
     self.lineView, self.goalWater, self.slider, self.setButton]
      .forEach { self.waveBackground.addSubview($0) }
    
    self.backButton.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
      $0.leading.equalToSuperview().offset(10)
      $0.width.height.equalTo(50)
    }
    self.moreButton.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
      $0.trailing.equalToSuperview().offset(-10)
      $0.width.height.equalTo(50)
    }
    self.goalWater.snp.makeConstraints {
      $0.top.equalToSuperview().offset(100)
      $0.centerX.equalToSuperview()
    }
    self.slider.snp.makeConstraints {
      $0.top.equalTo(self.goalWater.snp.bottom).offset(50)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(230)
      $0.height.equalTo(70)
    }
    self.setButton.snp.makeConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(100)
      $0.height.equalTo(40)
    }
    self.firstBeakerLine.snp.makeConstraints {
      $0.bottom.equalTo(self.view.snp.bottom).offset(-(self.viewHeight / 6))
      $0.trailing.equalToSuperview().offset(-20)
      $0.height.equalTo(5)
      $0.width.equalTo(80)
    }
    self.secondBeakerLine.snp.makeConstraints {
      $0.bottom.equalTo(self.view.snp.bottom).offset(-(self.viewHeight / 3))
      $0.trailing.equalToSuperview().offset(-20)
      $0.height.equalTo(5)
      $0.width.equalTo(80)
    }
    self.thirdBeakerLine.snp.makeConstraints {
      $0.bottom.equalTo(self.view.snp.bottom).offset(-(self.viewHeight / 2))
      $0.trailing.equalToSuperview().offset(-20)
      $0.height.equalTo(5)
      $0.width.equalTo(80)
    }
    self.lineView.snp.makeConstraints {
      $0.bottom.equalTo(self.view.snp.bottom).offset(-(self.viewHeight / 6))
      $0.trailing.equalToSuperview().offset(-20)
      $0.width.equalTo(5)
      $0.height.equalTo(self.viewHeight / 3)
    }
  }
}
