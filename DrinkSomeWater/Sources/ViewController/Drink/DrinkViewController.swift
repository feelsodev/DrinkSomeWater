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
import WaveAnimationView

final class DrinkViewController: BaseViewController, View {
  deinit {
    self.cup.stopAnimation()
    self.waveBackground.stopAnimation()
  }
  
  // MARK: - UI
  let backButton = UIButton().then {
    $0.tintColor = .white
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
  
  let cup = WaveAnimationView(
    frame: CGRect(x: 0, y: 0, width: 200, height: 300),
    frontColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),
    backColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
  ).then {
    $0.layer.cornerRadius = 10
    $0.layer.masksToBounds = true
    $0.startAnimation()
    $0.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
  }
  
  let ml = UILabel().then {
    $0.font = .systemFont(ofSize: 40, weight: .medium)
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
  
  init(reactor: DrinkViewReactor) {
    super.init()
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bind(reactor: DrinkViewReactor) {
    
    // Action
    self.addWater.rx.tap
      .map { Reactor.Action.increseWater }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.subWater.rx.tap
      .map { Reactor.Action.decreseWater }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.completeButton.rx.tap
      .map { Reactor.Action.addWater }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.asObservable()
      .map { $0.current }
      .distinctUntilChanged()
      .map { "\(Int($0))ml" }
      .bind(to: self.ml.rx.text)
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable()
      .map { $0.current / $0.total }
      .map { Float($0) }
      .bind(to: self.cup.rx.setProgress)
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
    self.view.addSubview(self.waveBackground)
    [self.backButton, self.cup, self.addWater, self.subWater, self.ml, self.completeButton]
      .forEach { self.waveBackground.addSubview($0) }
    
    self.backButton.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
      $0.leading.equalToSuperview().offset(10)
      $0.width.height.equalTo(50)
    }
    self.cup.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.width.equalTo(150)
      $0.height.equalTo(220)
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
    self.ml.snp.makeConstraints {
      $0.bottom.equalTo(self.cup.snp.top).offset(-30)
      $0.centerX.equalToSuperview()
    }
    self.completeButton.snp.makeConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(100)
      $0.height.equalTo(40)
    }
  }
}

extension Reactive where Base: UIView {
  var backgroundColor: Binder<UIColor> {
    return Binder(self.base) { view, color in
      view.backgroundColor = color
    }
  }
}

extension Reactive where Base: WaveAnimationView {
  var setProgress: Binder<Float> {
    return Binder(self.base) { view, progress in
      view.setProgress(progress)
    }
  }
}
