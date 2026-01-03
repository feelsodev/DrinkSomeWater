import UIKit
@preconcurrency import FSCalendar

final class CalendarViewController: BaseViewController {
    
    private let store: CalendarStore
    
    var successDates: [String] = []
    var waterRecordList: [WaterRecord] = []
    
    private let first = CalendarDescriptView(color: #colorLiteral(red: 0.7764705882, green: 0.2, blue: 0.1647058824, alpha: 1), descript: "Today".localized)
    private let second = CalendarDescriptView(color: .darkGray, descript: "Selected".localized)
    private let third = CalendarDescriptView(color: #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1), descript: "Success".localized)
    private let sun = UIImageView(image: UIImage(named: "sun"))
    private let tube = UIImageView(image: UIImage(named: "tube"))
    
    private let dismissButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "xmark")?
            .withConfiguration(UIImage.SymbolConfiguration(weight: .regular))
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        config.baseForegroundColor = .black
        $0.configuration = config
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
        $0.addArrangedSubview(first)
        $0.addArrangedSubview(second)
        $0.addArrangedSubview(third)
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
        frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height),
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
    
    init(store: CalendarStore) {
        self.store = store
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        waveBackground.stopAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        observation = startObservation { [weak self] in self?.render() }
        
        Task { await store.send(.viewDidLoad) }
    }
    
    private func setupActions() {
        dismissButton.addAction(UIAction { [weak self] _ in
            Task { await self?.store.send(.cancel) }
        }, for: .touchUpInside)
    }
    
    override func render() {
        waterRecordList = store.waterRecordList
        successDates = waterRecordList.filter { $0.isSuccess }.map { $0.date.dateToString }
        calendar.reloadData()
        
        if store.shouldDismiss {
            dismiss(animated: true)
        }
    }
    
    override func setupConstraints() {
        view.addSubview(waveBackground)
        waveBackground.addSubviews([
            dismissButton, sun, tube, stackView,
            titleLabel, calendar, calendarDescript, record
        ])
        
        waveBackground.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        dismissButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.width.height.equalTo(35)
        }
        sun.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.trailing.equalTo(tube.snp.leading)
            $0.height.width.equalTo(40)
        }
        tube.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(60)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.width.equalTo(40)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(40)
            $0.centerX.equalToSuperview()
        }
        calendar.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(viewHeight * 0.35)
        }
        calendarDescript.snp.makeConstraints {
            $0.top.equalTo(calendar.snp.bottom).offset(5)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-10)
        }
        stackView.snp.makeConstraints {
            $0.top.equalTo(calendarDescript.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(25)
        }
        record.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(viewHeight * 0.20)
        }
    }
}

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    nonisolated func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        MainActor.assumeIsolated {
            successDates.contains(date.dateToString) ? #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1) : nil
        }
    }
    
    nonisolated func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        MainActor.assumeIsolated {
            successDates.contains(date.dateToString) ? .white : nil
        }
    }
    
    nonisolated func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        MainActor.assumeIsolated {
            let selectedDate = date.dateToString
            if successDates.contains(selectedDate) {
                if let waterRecord = waterRecordList.first(where: { $0.date.dateToString == selectedDate }) {
                    record.fadeIn()
                    record.do {
                        $0.goal.text = "📌 목표량 : \(waterRecord.goal) ml"
                        $0.capacity.text = "🥛 섭취량 : \(waterRecord.value) ml"
                        let percentage = (Float(waterRecord.value) / Float(waterRecord.goal)).setPercentage
                        $0.percentage.text = "📝 달성률 : " + percentage
                    }
                }
            } else {
                record.fadeOut()
            }
        }
    }
}
