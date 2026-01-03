import UIKit
import Then
import SnapKit

final class LicensesViewController: BaseViewController {
    
    private let libraries = Liceses.getData()
    
    private let licenseLabel = UILabel().then {
        $0.text = "License".localized
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
    
    private lazy var licenseList = IntrinsicTableView().then {
        $0.register(LicenseCell.self, forCellReuseIdentifier: LicenseCell.cellID)
        $0.isScrollEnabled = false
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 0.5
        $0.separatorColor = .clear
        $0.dataSource = self
        $0.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)
    }
    
    override func setupConstraints() {
        view.addSubviews([
            licenseLabel, backButton, backgroundView, containerView, licenseList
        ])
        
        view.bringSubviewsToFront([
            licenseLabel, backButton, licenseList
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
        licenseLabel.snp.makeConstraints {
            $0.bottom.equalTo(licenseList.snp.top).offset(-20)
            $0.centerX.equalToSuperview()
        }
        licenseList.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(viewHeight / 4 - 40)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
        }
        containerView.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(viewHeight / 4 - 40)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.bottom.equalTo(licenseList.snp.bottom)
        }
    }
}

extension LicensesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        libraries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LicenseCell.cellID, for: indexPath) as! LicenseCell
        cell.library.text = libraries[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let library = libraries[indexPath.row]
        let vc = LicenseDetailViewController(library: library)
        present(vc, animated: true)
    }
}
