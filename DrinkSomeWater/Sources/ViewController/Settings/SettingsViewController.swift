import UIKit
import SwiftUI
import SnapKit
import GoogleMobileAds

final class SettingsViewController: BaseViewController {
  
  private let store: SettingsStore
  
  private lazy var waveBackground: WaveAnimationView = {
    let view = WaveAnimationView(frame: .zero, color: DS.Color.primaryLight)
    view.backgroundColor = DS.Color.backgroundPrimary
    view.setProgress(0.5)
    return view
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = NSLocalizedString("settings.title", comment: "")
    label.font = DS.Font.display
    label.textColor = DS.Color.textPrimary
    return label
  }()
  
  private lazy var subtitleLabel: UILabel = {
    let label = UILabel()
    label.text = NSLocalizedString("settings.subtitle", comment: "")
    label.font = DS.Font.title3
    label.textColor = DS.Color.textSecondary
    return label
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .grouped)
    tableView.backgroundColor = .clear
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.cellID)
    tableView.separatorStyle = .none
    tableView.showsVerticalScrollIndicator = false
    tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
    tableView.sectionHeaderTopPadding = 0
    
    let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 120))
    headerView.addSubviews([titleLabel, subtitleLabel])
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(DS.Spacing.lg)
      $0.leading.equalToSuperview().offset(DS.Spacing.xl)
    }
    
    subtitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(DS.Spacing.xxs)
      $0.leading.equalToSuperview().offset(DS.Spacing.xl)
    }
    
    tableView.tableHeaderView = headerView
    return tableView
  }()
  
  private lazy var bannerView: GADBannerView = {
    let banner = AdMobService.shared.createBannerView(rootViewController: self)
    banner.delegate = self
    return banner
  }()
  
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
        ("heart.fill", NSLocalizedString("settings.support.developer", comment: ""), nil, .supportDeveloper),
        ("star.fill", NSLocalizedString("settings.review", comment: ""), nil, .review),
        ("envelope.fill", NSLocalizedString("settings.contact", comment: ""), nil, .contact)
      ]),
      (NSLocalizedString("settings.section.info", comment: ""), [
        ("info.circle.fill", NSLocalizedString("settings.version", comment: ""), nil, .version)
      ])
    ]
  }
  
  enum SettingsAction {
    case profile, goal, quickButtons, notification, widgetGuide, supportDeveloper, review, contact, version
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
    
    waveBackground.startAnimation()
    
    observation = startObservation { [weak self] in self?.render() }
    
    Task {
      await store.send(.loadGoal)
      await store.send(.loadQuickButtons)
    }
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
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
  
  override func setupConstraints() {
    view.addSubviews([waveBackground, tableView, bannerView])
    
    waveBackground.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    tableView.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(bannerView.snp.top)
    }
    
    bannerView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
      $0.height.equalTo(50)
    }
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
    case .supportDeveloper:
      showRewardedAd()
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
    let goalView = GoalSettingView(
      currentGoal: store.goalValue,
      provider: store.provider
    ) { [weak self] in
      Task {
        await self?.store.send(.loadGoal)
        self?.tableView.reloadData()
      }
    }
    let vc = UIHostingController(rootView: goalView)
    if let sheet = vc.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.prefersGrabberVisible = true
    }
    present(vc, animated: true)
  }
  
  private func presentQuickButtonSetting() {
    let quickButtonView = QuickButtonSettingView(
      currentButtons: store.quickButtons,
      provider: store.provider
    ) { [weak self] in
      Task {
        await self?.store.send(.loadQuickButtons)
        self?.tableView.reloadData()
      }
    }
    let vc = UIHostingController(rootView: quickButtonView)
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
  
  private func showRewardedAd() {
    guard AdMobService.shared.isRewardedAdReady else {
      let alert = UIAlertController(
        title: NSLocalizedString("ad.loading.title", comment: ""),
        message: NSLocalizedString("ad.loading.message", comment: ""),
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: NSLocalizedString("common.confirm", comment: ""), style: .default))
      present(alert, animated: true)
      return
    }
    
    AdMobService.shared.showRewardedAd(from: self) { [weak self] rewarded in
      if rewarded {
        let alert = UIAlertController(
          title: NSLocalizedString("ad.thanks.title", comment: ""),
          message: NSLocalizedString("ad.thanks.message", comment: ""),
          preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("common.confirm", comment: ""), style: .default))
        self?.present(alert, animated: true)
      }
    }
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
      cell.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    } else if isFirst {
      cell.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    } else if isLast {
      cell.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    } else {
      cell.maskedCorners = []
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let action = sections[indexPath.section].items[indexPath.row].action
    handleAction(action)
  }
}

extension SettingsViewController: GADBannerViewDelegate {
  nonisolated func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
    print("[AdMob] Banner ad loaded")
  }
  
  nonisolated func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
    print("[AdMob] Banner ad failed: \(error.localizedDescription)")
  }
}
