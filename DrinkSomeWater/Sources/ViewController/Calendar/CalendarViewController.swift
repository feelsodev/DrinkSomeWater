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
  var date: [String] = []
  
  // MARK: - UI
  
  lazy var calendar = FSCalendar().then {
    $0.delegate = self
    $0.dataSource = self
    $0.backgroundColor = .white
    $0.appearance.headerMinimumDissolvedAlpha = 0.0
  }
  lazy var waveBackground = WaveAnimationView(
    frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height),
    frontColor: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),
    backColor: #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
  ).then {
    $0.backgroundColor = .white
    $0.setProgress(0.5)
    $0.startAnimation()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
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
        waterRecordList.forEach {
          if $0.isSuccess == true {
            self?.date.append($0.date.dateToString())
          }
        }
      })
      .disposed(by: self.disposeBag)
  }
  
  override func setupConstraints() {
    self.view.addSubview(self.waveBackground)
    self.waveBackground.addSubview(self.calendar)
    
    self.waveBackground.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    self.calendar.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
      $0.width.equalToSuperview()
      $0.height.equalTo(300)
    }
  }
}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
  func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
    if self.date.contains(date.dateToString()) {
      return .lightGray
    } else {
      return nil
    }
  }
}
