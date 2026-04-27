import UIKit
import SnapKit

final class WidgetGuideViewController: UIViewController {
  
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  
  private lazy var headerImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "apps.iphone")
    imageView.tintColor = UIColor(red: 0.35, green: 0.75, blue: 0.95, alpha: 1)
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = L.Widget.guideTitle
    label.font = .systemFont(ofSize: 24, weight: .bold)
    label.textAlignment = .center
    return label
  }()
  
  private lazy var stepsStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.spacing = 24
    stackView.alignment = .fill
    return stackView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    title = L.Widget.guideNavTitle
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
      ("1", L.Widget.guideStep1Title, L.Widget.guideStep1Description),
      ("2", L.Widget.guideStep2Title, L.Widget.guideStep2Description),
      ("3", L.Widget.guideStep3Title, L.Widget.guideStep3Description),
      ("4", L.Widget.guideStep4Title, L.Widget.guideStep4Description),
      ("5", L.Widget.guideStep5Title, L.Widget.guideStep5Description)
    ]

    for step in steps {
      let stepView = createStepView(number: step.0, title: step.1, description: step.2)
      stepsStackView.addArrangedSubview(stepView)
    }

    let lockScreenSection = createSectionHeader(L.Widget.guideLockScreenHeader)
    stepsStackView.addArrangedSubview(lockScreenSection)

    let lockScreenSteps: [(String, String, String)] = [
      ("1", L.Widget.guideLockScreenStep1Title, L.Widget.guideLockScreenStep1Description),
      ("2", L.Widget.guideLockScreenStep2Title, L.Widget.guideLockScreenStep2Description),
      ("3", L.Widget.guideLockScreenStep3Title, L.Widget.guideLockScreenStep3Description)
    ]

    for step in lockScreenSteps {
      let stepView = createStepView(number: step.0, title: step.1, description: step.2)
      stepsStackView.addArrangedSubview(stepView)
    }
  }
  
  private func createStepView(number: String, title: String, description: String) -> UIView {
    let container = UIView()
    
    let numberView: UIView = {
      let view = UIView()
      view.backgroundColor = UIColor(red: 0.35, green: 0.75, blue: 0.95, alpha: 1)
      view.layer.cornerRadius = 16
      return view
    }()
    
    let numberLabel: UILabel = {
      let label = UILabel()
      label.text = number
      label.font = .systemFont(ofSize: 16, weight: .bold)
      label.textColor = .white
      label.textAlignment = .center
      return label
    }()
    
    let titleLabel: UILabel = {
      let label = UILabel()
      label.text = title
      label.font = .systemFont(ofSize: 17, weight: .semibold)
      return label
    }()
    
    let descLabel: UILabel = {
      let label = UILabel()
      label.text = description
      label.font = .systemFont(ofSize: 15)
      label.textColor = .secondaryLabel
      label.numberOfLines = 0
      return label
    }()
    
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
    
    let label: UILabel = {
      let label = UILabel()
      label.text = title
      label.font = .systemFont(ofSize: 20, weight: .bold)
      label.textColor = UIColor(red: 0.35, green: 0.75, blue: 0.95, alpha: 1)
      return label
    }()
    
    let separator: UIView = {
      let view = UIView()
      view.backgroundColor = .separator
      return view
    }()
    
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
