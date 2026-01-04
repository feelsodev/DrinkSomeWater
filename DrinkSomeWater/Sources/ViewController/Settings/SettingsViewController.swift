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
        $0.text = "설정"
        $0.font = .systemFont(ofSize: 32, weight: .bold)
        $0.textColor = .white
    }
    
    private let subtitleLabel = UILabel().then {
        $0.text = "앱을 나만의 스타일로"
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .white.withAlphaComponent(0.8)
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1)
        $0.delegate = self
        $0.dataSource = self
        $0.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.cellID)
        $0.separatorStyle = .none
        $0.showsVerticalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 0)
        $0.sectionHeaderTopPadding = 0
    }
    
    private let sections: [(title: String, items: [(icon: String, title: String, detail: String?, action: SettingsAction)])] = [
        ("목표", [
            ("target", "일일 목표량", nil, .goal)
        ]),
        ("퀵버튼", [
            ("bolt.fill", "퀵버튼 설정", nil, .quickButtons)
        ]),
        ("알림", [
            ("bell.fill", "물 마시기 알림", nil, .notification)
        ]),
        ("지원", [
            ("star.fill", "앱 리뷰 남기기", nil, .review),
            ("envelope.fill", "문의하기", nil, .contact)
        ]),
        ("정보", [
            ("info.circle.fill", "버전", nil, .version)
        ])
    ]
    
    enum SettingsAction {
        case goal, quickButtons, notification, review, contact, version
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
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1)
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
            UIColor(red: 0.35, green: 0.75, blue: 0.95, alpha: 1).cgColor,
            UIColor(red: 0.25, green: 0.65, blue: 0.90, alpha: 1).cgColor
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
            $0.height.equalTo(180)
        }
        
        headerIconView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(12)
            $0.leading.equalToSuperview().offset(24)
            $0.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(headerIconView.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(24)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(24)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(-20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        tableView.layer.cornerRadius = 20
        tableView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tableView.clipsToBounds = true
    }
    
    private func handleAction(_ action: SettingsAction) {
        switch action {
        case .goal:
            presentGoalSetting()
        case .quickButtons:
            presentQuickButtonSetting()
        case .notification:
            openNotificationSettings()
        case .review:
            openAppStoreReview()
        case .contact:
            showContactAlert()
        case .version:
            break
        }
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
            title: "문의",
            message: "feelsodev@gmail.com 으로 문의 바랍니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
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
        56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        let label = UILabel()
        label.text = sections[section].title
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.55, alpha: 1)
        
        headerView.addSubview(label)
        label.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(32)
            $0.bottom.equalToSuperview().offset(-6)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 32 : 40
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
        
        cell.configure(icon: item.icon, title: item.title, detail: detail, showArrow: item.action != .version)
        
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == sections[indexPath.section].items.count - 1
        
        if isFirst && isLast {
            cell.layer.cornerRadius = 12
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else if isFirst {
            cell.layer.cornerRadius = 12
            cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else if isLast {
            cell.layer.cornerRadius = 12
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
