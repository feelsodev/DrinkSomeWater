//
//  MainViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/16.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift
import WaveAnimationView

final class MainViewController: BaseViewController, View {
  
  // MARK: UI
  
  let descript = UILabel().then {
    $0.text = "하루 목표치"
    $0.textColor = .black
  }
  
  let goal = UILabel().then {
    $0.textAlignment = .center
    $0.textColor = .black
  }
  
  let lid = UIView().then {
    $0.layer.borderWidth = 0.1
    $0.layer.cornerRadius = 5
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.masksToBounds = true
    $0.backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.5605390058, blue: 1, alpha: 1)
  }
  
  let lidNeck = UIView().then {
    $0.layer.borderWidth = 0.1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.masksToBounds = true
    $0.backgroundColor = .white
  }
  
  let bottle = WaveAnimationView(
    frame: CGRect(x: 0, y: 0, width: 200, height: 400),
    frontColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),
    backColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
  ).then {
    $0.layer.borderWidth = 0.1
    $0.layer.cornerRadius = 15
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.masksToBounds = true
    $0.startAnimation()
    $0.backgroundColor = .white
  }
  
  let addWarter = UIButton().then {
    $0.setImage(UIImage(named: "bulkuk"), for: .normal)
  }
  
  init(reactor: MainViewReactor) {
    super.init()
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = #colorLiteral(red: 0.6, green: 0.8352941176, blue: 0.9019607843, alpha: 1)
  }
  
  func bind(reactor: MainViewReactor) {
    
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.refresh }
      .bind(to: reactor.action )
      .disposed(by: self.disposeBag)
    
    self.addWarter.rx.tap
      .map(reactor.reactorForCreatingDrink)
      .subscribe(onNext: { [weak self] reactor in
        guard let `self` = self else { return }
        let vc = DrinkViewController(reactor: reactor)
        self.present(vc, animated: true, completion: nil)
      })
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state
      .map { $0.progress }
      .bind(to: self.bottle.rx.setProgress)
      .disposed(by: self.disposeBag)
  }
  
  override func setupConstraints() {
    [self.descript, self.goal, self.lid, self.lidNeck, self.bottle, self.addWarter]
      .forEach { self.view.addSubview($0) }
    
    self.descript.snp.makeConstraints {
      $0.top.equalToSuperview().offset(100)
      $0.centerX.equalToSuperview()
    }
    self.goal.snp.makeConstraints {
      $0.top.equalTo(self.descript.snp.bottom).offset(20)
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(50)
    }
    self.lid.snp.makeConstraints {
      $0.bottom.equalTo(self.lidNeck.snp.top)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(100)
      $0.height.equalTo(30)
    }
    self.lidNeck.snp.makeConstraints {
      $0.bottom.equalTo(self.bottle.snp.top)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(50)
      $0.height.equalTo(20)
    }
    self.bottle.snp.makeConstraints {
      $0.top.equalTo(self.goal.snp.bottom).offset(20)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(200)
      $0.height.equalTo(400)
    }
    self.addWarter.snp.makeConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(20)
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(80)
    }
  }
}
