import UIKit
import Then
import SnapKit

final class LicenseDetailViewController: UIViewController {
    
    private let library: String
    
    private let dismissButton = UIButton().then {
        $0.tintColor = .black
        $0.setImage(UIImage(systemName: "xmark")?
            .withConfiguration(UIImage.SymbolConfiguration(weight: .medium)), for: .normal)
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 0.0
        $0.layer.masksToBounds = false
        $0.layer.cornerRadius = 4.0
    }
    
    private let descript = UITextView().then {
        $0.textColor = .black
        $0.isEditable = false
        $0.isUserInteractionEnabled = true
        $0.dataDetectorTypes = .link
    }
    
    init(library: String) {
        self.library = library
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
        setupActions()
        
        if let descriptionText = licenseDescript(library: library) {
            descript.text = descriptionText
        }
    }
    
    private func setupActions() {
        dismissButton.addAction(UIAction { [weak self] _ in
            self?.dismiss(animated: true)
        }, for: .touchUpInside)
    }
    
    private func setupConstraints() {
        view.addSubview(dismissButton)
        view.addSubview(descript)
        
        dismissButton.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(8)
            $0.width.height.equalTo(30)
        }
        descript.snp.makeConstraints {
            $0.top.equalTo(dismissButton.snp.bottom).offset(5)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func licenseDescript(library: String) -> String? {
        let license = LicesesData()
        switch library {
        case "FSCalendar":
            return license.fsCalendar
        case "Then":
            return license.then
        case "SnapKit":
            return license.snapKit
        case "WaveAnimationView":
            return license.waveAnimationView
        default:
            return nil
        }
    }
}
