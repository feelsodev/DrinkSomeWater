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
  
  // MARK: - UI
  
  let descript = UILabel().then {
    $0.font = .systemFont(ofSize: 20, weight: .medium)
    $0.textColor = .darkGray
    $0.numberOfLines = 0
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
    $0.layer.borderColor = UIColor.white.cgColor
    $0.layer.masksToBounds = true
    $0.startAnimation()
    $0.backgroundColor = .white
  }
  
  lazy var waveBackground = WaveAnimationView(
    frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height),
    frontColor: .clear,
    backColor: #colorLiteral(red: 0.6, green: 0.8352941176, blue: 0.9019607843, alpha: 1)
  ).then {
    $0.backgroundColor = #colorLiteral(red: 0.8339943543, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    $0.setProgress(0.5)
    $0.startAnimation()
  }
  
  let addWarter = UIButton().then {
    $0.setImage(UIImage(named: "bulkuk"), for: .normal)
  }
  
  let setView = UIButton().then {
    $0.setImage(UIImage(systemName: "gear")?
                  .withConfiguration(UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
    $0.tintColor = .white
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
  
  let calendarView = UIButton().then {
    $0.setImage(UIImage(systemName: "calendar")?
                  .withConfiguration(UIImage.SymbolConfiguration(weight: .light)), for: .normal)
    $0.tintColor = .white
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
    
    self.rx.viewDidLoad
      .map { Reactor.Action.refreshGoal }
      .bind(to: reactor.action )
      .disposed(by: self.disposeBag)
    
    self.setView.rx.tap
      .map(reactor.reactorForCreactingSetting)
      .subscribe(onNext: { [weak self] reactor in
        guard let `self` = self else { return }
        let vc = SettingViewController(reactor: reactor)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
      })
      .disposed(by: self.disposeBag)
    
    self.addWarter.rx.tap
      .map(reactor.reactorForCreatingDrink)
      .subscribe(onNext: { [weak self] reactor in
        guard let `self` = self else { return }
        let vc = DrinkViewController(reactor: reactor)
        self.present(vc, animated: true, completion: nil)
      })
      .disposed(by: self.disposeBag)
    
    self.calendarView.rx.tap
      .map(reactor.reactorForCreatingCalendar)
      .subscribe(onNext: { [weak self] reactor in
        guard let `self` = self else { return }
        let vc = CalendarViewController(reactor: reactor)
        self.present(vc, animated: true, completion: nil)
      })
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.asObservable()
      .map { $0.progress }
      .bind(to: self.bottle.rx.setProgress)
      .disposed(by: self.disposeBag)
    
    reactor.state.asObservable()
      .map { $0.progress.setPercentage() }
      .bind(to: self.descript.rx.text)
      .disposed(by: self.disposeBag)
  }
  
  override func setupConstraints() {
    self.view.addSubview(self.waveBackground)
    [self.calendarView, self.setView, self.descript, self.goal, self.lid, self.lidNeck, self.bottle, self.addWarter]
      .forEach { self.waveBackground.addSubview($0) }
    
    self.waveBackground.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    self.calendarView.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
      $0.leading.equalToSuperview().offset(10)
      $0.width.equalTo(60)
      $0.height.equalTo(50)
    }
    self.setView.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
      $0.trailing.equalToSuperview().offset(-10)
      $0.width.height.equalTo(50)
    }
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
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(30)
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(100)
    }
  }
}
