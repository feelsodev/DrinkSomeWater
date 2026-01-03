import UIKit
@preconcurrency import FSCalendar

final class HistoryViewController: BaseViewController {
    
    private let store: HistoryStore
    
    private lazy var waveBackground: WaveAnimationView = {
        let view = WaveAnimationView(
            frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight),
            frontColor: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),
            backColor: #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        )
        view.backgroundColor = .white
        view.setProgress(0.4)
        return view
    }()
    
    private let titleLabel = UILabel().then {
        $0.text = "기록"
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textColor = .darkGray
    }
    
    private let monthSummaryLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .gray
        $0.textAlignment = .right
    }
    
    private lazy var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.delegate = self
        calendar.dataSource = self
        calendar.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        calendar.layer.cornerRadius = 16
        calendar.clipsToBounds = true
        calendar.appearance.do {
            $0.selectionColor = .darkGray
            $0.headerMinimumDissolvedAlpha = 0.0
            $0.headerDateFormat = "yyyy년 M월"
            $0.headerTitleColor = .darkGray
            $0.weekdayTextColor = .darkGray
            $0.headerTitleFont = .systemFont(ofSize: 18, weight: .bold)
            $0.weekdayFont = .systemFont(ofSize: 14, weight: .semibold)
            $0.titleFont = .systemFont(ofSize: 14, weight: .medium)
        }
        return calendar
    }()
    
    private let legendStack = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = 16
    }
    
    private let recordCard = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 16
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowRadius = 8
        $0.isHidden = true
    }
    
    private let recordDateLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16, weight: .bold)
        $0.textColor = .darkGray
    }
    
    private let recordGoalLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .gray
    }
    
    private let recordIntakeLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .gray
    }
    
    private let recordAchievementLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18, weight: .bold)
        $0.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    }
    
    init(store: HistoryStore) {
        self.store = store
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setupLegend()
        waveBackground.startAnimation()
        observation = startObservation { [weak self] in self?.render() }
        
        Task { await store.send(.viewDidLoad) }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { await store.send(.viewDidLoad) }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        waveBackground.stopAnimation()
    }
    
    private func setupLegend() {
        let todayLegend = createLegendItem(color: #colorLiteral(red: 0.7764705882, green: 0.2, blue: 0.1647058824, alpha: 1), text: "오늘")
        let selectedLegend = createLegendItem(color: .darkGray, text: "선택")
        let successLegend = createLegendItem(color: #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1), text: "달성")
        
        legendStack.addArrangedSubview(todayLegend)
        legendStack.addArrangedSubview(selectedLegend)
        legendStack.addArrangedSubview(successLegend)
    }
    
    private func createLegendItem(color: UIColor, text: String) -> UIView {
        let container = UIView()
        let dot = UIView().then {
            $0.backgroundColor = color
            $0.layer.cornerRadius = 5
        }
        let label = UILabel().then {
            $0.text = text
            $0.font = .systemFont(ofSize: 12, weight: .medium)
            $0.textColor = .darkGray
        }
        container.addSubview(dot)
        container.addSubview(label)
        dot.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(10)
        }
        label.snp.makeConstraints {
            $0.leading.equalTo(dot.snp.trailing).offset(6)
            $0.centerY.equalToSuperview()
        }
        return container
    }
    
    override func render() {
        calendar.reloadData()
        monthSummaryLabel.text = "📊 이번 달: \(store.monthlySuccessCount)일 달성"
        
        if let record = store.selectedRecord {
            recordCard.isHidden = false
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M월 d일 (E)"
            dateFormatter.locale = Locale(identifier: "ko_KR")
            recordDateLabel.text = "📌 " + dateFormatter.string(from: record.date)
            recordGoalLabel.text = "목표량: \(record.goal)ml"
            recordIntakeLabel.text = "섭취량: \(record.value)ml"
            let percentage = Float(record.value) / Float(record.goal)
            recordAchievementLabel.text = "달성률: " + percentage.setPercentage + (record.isSuccess ? " ✅" : "")
        } else {
            recordCard.isHidden = true
        }
    }
    
    override func setupConstraints() {
        view.addSubview(waveBackground)
        waveBackground.addSubviews([
            titleLabel, monthSummaryLabel, calendar, legendStack, recordCard
        ])
        recordCard.addSubviews([
            recordDateLabel, recordGoalLabel, recordIntakeLabel, recordAchievementLabel
        ])
        
        waveBackground.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        monthSummaryLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        calendar.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(viewHeight * 0.4)
        }
        
        legendStack.snp.makeConstraints {
            $0.top.equalTo(calendar.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        recordCard.snp.makeConstraints {
            $0.top.equalTo(legendStack.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(120)
        }
        
        recordDateLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
        }
        
        recordGoalLabel.snp.makeConstraints {
            $0.top.equalTo(recordDateLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        recordIntakeLabel.snp.makeConstraints {
            $0.top.equalTo(recordGoalLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
        }
        
        recordAchievementLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
        }
    }
}

extension HistoryViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    nonisolated func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        MainActor.assumeIsolated {
            store.successDates.contains(date.dateToString) ? #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1) : nil
        }
    }
    
    nonisolated func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        MainActor.assumeIsolated {
            store.successDates.contains(date.dateToString) ? .white : nil
        }
    }
    
    nonisolated func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        Task { @MainActor in
            await store.send(.selectDate(date))
        }
    }
}
