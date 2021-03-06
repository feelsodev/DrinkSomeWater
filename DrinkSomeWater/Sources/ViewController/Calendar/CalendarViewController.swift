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
  var waterRecordList: [WaterRecord]?
  
  
  // MARK: - UI
  
  private let first = CalendarDescriptView(color: #colorLiteral(red: 0.7764705882, green: 0.2, blue: 0.1647058824, alpha: 1), descript: "Today".localized)
  private let second = CalendarDescriptView(color: .darkGray, descript: "Selected".localized)
  private let third = CalendarDescriptView(color: #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1), descript: "Success".localized)
  private let sun = UIImageView(image: UIImage(named: "sun"))
  private let tube = UIImageView(image: UIImage(named: "tube"))
  
  private let dismissButton = UIButton().then {
    $0.setImage(UIImage(systemName: "xmark")?
                  .withConfiguration(UIImage.SymbolConfiguration(weight: .regular)), for: .normal)
    $0.tintColor = .black
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
  
  private let calendarDescript = UILabel().then {
    $0.text = "☝️ " + "You can check the history when you select a success date.".localized
    $0.numberOfLines = 2
    $0.textColor = .darkGray
    $0.textAlignment = .center
    $0.font = .systemFont(ofSize: 17, weight: .semibold)
  }
  
  private lazy var stackView = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.spacing = 5
    $0.addArrangedSubview(self.first)
    $0.addArrangedSubview(self.second)
    $0.addArrangedSubview(self.third)
  }
  
  private let titleLabel = UILabel().then {
    $0.text = "Goal of this month".localized
    $0.textColor = .black
    $0.font = .systemFont(ofSize: 20, weight: .medium)
    $0.textAlignment = .center
  }
  
  private lazy var calendar = FSCalendar().then {
    $0.delegate = self
    $0.dataSource = self
    $0.backgroundColor = .clear
    $0.appearance.do {
      $0.selectionColor = .darkGray
      $0.headerMinimumDissolvedAlpha = 0.0
      $0.headerDateFormat = "MMMM, YYYY".localized
      $0.headerTitleColor = .black
      $0.weekdayTextColor = .black
      $0.headerTitleFont = .systemFont(ofSize: 18, weight: .semibold)
      $0.weekdayFont = .systemFont(ofSize: 14, weight: .bold)
    }
  }
  
  private lazy var waveBackground = WaveAnimationView(
    frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height),
    frontColor: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),
    backColor: #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
  ).then {
    $0.backgroundColor = .white
    $0.setProgress(0.4)
    $0.startAnimation()
  }
  
  private let record = WaterRecordResultView().then {
    $0.isHidden = true
  }
  
  
  // MARK: - Initialize
  
  init(reactor: CalendarViewReactor) {
    super.init()
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // MARK: - Bind
  
  func bind(reactor: CalendarViewReactor) {
    
    // Action
    self.rx.viewDidLoad
      .map { Reactor.Action.viewDidload }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    self.dismissButton.rx.tap
      .map { Reactor.Action.cancel }
      .bind(to: reactor.action)
      .disposed(by: self.disposeBag)
    
    // State
    reactor.state.asObservable()
      .map { $0.waterRecordList }
      .subscribe(onNext: { [weak self] waterRecordList in
        guard let `self` = self else { return }
        self.waterRecordList = waterRecordList
        waterRecordList.forEach {
          if $0.isSuccess {
            self.date.append($0.date.dateToString)
          }
        }
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
    self.waveBackground.addSubviews([
      self.dismissButton, self.sun, self.tube, self.stackView,
      self.titleLabel, self.calendar, self.calendarDescript, self.record
    ])
    
    self.waveBackground.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    self.dismissButton.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
      $0.leading.equalToSuperview().offset(10)
      $0.width.height.equalTo(35)
    }
    self.sun.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(30)
      $0.trailing.equalTo(self.tube.snp.leading)
      $0.height.width.equalTo(40)
    }
    self.tube.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(60)
      $0.trailing.equalToSuperview().offset(-20)
      $0.height.width.equalTo(40)
    }
    self.titleLabel.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(40)
      $0.centerX.equalToSuperview()
    }
    self.calendar.snp.makeConstraints {
      $0.top.equalTo(self.titleLabel.snp.bottom).offset(10)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.height.equalTo(self.viewHeight * 0.35)
    }
    self.calendarDescript.snp.makeConstraints {
      $0.top.equalTo(self.calendar.snp.bottom).offset(5)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-10)
    }
    self.stackView.snp.makeConstraints {
      $0.top.equalTo(self.calendarDescript.snp.bottom).offset(10)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.height.equalTo(25)
    }
    self.record.snp.makeConstraints {
      $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.height.equalTo(self.viewHeight * 0.20)
    }
  }
}

extension CalendarViewController: FSCalendarDataSource,
                                  FSCalendarDelegate,
                                  FSCalendarDelegateAppearance {
  func calendar(
    _ calendar: FSCalendar,
    appearance: FSCalendarAppearance,
    fillDefaultColorFor date: Date
  ) -> UIColor? {
    if self.date.contains(date.dateToString) {
      return #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    } else {
      return nil
    }
  }
  
  func calendar(
    _ calendar: FSCalendar,
    appearance: FSCalendarAppearance,
    titleDefaultColorFor date: Date
  ) -> UIColor? {
    if self.date.contains(date.dateToString) {
      return .white
    } else {
      return nil
    }
  }
  
  func calendar(
    _ calendar: FSCalendar,
    didSelect date: Date,
    at monthPosition: FSCalendarMonthPosition
  ) {
    let selectedDate = date.dateToString
    if self.date.contains(selectedDate) {
      guard let waterRecordList = self.waterRecordList else { return }
      waterRecordList.forEach { waterRecord in
        if waterRecord.date.dateToString == selectedDate {
          self.record.fadeIn()
          self.record.do {
            $0.goal.text = "📌 목표량 : \(waterRecord.goal) ml"
            $0.capacity.text = "🥛 섭취량 : \(waterRecord.value) ml"
            let precetage = (Float(waterRecord.value) / Float(waterRecord.goal)).setPercentage
            $0.percentage.text = "📝 달성률 : " + precetage
          }
        }
      }
    } else {
      self.record.fadeOut()
    }
  }
}
