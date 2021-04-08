//
//  CalendarViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/30.
//

import UIKit
import FSCalendar
import ReactorKit
import RxCocoa
import RxSwift
import WaveAnimationView

final class CalendarViewController: BaseViewController, View {
  deinit { self.waveBackground.stopAnimation() }
  
  // MARK: - Property
  
  var date: [String] = []
  
  
  // MARK: - UI
  
  let sun = UIImageView(image: UIImage(named: "sun"))
  let tube = UIImageView(image: UIImage(named: "tube"))
  let titleLabel = UILabel().then {
    $0.text = "이달의 목표 달성"
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 20, weight: .medium)
    $0.textAlignment = .center
  }
  
  lazy var calendar = FSCalendar().then {
    $0.delegate = self
    $0.dataSource = self
    $0.backgroundColor = .clear
    $0.appearance.headerMinimumDissolvedAlpha = 0.0
  }
  
  lazy var waveBackground = WaveAnimationView(
    frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height),
    frontColor: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),
    backColor: #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
  ).then {
    $0.backgroundColor = .white
    $0.setProgress(0.4)
    $0.startAnimation()
  }
  
  init(reactor: CalendarViewReactor) {
    super.init()
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bind(reactor: CalendarViewReactor) {
    
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewDidload }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.asObservable()
      .map { $0.waterRecordList }
      .subscribe(onNext: { [weak self] waterRecordList in
        guard let `self` = self else { return }
        waterRecordList.forEach {
          if $0.isSuccess {
            self.date.append($0.date.dateToString())
          }
        }
      })
      .disposed(by: self.disposeBag)
  }
  
  override func setupConstraints() {
    self.view.addSubview(self.waveBackground)
    [self.sun, self.tube, self.titleLabel, self.calendar].forEach { self.waveBackground.addSubview($0) }
    
    self.waveBackground.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    self.sun.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
      $0.leading.equalToSuperview().offset(30)
      $0.height.width.equalTo(40)
    }
    self.tube.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
      $0.trailing.equalToSuperview().offset(-30)
      $0.height.width.equalTo(40)
    }
    self.titleLabel.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
      $0.centerX.equalToSuperview()
    }
    self.calendar.snp.makeConstraints {
      $0.top.equalTo(self.titleLabel.snp.bottom).offset(20)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.height.equalTo(300)
    }
  }
}

extension CalendarViewController: FSCalendarDataSource,
                                  FSCalendarDelegate,
                                  FSCalendarDelegateAppearance {
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
    if self.date.contains(date.dateToString()) {
      return #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    } else {
      return nil
    }
  }
  
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
    if self.date.contains(date.dateToString()) {
      return .white
    } else {
      return nil
    }
  }
}
