import UIKit
import SnapKit

final class NotificationSettingViewController: BaseViewController {
  
  private let store: NotificationStore
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    return scrollView
  }()
  
  private let contentView = UIView()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = L.NotificationSettings.title
    label.font = .systemFont(ofSize: 24, weight: .bold)
    label.textColor = .darkGray
    return label
  }()

  private lazy var enabledSwitch: UISwitch = {
    let toggle = UISwitch()
    toggle.onTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    return toggle
  }()

  private lazy var enabledLabel: UILabel = {
    let label = UILabel()
    label.text = L.NotificationSettings.enable
    label.font = .systemFont(ofSize: 17, weight: .medium)
    label.textColor = .darkGray
    return label
  }()

  private lazy var timeRangeLabel: UILabel = {
    let label = UILabel()
    label.text = L.NotificationSettings.timeRange
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textColor = .gray
    return label
  }()
  
  private lazy var startTimeButton: UIButton = {
    let button = UIButton()
    var config = UIButton.Configuration.tinted()
    config.title = "08:00"
    config.baseBackgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    config.baseForegroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    config.cornerStyle = .medium
    button.configuration = config
    return button
  }()
  
  private lazy var timeRangeDashLabel: UILabel = {
    let label = UILabel()
    label.text = "~"
    label.font = .systemFont(ofSize: 18, weight: .medium)
    label.textColor = .gray
    return label
  }()
  
  private lazy var endTimeButton: UIButton = {
    let button = UIButton()
    var config = UIButton.Configuration.tinted()
    config.title = "22:00"
    config.baseBackgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    config.baseForegroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    config.cornerStyle = .medium
    button.configuration = config
    return button
  }()
  
  private lazy var intervalLabel: UILabel = {
    let label = UILabel()
    label.text = L.NotificationSettings.interval
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textColor = .gray
    return label
  }()
  
  private lazy var intervalSegment: UISegmentedControl = {
    let segment = UISegmentedControl(items: NotificationInterval.allCases.map { $0.displayString })
    segment.selectedSegmentIndex = 1
    segment.selectedSegmentTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    segment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    segment.setTitleTextAttributes([.foregroundColor: UIColor.darkGray], for: .normal)
    return segment
  }()
  
  private lazy var weekdayLabel: UILabel = {
    let label = UILabel()
    label.text = L.NotificationSettings.weekdays
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textColor = .gray
    return label
  }()
  
  private lazy var weekdayStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.spacing = 8
    return stackView
  }()
  
  private lazy var customTimesLabel: UILabel = {
    let label = UILabel()
    label.text = L.NotificationSettings.custom
    label.font = .systemFont(ofSize: 14, weight: .semibold)
    label.textColor = .gray
    return label
  }()
  
  private lazy var customTimesStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 8
    return stackView
  }()
  
  private lazy var addCustomTimeButton: UIButton = {
    let button = UIButton()
    var config = UIButton.Configuration.plain()
    config.title = "+ " + L.NotificationSettings.addTime
    config.baseForegroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
      var attr = attr
      attr.font = UIFont.systemFont(ofSize: 15, weight: .medium)
      return attr
    }
    button.configuration = config
    return button
  }()
  
  private lazy var messageInfoLabel: UILabel = {
    let label = UILabel()
    label.text = "💬 " + L.Notification.messageInfo
    label.font = .systemFont(ofSize: 14, weight: .medium)
    label.textColor = .gray
    label.textAlignment = .center
    return label
  }()
  
  private var weekdayButtons: [UIButton] = []
  
  init(store: NotificationStore) {
    self.store = store
    super.init()
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupWeekdayButtons()
    setupActions()
    observation = startObservation { [weak self] in self?.render() }
    
    Task {
      await store.send(.load)
    }
  }
  
  override func render() {
    enabledSwitch.isOn = store.settings.isEnabled
    
    updateTimeButton(startTimeButton, with: store.settings.startTime)
    updateTimeButton(endTimeButton, with: store.settings.endTime)
    
    if let index = NotificationInterval.allCases.firstIndex(of: store.settings.interval) {
      intervalSegment.selectedSegmentIndex = index
    }
    
    for (index, button) in weekdayButtons.enumerated() {
      let weekday = Weekday.allCases[index]
      let isSelected = store.settings.enabledWeekdays.contains(weekday)
      updateWeekdayButton(button, isSelected: isSelected)
    }
    
    updateCustomTimesUI()
    
    updateUIEnabledState()
  }
  
  override func setupConstraints() {
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    
    contentView.addSubviews([
      titleLabel, enabledLabel, enabledSwitch,
      timeRangeLabel, startTimeButton, timeRangeDashLabel, endTimeButton,
      intervalLabel, intervalSegment,
      weekdayLabel, weekdayStackView,
      customTimesLabel, customTimesStackView, addCustomTimeButton,
      messageInfoLabel
    ])
    
    scrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(24)
      $0.leading.equalToSuperview().offset(20)
    }
    
    enabledSwitch.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.trailing.equalToSuperview().offset(-20)
    }
    
    enabledLabel.snp.makeConstraints {
      $0.centerY.equalTo(enabledSwitch)
      $0.leading.equalToSuperview().offset(20)
    }
    
    timeRangeLabel.snp.makeConstraints {
      $0.top.equalTo(enabledSwitch.snp.bottom).offset(32)
      $0.leading.equalToSuperview().offset(20)
    }
    
    startTimeButton.snp.makeConstraints {
      $0.top.equalTo(timeRangeLabel.snp.bottom).offset(12)
      $0.leading.equalToSuperview().offset(20)
      $0.height.equalTo(44)
      $0.width.equalTo(100)
    }
    
    timeRangeDashLabel.snp.makeConstraints {
      $0.centerY.equalTo(startTimeButton)
      $0.leading.equalTo(startTimeButton.snp.trailing).offset(16)
    }
    
    endTimeButton.snp.makeConstraints {
      $0.centerY.equalTo(startTimeButton)
      $0.leading.equalTo(timeRangeDashLabel.snp.trailing).offset(16)
      $0.height.equalTo(44)
      $0.width.equalTo(100)
    }
    
    intervalLabel.snp.makeConstraints {
      $0.top.equalTo(startTimeButton.snp.bottom).offset(32)
      $0.leading.equalToSuperview().offset(20)
    }
    
    intervalSegment.snp.makeConstraints {
      $0.top.equalTo(intervalLabel.snp.bottom).offset(12)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.height.equalTo(36)
    }
    
    weekdayLabel.snp.makeConstraints {
      $0.top.equalTo(intervalSegment.snp.bottom).offset(32)
      $0.leading.equalToSuperview().offset(20)
    }
    
    weekdayStackView.snp.makeConstraints {
      $0.top.equalTo(weekdayLabel.snp.bottom).offset(12)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.height.equalTo(44)
    }
    
    customTimesLabel.snp.makeConstraints {
      $0.top.equalTo(weekdayStackView.snp.bottom).offset(32)
      $0.leading.equalToSuperview().offset(20)
    }
    
    customTimesStackView.snp.makeConstraints {
      $0.top.equalTo(customTimesLabel.snp.bottom).offset(12)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
    }
    
    addCustomTimeButton.snp.makeConstraints {
      $0.top.equalTo(customTimesStackView.snp.bottom).offset(8)
      $0.leading.equalToSuperview().offset(20)
      $0.height.equalTo(36)
    }
    
    messageInfoLabel.snp.makeConstraints {
      $0.top.equalTo(addCustomTimeButton.snp.bottom).offset(32)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.bottom.equalToSuperview().offset(-32)
    }
  }
  
  private func setupWeekdayButtons() {
    for weekday in Weekday.allCases {
      let button = UIButton()
      button.setTitle(weekday.shortName, for: .normal)
      button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
      button.layer.cornerRadius = 22
      button.tag = weekday.rawValue
      button.addTarget(self, action: #selector(weekdayTapped(_:)), for: .touchUpInside)
      weekdayButtons.append(button)
      weekdayStackView.addArrangedSubview(button)
    }
  }
  
  private func setupActions() {
    enabledSwitch.addTarget(self, action: #selector(enabledSwitchChanged), for: .valueChanged)
    
    startTimeButton.addAction(UIAction { [weak self] _ in
      self?.showTimePicker(isStartTime: true)
    }, for: .touchUpInside)
    
    endTimeButton.addAction(UIAction { [weak self] _ in
      self?.showTimePicker(isStartTime: false)
    }, for: .touchUpInside)
    
    intervalSegment.addTarget(self, action: #selector(intervalChanged), for: .valueChanged)
    
    addCustomTimeButton.addAction(UIAction { [weak self] _ in
      self?.showAddCustomTimePicker()
    }, for: .touchUpInside)
  }
  
  @objc private func enabledSwitchChanged() {
    Task {
      await store.send(.toggleEnabled(enabledSwitch.isOn))
    }
  }
  
  @objc private func weekdayTapped(_ sender: UIButton) {
    guard let weekday = Weekday(rawValue: sender.tag) else { return }
    Task {
      await store.send(.toggleWeekday(weekday))
    }
  }
  
  @objc private func intervalChanged() {
    let interval = NotificationInterval.allCases[intervalSegment.selectedSegmentIndex]
    Task {
      await store.send(.updateInterval(interval))
    }
  }
  
   private func showTimePicker(isStartTime: Bool) {
     let title = isStartTime ? L.NotificationSettings.startTime : L.NotificationSettings.endTime
     let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .time
    datePicker.preferredDatePickerStyle = .wheels
    datePicker.locale = Locale.current
    
    let time = isStartTime ? store.settings.startTime : store.settings.endTime
    var components = DateComponents()
    components.hour = time.hour
    components.minute = time.minute
    datePicker.date = Calendar.current.date(from: components) ?? Date()
    
    let containerView = UIView()
    containerView.addSubview(datePicker)
    datePicker.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalTo(200)
    }
    
    alert.view.addSubview(containerView)
    containerView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(50)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(200)
    }
    
    let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
    alert.view.addConstraint(height)
    
     alert.addAction(UIAlertAction(title: L.Common.confirm, style: .default) { [weak self] _ in
       let components = Calendar.current.dateComponents([.hour, .minute], from: datePicker.date)
       let newTime = NotificationTime(hour: components.hour ?? 0, minute: components.minute ?? 0)
       Task {
         if isStartTime {
           await self?.store.send(.updateStartTime(newTime))
         } else {
           await self?.store.send(.updateEndTime(newTime))
         }
       }
     })

     alert.addAction(UIAlertAction(title: L.Common.cancel, style: .cancel))

    present(alert, animated: true)
  }

   private func showAddCustomTimePicker() {
     let alert = UIAlertController(title: L.NotificationSettings.addTime, message: nil, preferredStyle: .actionSheet)

    let datePicker = UIDatePicker()
    datePicker.datePickerMode = .time
    datePicker.preferredDatePickerStyle = .wheels
    datePicker.locale = Locale.current
    
    let containerView = UIView()
    containerView.addSubview(datePicker)
    datePicker.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalTo(200)
    }
    
    alert.view.addSubview(containerView)
    containerView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(50)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(200)
    }
    
    let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 320)
    alert.view.addConstraint(height)
    
     alert.addAction(UIAlertAction(title: L.Home.quickButtonAdd, style: .default) { [weak self] _ in
       let components = Calendar.current.dateComponents([.hour, .minute], from: datePicker.date)
       let newTime = NotificationTime(hour: components.hour ?? 0, minute: components.minute ?? 0)
       Task {
         await self?.store.send(.addCustomTime(newTime))
       }
     })

     alert.addAction(UIAlertAction(title: L.Common.cancel, style: .cancel))
    
    present(alert, animated: true)
  }
  
  private func updateTimeButton(_ button: UIButton, with time: NotificationTime) {
    button.configuration?.title = time.displayString
  }
  
  private func updateWeekdayButton(_ button: UIButton, isSelected: Bool) {
    if isSelected {
      button.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
      button.setTitleColor(.white, for: .normal)
    } else {
      button.backgroundColor = UIColor.systemGray5
      button.setTitleColor(.darkGray, for: .normal)
    }
  }
  
  private func updateCustomTimesUI() {
    customTimesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    for time in store.settings.customTimes {
      let row = createCustomTimeRow(time: time)
      customTimesStackView.addArrangedSubview(row)
    }
  }
  
  private func createCustomTimeRow(time: NotificationTime) -> UIView {
    let container = UIView()
    container.backgroundColor = UIColor.systemGray6
    container.layer.cornerRadius = 8
    
    let timeLabel = UILabel()
    timeLabel.text = time.displayString
    timeLabel.font = .systemFont(ofSize: 16, weight: .medium)
    timeLabel.textColor = .darkGray
    
    let deleteButton = UIButton()
    deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
    deleteButton.tintColor = .systemRed
    deleteButton.addAction(UIAction { [weak self] _ in
      Task {
        await self?.store.send(.removeCustomTime(time))
      }
    }, for: .touchUpInside)
    
    container.addSubviews([timeLabel, deleteButton])
    
    timeLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(16)
      $0.centerY.equalToSuperview()
    }
    
    deleteButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().offset(-12)
      $0.centerY.equalToSuperview()
      $0.width.height.equalTo(24)
    }
    
    container.snp.makeConstraints {
      $0.height.equalTo(44)
    }
    
    return container
  }
  
  private func updateUIEnabledState() {
    let isEnabled = store.settings.isEnabled
    let alpha: CGFloat = isEnabled ? 1.0 : 0.5
    
    timeRangeLabel.alpha = alpha
    startTimeButton.isEnabled = isEnabled
    startTimeButton.alpha = alpha
    endTimeButton.isEnabled = isEnabled
    endTimeButton.alpha = alpha
    
    intervalLabel.alpha = alpha
    intervalSegment.isEnabled = isEnabled
    intervalSegment.alpha = alpha
    
    weekdayLabel.alpha = alpha
    weekdayStackView.alpha = alpha
    weekdayButtons.forEach { $0.isEnabled = isEnabled }
    
    customTimesLabel.alpha = alpha
    customTimesStackView.alpha = alpha
    addCustomTimeButton.isEnabled = isEnabled
    addCustomTimeButton.alpha = alpha
    
    messageInfoLabel.alpha = alpha
  }
}
