import UIKit
import SnapKit
import Then

final class WidgetGuideViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let headerImageView = UIImageView().then {
        $0.image = UIImage(systemName: "apps.iphone")
        $0.tintColor = UIColor(red: 0.35, green: 0.75, blue: 0.95, alpha: 1)
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "Widget Setup Guide"
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let stepsStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 24
        $0.alignment = .fill
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Widget Guide"
        setupUI()
        setupSteps()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews([headerImageView, titleLabel, stepsStackView])
        
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        
        headerImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(headerImageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        stepsStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-32)
        }
    }
    
    private func setupSteps() {
        let steps: [(String, String, String)] = [
            ("1", "Long press on Home Screen", "Press and hold on an empty area of your Home Screen until the apps start to jiggle."),
            ("2", "Tap the + button", "Tap the \"+\" button in the top left corner of the screen."),
            ("3", "Search for Gulp", "In the widget gallery, search for \"Gulp\" or \"Water\"."),
            ("4", "Choose widget size", "Select your preferred widget size:\n• Small: Shows water intake and progress\n• Medium: Includes quick add buttons"),
            ("5", "Add to Home Screen", "Tap \"Add Widget\" and position it where you'd like.")
        ]
        
        for step in steps {
            let stepView = createStepView(number: step.0, title: step.1, description: step.2)
            stepsStackView.addArrangedSubview(stepView)
        }
        
        let lockScreenSection = createSectionHeader("Lock Screen Widget")
        stepsStackView.addArrangedSubview(lockScreenSection)
        
        let lockScreenSteps: [(String, String, String)] = [
            ("1", "Long press on Lock Screen", "Press and hold on your Lock Screen and tap \"Customize\"."),
            ("2", "Select widget area", "Tap the widget area above or below the time."),
            ("3", "Add Gulp widget", "Search for \"Gulp\" and select the widget style you prefer.")
        ]
        
        for step in lockScreenSteps {
            let stepView = createStepView(number: step.0, title: step.1, description: step.2)
            stepsStackView.addArrangedSubview(stepView)
        }
    }
    
    private func createStepView(number: String, title: String, description: String) -> UIView {
        let container = UIView()
        
        let numberView = UIView().then {
            $0.backgroundColor = UIColor(red: 0.35, green: 0.75, blue: 0.95, alpha: 1)
            $0.layer.cornerRadius = 16
        }
        
        let numberLabel = UILabel().then {
            $0.text = number
            $0.font = .systemFont(ofSize: 16, weight: .bold)
            $0.textColor = .white
            $0.textAlignment = .center
        }
        
        let titleLabel = UILabel().then {
            $0.text = title
            $0.font = .systemFont(ofSize: 17, weight: .semibold)
        }
        
        let descLabel = UILabel().then {
            $0.text = description
            $0.font = .systemFont(ofSize: 15)
            $0.textColor = .secondaryLabel
            $0.numberOfLines = 0
        }
        
        container.addSubviews([numberView, titleLabel, descLabel])
        numberView.addSubview(numberLabel)
        
        numberView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
            $0.width.height.equalTo(32)
        }
        
        numberLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(numberView)
            $0.leading.equalTo(numberView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview()
        }
        
        descLabel.snp.makeConstraints {
            $0.top.equalTo(numberView.snp.bottom).offset(8)
            $0.leading.equalTo(numberView.snp.trailing).offset(12)
            $0.trailing.bottom.equalToSuperview()
        }
        
        return container
    }
    
    private func createSectionHeader(_ title: String) -> UIView {
        let container = UIView()
        
        let label = UILabel().then {
            $0.text = title
            $0.font = .systemFont(ofSize: 20, weight: .bold)
            $0.textColor = UIColor(red: 0.35, green: 0.75, blue: 0.95, alpha: 1)
        }
        
        let separator = UIView().then {
            $0.backgroundColor = .separator
        }
        
        container.addSubviews([separator, label])
        
        separator.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        label.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        
        return container
    }
}
