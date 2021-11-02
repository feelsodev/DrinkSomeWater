//
//  DrinkViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/16.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift
import RxGesture
import WaveAnimationView

final class DrinkViewController: BaseViewController, View {
  deinit {
    self.cup.stopAnimation()
    self.waveBackground.stopAnimation()
  }
  
  // MARK: Constants
  
  struct Metric {
    static let height = UIScreen.main.bounds.height * 0.37
  }
  
  
  // MARK: - UI
  
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
  
  let addWater = UIButton().then {
    $0.tintColor = .blue
    $0.setImage(UIImage(systemName: "plus.circle")?
                  .withConfiguration(UIImage.SymbolConfiguration(weight: .regular)), for: .normal)
    $0.contentVerticalAlignment = .fill
    $0.contentHorizontalAlignment = .fill
    $0.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    $0.layer.masksToBounds = true
  }
  
  let subWater = UIButton().then {
    $0.tintColor = .red
    $0.backgroundColor = .clear
    $0.setImage(UIImage(systemName: "minus.circle")?
                  .withConfiguration(UIImage.SymbolConfiguration(weight: .regular)), for: .normal)
    $0.contentVerticalAlignment = .fill
    $0.contentHorizontalAlignment = .fill
    $0.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
  }
  
  let lid = UIView().then {
    $0.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
  }
  
  let cup = WaveAnimationView(
    frame: CGRect(
      x: 0,
      y: 0,
      width: UIScreen.main.bounds.width * 0.5,
      height: UIScreen.main.bounds.height * 0.37),
    color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
  ).then {
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.startAnimation()
    $0.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    $0.maskImage = UIImage(named: "cup")
  }
  
  let waterCapacity = UILabel().then {
    $0.font = .systemFont(ofSize: 40, weight: .bold)
    $0.textColor = .darkGray
    $0.numberOfLines = 0
  }
  
  let completeButton = UIButton().then {
    $0.setTitle("DRINK", for: .normal)
    $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
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
    frontColor: .clear,
    backColor: #colorLiteral(red: 0.6, green: 0.8352941176, blue: 0.9019607843, alpha: 1)
  ).then {
    $0.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    $0.startAnimation()
  }
  
  let cup500 = UIButton().then {
    $0.setImage(UIImage(named: "cup500"), for: .normal)
  }
  
  let cup300 = UIButton().then {
    $0.setImage(UIImage(named: "cup300"), for: .normal)
  }
  
  let capacity500 = UILabel().then {
    $0.text = "500ml"
    $0.textColor = .black
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 14, weight: .bold)
  }
  
  let capacity300 = UILabel().then {
    $0.text = "300ml"
    $0.textColor = .black
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 14, weight: .bold)
  }
  
  
  // MARK: - Initialize
  
  init(reactor: DrinkViewReactor) {
    super.init()
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Bind
  
  func bind(reactor: DrinkViewReactor) {
    
    // Action
    let gesture = self.cup.rx
      .anyGesture(
        (.tap(), when: .ended),
        (.pan(), when: .began),
        (.pan(), when: .ended),
        (.pan(), when: .changed)
      )
    
    gesture
      .filter { $0.state == .ended }
      .map { [weak self] tapped in
        let point = tapped.location(in: self?.cup)
        let height = Metric.height - point.y
        let progress = height / Metric.height
        return progress
      }
      .filter { $0 >= 0 && $0 <= 1 }
      .map { Reactor.Action.tapCup($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    gesture
      .filter { $0.state != .ended }
      .map { [weak self] swipe in
        swipe.location(in: self?.cup).y
      }
      .filter { $0 >= 0 && $0 <= Metric.height }
      .map { $0 * 500 / Metric.height }
      .map { Reactor.Action.didScroll($0) }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.backButton.rx.tap
      .map { Reactor.Action.cancel }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.addWater.rx.tap
      .map { Reactor.Action.increseWater }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.subWater.rx.tap
      .map { Reactor.Action.decreseWater }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.cup500.rx.tap
      .map { Reactor.Action.set500 }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.cup300.rx.tap
      .map { Reactor.Action.set300 }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.completeButton.rx.tap
      .map { Reactor.Action.addWater }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.asObservable()
      .map { $0.currentValue }
      .distinctUntilChanged()
      .map { "\(Int($0))ml" }
      .bind(to: self.waterCapacity.rx.text)
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable()
      .map { $0.currentValue / $0.maxValue }
      .distinctUntilChanged()
      .map { Float($0) }
      .bind(to: self.cup.rx.setProgress)
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable()
      .map { $0.shouldDismissed }
      .distinctUntilChanged()
      .filter { $0 }
      .subscribe { [weak self] _ in
        guard let self = self else { return }
        self.navigationController?.popViewController(animated: true)
      }
      .disposed(by: self.disposeBag)
  }
  
  override func setupConstraints() {
    self.view.addSubview(self.waveBackground)
    self.waveBackground.addSubviews([
      self.backButton, self.lid, self.cup, self.addWater, self.subWater, self.waterCapacity,
      self.completeButton, self.cup500, self.cup300, self.capacity500, self.capacity300
    ])
    
    self.backButton.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
      $0.leading.equalToSuperview().offset(10)
      $0.width.height.equalTo(50)
    }
    self.lid.snp.makeConstraints {
      $0.bottom.equalTo(self.cup.snp.top)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(self.viewWidth * 0.55)
      $0.height.equalTo(40)
    }
    self.cup.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.width.equalTo(self.viewWidth * 0.5)
      $0.height.equalTo(self.viewHeight * 0.37)
    }
    self.addWater.snp.makeConstraints {
      $0.top.equalTo(self.cup.snp.bottom).offset(10)
      $0.leading.equalTo(self.cup.snp.leading)
      $0.width.height.equalTo(70)
    }
    self.subWater.snp.makeConstraints {
      $0.top.equalTo(self.cup.snp.bottom).offset(10)
      $0.trailing.equalTo(self.cup.snp.trailing)
      $0.width.height.equalTo(70)
    }
    self.waterCapacity.snp.makeConstraints {
      $0.bottom.equalTo(self.lid.snp.top).offset(-30)
      $0.centerX.equalToSuperview()
    }
    self.completeButton.snp.makeConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-30)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(100)
      $0.height.equalTo(40)
    }
    self.cup500.snp.makeConstraints {
      $0.leading.equalTo(self.completeButton.snp.trailing).offset(50)
      $0.centerY.equalTo(self.completeButton.snp.centerY)
      $0.width.equalTo(30)
      $0.height.equalTo(50)
    }
    self.cup300.snp.makeConstraints {
      $0.trailing.equalTo(self.completeButton.snp.leading).offset(-50)
      $0.centerY.equalTo(self.completeButton.snp.centerY)
      $0.width.equalTo(30)
      $0.height.equalTo(50)
    }
    self.capacity500.snp.makeConstraints {
      $0.top.equalTo(self.cup500.snp.bottom).offset(5)
      $0.centerX.equalTo(self.cup500.snp.centerX)
    }
    self.capacity300.snp.makeConstraints {
      $0.top.equalTo(self.cup300.snp.bottom).offset(5)
      $0.centerX.equalTo(self.cup300.snp.centerX)
    }
  }
}
