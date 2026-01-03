import UIKit

final class SettingsViewController: BaseViewController {
    
    private let store: SettingsStore
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "설정"
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textColor = .white
    }
    
    private lazy var tableView = UITableView(frame: .zero, style: .insetGrouped).then {
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.register(SettingsCell.self, forCellReuseIdentifier: SettingsCell.cellID)
        $0.separatorStyle = .singleLine
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
            ("envelope.fill", "문의하기", nil, .contact),
            ("doc.text.fill", "오픈소스 라이선스", nil, .license)
        ]),
        ("정보", [
            ("info.circle.fill", "버전", nil, .version)
        ])
    ]
    
    enum SettingsAction {
        case goal, quickButtons, notification, review, contact, license, version
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
        navigationController?.isNavigationBarHidden = true
        observation = startObservation { [weak self] in self?.render() }
        
        Task {
            await store.send(.loadGoal)
            await store.send(.loadCustomButtons)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await store.send(.loadGoal)
            await store.send(.loadCustomButtons)
        }
    }
    
    override func render() {
        tableView.reloadData()
    }
    
    override func setupConstraints() {
        view.addSubviews([backgroundView, titleLabel, tableView])
        
        backgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(viewHeight / 5)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(20)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
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
        case .license:
            presentLicenses()
        case .version:
            break
        }
    }
    
    private func presentGoalSetting() {
        let vc = GoalSettingViewController(
            currentGoal: store.goalValue,
            onSave: { [weak self] _ in
                Task { await self?.store.send(.loadGoal) }
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
            currentButtons: store.customQuickButtons,
            onSave: { [weak self] buttons in
                Task { await self?.store.send(.updateCustomButtons(buttons)) }
            }
        )
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        present(vc, animated: true)
    }
    
    private func openNotificationSettings() {
        if let bundleIdentifier = Bundle.main.bundleIdentifier,
           let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
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
    
    private func presentLicenses() {
        let vc = LicensesViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.cellID, for: indexPath) as! SettingsCell
        let item = sections[indexPath.section].items[indexPath.row]
        
        var detail: String? = item.detail
        switch item.action {
        case .goal:
            detail = "\(store.goalValue)ml"
        case .quickButtons:
            detail = store.customQuickButtons.map { "\($0)" }.joined(separator: ", ") + "ml"
        case .version:
            detail = store.appVersion
        default:
            break
        }
        
        cell.configure(icon: item.icon, title: item.title, detail: detail, showArrow: item.action != .version)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let action = sections[indexPath.section].items[indexPath.row].action
        handleAction(action)
    }
}


