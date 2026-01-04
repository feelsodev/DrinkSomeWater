import UIKit
import SnapKit
import Then

final class SettingsViewController: BaseViewController {
  
  private let store: SettingsStore
  
  private let gradientLayer = CAGradientLayer()
  
  private let headerView = UIView()
  
  private let headerIconView = UIImageView().then {
    $0.image = UIImage(systemName: "gearshape.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium))
    $0.tintColor = .white.withAlphaComponent(0.9)
    $0.contentMode = .scaleAspectFit
  }
  
  private let titleLabel = UILabel().then {
    $0.text = NSLocalizedString("settings.title", comment: "")
    $0.font = DS.Font.largeTitle
    $0.textColor = .white
  }
  
  private let subtitleLabel = UILabel().then {
    $0.text = NSLocalizedString("settings.subtitle", comment: "")
    $0.font = DS.Font.subheadMedium
    $0.textColor = .white.withAlphaComponent(0.8)
  }
  
  private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped).then {
    $0.backgroundColor = DS.Color.backgroundPrimary
    $0.delegate = self
    $0.dataSource = self
    $0.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.cellID)
    $0.separatorStyle = .none
    $0.showsVerticalScrollIndicator = false
    $0.contentInset = UIEdgeInsets(top: DS.Spacing.sm, left: 0, bottom: DS.Spacing.xxl, right: 0)
    $0.sectionHeaderTopPadding = 0
  }
  
  private var sections: [(title: String, items: [(icon: String, title: String, detail: String?, action: SettingsAction)])] {
    [
      (NSLocalizedString("settings.section.personal", comment: "개인 설정"), [
        ("person.fill", NSLocalizedString("settings.profile", comment: ""), nil, .profile),
        ("target", NSLocalizedString("settings.goal", comment: ""), nil, .goal),
        ("bolt.fill", NSLocalizedString("settings.quickbuttons", comment: ""), nil, .quickButtons)
      ]),
      (NSLocalizedString("settings.section.app", comment: "앱 설정"), [
        ("bell.fill", NSLocalizedString("settings.notification", comment: ""), nil, .notification),
        ("apps.iphone", NSLocalizedString("settings.widget.guide", comment: ""), nil, .widgetGuide)
      ]),
      (NSLocalizedString("settings.section.support", comment: ""), [
        ("star.fill", NSLocalizedString("settings.review", comment: ""), nil, .review),
        ("envelope.fill", NSLocalizedString("settings.contact", comment: ""), nil, .contact)
      ]),
      (NSLocalizedString("settings.section.info", comment: ""), [
        ("info.circle.fill", NSLocalizedString("settings.version", comment: ""), nil, .version)
      ])
    ]
  }
  
  enum SettingsAction {
    case profile, goal, quickButtons, notification, widgetGuide, review, contact, version
  }
  
  init(store: SettingsStore) {
    self.store = store
    super.init()
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = DS.Color.backgroundPrimary
    navigationController?.isNavigationBarHidden = true
    setupGradient()
    observation = startObservation { [weak self] in self?.render() }
    
    Task {
      await store.send(.loadGoal)
      await store.send(.loadQuickButtons)
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    gradientLayer.frame = headerView.bounds
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Task {
      await store.send(.loadGoal)
      await store.send(.loadQuickButtons)
    }
  }
  
  override func render() {
    tableView.reloadData()
  }
  
  private func setupGradient() {
    gradientLayer.colors = [
      DS.Color.primary.cgColor,
      DS.Color.primaryDark.cgColor
    ]
    gradientLayer.locations = [0.0, 1.0]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: 1, y: 1)
    headerView.layer.insertSublayer(gradientLayer, at: 0)
  }
  
  override func setupConstraints() {
    view.addSubviews([headerView, tableView])
    headerView.addSubviews([headerIconView, titleLabel, subtitleLabel])
    
    headerView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(140)
    }
    
    headerIconView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(DS.Spacing.sm)
      $0.leading.equalToSuperview().offset(DS.Spacing.xl)
      $0.width.height.equalTo(DS.Size.iconXLarge)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(headerIconView.snp.bottom).offset(DS.Spacing.sm)
      $0.leading.equalToSuperview().offset(DS.Spacing.xl)
    }
    
    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(DS.Spacing.xxs)
      $0.leading.equalToSuperview().offset(DS.Spacing.xl)
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(headerView.snp.bottom).offset(-DS.Spacing.lg)
      $0.leading.trailing.bottom.equalToSuperview()
    }
    
    tableView.layer.cornerRadius = DS.Size.cornerRadiusXLarge
    tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    tableView.clipsToBounds = true
  }
  
  private func handleAction(_ action: SettingsAction) {
    switch action {
    case .profile:
      presentProfileSetting()
    case .goal:
      presentGoalSetting()
    case .quickButtons:
      presentQuickButtonSetting()
    case .notification:
      openNotificationSettings()
    case .widgetGuide:
      presentWidgetGuide()
    case .review:
      openAppStoreReview()
    case .contact:
      showContactAlert()
    case .version:
      break
    }
  }
  
  private func presentWidgetGuide() {
    let vc = WidgetGuideViewController()
    if let sheet = vc.sheetPresentationController {
      sheet.detents = [.large()]
      sheet.prefersGrabberVisible = true
    }
    present(vc, animated: true)
  }
  
  private func presentProfileSetting() {
    let profileStore = ProfileStore(provider: store.provider)
    let vc = ProfileSettingViewController(store: profileStore)
    if let sheet = vc.sheetPresentationController {
      sheet.detents = [.large()]
      sheet.prefersGrabberVisible = true
    }
    present(vc, animated: true)
  }
  
  private func presentGoalSetting() {
    let vc = GoalSettingViewController(
      currentGoal: store.goalValue,
      onSave: { [weak self] _ in
        Task {
          await self?.store.send(.loadGoal)
          self?.tableView.reloadData()
        }
      },
      provider: store.provider
    )
    if let sheet = vc.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.prefersGrabberVisible = true
    }
    present(vc, animated: true)
  }
  
  private func presentQuickButtonSetting() {
    let vc = QuickButtonSettingViewController(
      currentButtons: store.quickButtons,
      onSave: { [weak self] buttons in
        Task {
          await self?.store.send(.updateQuickButtons(buttons))
          self?.tableView.reloadData()
        }
      }
    )
    if let sheet = vc.sheetPresentationController {
      sheet.detents = [.large()]
      sheet.prefersGrabberVisible = true
    }
    present(vc, animated: true)
  }
  
  private func openNotificationSettings() {
    let notificationStore = NotificationStore(provider: store.provider)
    let vc = NotificationSettingViewController(store: notificationStore)
    if let sheet = vc.sheetPresentationController {
      sheet.detents = [.large()]
      sheet.prefersGrabberVisible = true
    }
    present(vc, animated: true)
  }
  
  private func openAppStoreReview() {
    let url = "itms-apps://itunes.apple.com/app/id1563673158?action=write-review"
    if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url)
    }
  }
  
  private func showContactAlert() {
    let alert = UIAlertController(
      title: NSLocalizedString("contact.title", comment: ""),
      message: NSLocalizedString("contact.message", comment: ""),
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: NSLocalizedString("common.confirm", comment: ""), style: .default))
    present(alert, animated: true)
  }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    sections[section].items.count
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    DS.Size.cellHeight
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = UIView()
    
    let label = UILabel()
    label.text = sections[section].title.uppercased()
    label.font = DS.Font.captionSemibold
    label.textColor = DS.Color.textSecondary
    label.addCharacterSpacing(kernValue: 0.5)
    
    headerView.addSubview(label)
    label.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(DS.Spacing.xxl)
      $0.bottom.equalToSuperview().offset(-DS.Spacing.xs)
    }
    
    return headerView
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    section == 0 ? DS.Spacing.lg : DS.Spacing.xxl
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.cellID, for: indexPath) as! SettingsCell
    let item = sections[indexPath.section].items[indexPath.row]
    
    var detail: String? = item.detail
    switch item.action {
    case .goal:
      detail = "\(store.goalValue)ml"
    case .quickButtons:
      detail = store.quickButtons.map { "\($0)" }.joined(separator: ", ") + "ml"
    case .version:
      detail = store.appVersion
    default:
      break
    }
    
    let isFirst = indexPath.row == 0
    let isLast = indexPath.row == sections[indexPath.section].items.count - 1
    
    cell.configure(icon: item.icon, title: item.title, detail: detail, showArrow: item.action != .version, isLast: isLast)
    
    if isFirst && isLast {
      cell.layer.cornerRadius = DS.Size.cornerRadiusMedium
      cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    } else if isFirst {
      cell.layer.cornerRadius = DS.Size.cornerRadiusMedium
      cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    } else if isLast {
      cell.layer.cornerRadius = DS.Size.cornerRadiusMedium
      cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    } else {
      cell.layer.cornerRadius = 0
    }
    cell.clipsToBounds = true
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let action = sections[indexPath.section].items[indexPath.row].action
    handleAction(action)
  }
}
