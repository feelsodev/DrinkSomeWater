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

class DrinkViewController: BaseViewController, View {
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
    frame: CGRect(x: 0, y: 0, width: 150, height: 220),
    frontColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),
    backColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
  ).then {
    $0.layer.borderWidth = 1
    $0.layer.masksToBounds = true
    $0.setProgress(0.5)
    $0.startAnimation()
    $0.backgroundColor = .white
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
  }
  
  init(reactor: DrinkViewReactor) {
    super.init()
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bind(reactor: DrinkViewReactor) {
    
    // action
    self.addWater.rx.tap
      .map { Reactor.Action.increseWater }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    self.subWater.rx.tap
      .map { Reactor.Action.decreseWater }
      .bind(to: reactor.action)
      .disposed(by: disposeBag)
    
    // state
    reactor.state.asObservable()
      .map { $0.current / $0.total }
      .bind(to: self.cup.rx.setProgress)
      .disposed(by: disposeBag)
  }
  
  override func setupConstraints() {
    [self.cup, self.addWater, self.subWater].forEach { self.view.addSubview($0) }
    self.cup.snp.makeConstraints {
      $0.centerX.centerY.equalToSuperview()
      $0.width.equalTo(150)
      $0.height.equalTo(220)
    }
    self.addWater.snp.makeConstraints {
      $0.top.equalTo(self.cup.snp.top).offset(10)
      $0.leading.equalTo(self.cup.snp.trailing).offset(10)
      $0.width.height.equalTo(70)
    }
    self.subWater.snp.makeConstraints {
      $0.bottom.equalTo(self.cup.snp.bottom).offset(-10)
      $0.leading.equalTo(self.cup.snp.trailing).offset(10)
      $0.width.height.equalTo(70)
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
