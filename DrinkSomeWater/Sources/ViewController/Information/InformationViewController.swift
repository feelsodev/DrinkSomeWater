import UIKit

final class InformationViewController: BaseViewController {
    
    private let store: InformationStore
    
    private let infoLabel = UILabel().then {
        $0.text = "Set".localized
        $0.textColor = #colorLiteral(red: 0.1739570114, green: 0.1739570114, blue: 0.1739570114, alpha: 1)
        $0.font = .systemFont(ofSize: 20, weight: .semibold)
    }
    
    private let backgroundView = UIView().then {
        $0.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        $0.isUserInteractionEnabled = false
    }
    
    private let containerView = UIView().then {
        $0.backgroundColor = .red
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = .zero
        $0.layer.shadowRadius = 10
        $0.layer.shadowOpacity = 0.5
    }
    
    private lazy var tableView = IntrinsicTableView().then {
        $0.register(InfoCell.self, forCellReuseIdentifier: InfoCell.cellID)
        $0.isScrollEnabled = false
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 0.5
        $0.separatorColor = .clear
        $0.rowHeight = 60
        $0.delegate = self
        $0.dataSource = self
    }
    
    private let backButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "arrow.left")?
            .withConfiguration(UIImage.SymbolConfiguration(weight: .regular))
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5)
        config.baseForegroundColor = .black
        $0.configuration = config
        $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 0.0
        $0.layer.masksToBounds = false
        $0.layer.cornerRadius = 4.0
    }
    
    init(store: InformationStore) {
        self.store = store
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        observation = startObservation { [weak self] in self?.render() }
        
        Task { await store.send(.viewDidLoad) }
    }
    
    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            Task { await self?.store.send(.cancel) }
        }, for: .touchUpInside)
    }
    
    override func render() {
        tableView.reloadData()
        
        if store.shouldDismiss {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func setupConstraints() {
        view.addSubviews([
            infoLabel, backButton, backgroundView, containerView, tableView
        ])
        view.bringSubviewsToFront([
            infoLabel, backButton, tableView
        ])
        
        backgroundView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(viewHeight / 4)
        }
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.width.height.equalTo(50)
        }
        infoLabel.snp.makeConstraints {
            $0.bottom.equalTo(tableView.snp.top).offset(-20)
            $0.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(viewHeight / 4 - 40)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
        }
        containerView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(viewHeight / 4 - 40)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.bottom.equalTo(tableView.snp.bottom)
        }
    }
}

extension InformationViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        store.infoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: InfoCell.cellID, for: indexPath) as! InfoCell
        let info = store.infoList[indexPath.row]
        cell.configure(with: info)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            if let bundleIdentifier = Bundle.main.bundleIdentifier,
               let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        case 1:
            let url = "itms-apps://itunes.apple.com/app/id1563673158"
            if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        case 2:
            Task { await store.send(.itemSelect(indexPath.row)) }
        case 4:
            let vc = LicensesViewController()
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
}
