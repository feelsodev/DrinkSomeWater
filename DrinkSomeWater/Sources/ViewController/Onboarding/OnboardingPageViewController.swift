import UIKit
import SnapKit

enum OnboardingPageType {
  case intro
  case goal
  case healthKit
  case notification
  case widget
}

final class OnboardingPageViewController: UIViewController {
  
  let pageType: OnboardingPageType
  private let store: OnboardingStore
  private var onComplete: (() -> Void)?
  
  private lazy var iconImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.tintColor = DS.Color.primary
    return imageView
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.font = DS.Font.title1
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = DS.Font.body
    label.textColor = DS.Color.textSecondary
    label.textAlignment = .center
    label.numberOfLines = 0
    return label
  }()
  
  private lazy var goalSlider: UISlider = {
    let slider = UISlider()
    slider.minimumValue = 1500
    slider.maximumValue = 4500
    slider.value = Float(store.goal)
    slider.minimumTrackTintColor = DS.Color.primary
    slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    return slider
  }()
  
  private lazy var goalValueLabel: UILabel = {
    let label = UILabel()
    label.font = DS.Font.display
    label.textColor = DS.Color.primary
    label.textAlignment = .center
    return label
  }()
  
  private lazy var goalUnitLabel: UILabel = {
    let label = UILabel()
    label.text = "ml"
    label.font = DS.Font.title3
    label.textColor = DS.Color.textSecondary
    label.textAlignment = .center
    return label
  }()
  
  private lazy var actionButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = DS.Color.primary
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = DS.Font.headline
    button.layer.cornerRadius = DS.Size.cornerRadiusMedium
    button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    return button
  }()
  
  init(pageType: OnboardingPageType, store: OnboardingStore, onComplete: (() -> Void)? = nil) {
    self.pageType = pageType
    self.store = store
    self.onComplete = onComplete
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    setupContent()
    setupConstraints()
  }
  
  private func setupContent() {
    switch pageType {
    case .intro:
      iconImageView.image = UIImage(systemName: "drop.fill")
      titleLabel.text = NSLocalizedString("onboarding.intro.title", comment: "")
      descriptionLabel.text = NSLocalizedString("onboarding.intro.description", comment: "")
      actionButton.isHidden = true
      
    case .goal:
      iconImageView.image = UIImage(systemName: "target")
      titleLabel.text = NSLocalizedString("onboarding.goal.title", comment: "")
      descriptionLabel.text = NSLocalizedString("onboarding.goal.description", comment: "")
      goalValueLabel.text = "\(store.goal)"
      actionButton.isHidden = true
      
    case .healthKit:
      iconImageView.image = UIImage(systemName: "heart.fill")
      iconImageView.tintColor = .systemPink
      titleLabel.text = NSLocalizedString("onboarding.healthkit.title", comment: "")
      descriptionLabel.text = NSLocalizedString("onboarding.healthkit.description", comment: "")
      actionButton.setTitle(NSLocalizedString("onboarding.healthkit.button", comment: ""), for: .normal)
      
    case .notification:
      iconImageView.image = UIImage(systemName: "bell.fill")
      iconImageView.tintColor = .systemOrange
      titleLabel.text = NSLocalizedString("onboarding.notification.title", comment: "")
      descriptionLabel.text = NSLocalizedString("onboarding.notification.description", comment: "")
      actionButton.isHidden = true
      
    case .widget:
      iconImageView.image = UIImage(systemName: "apps.iphone")
      titleLabel.text = NSLocalizedString("onboarding.widget.title", comment: "")
      descriptionLabel.text = NSLocalizedString("onboarding.widget.description", comment: "")
      actionButton.setTitle(NSLocalizedString("onboarding.widget.button", comment: ""), for: .normal)
    }
  }
  
  private func setupConstraints() {
    view.addSubviews([iconImageView, titleLabel, descriptionLabel, actionButton])
    
    iconImageView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(60)
      $0.centerX.equalToSuperview()
      $0.width.height.equalTo(100)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(iconImageView.snp.bottom).offset(32)
      $0.leading.trailing.equalToSuperview().inset(32)
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(16)
      $0.leading.trailing.equalToSuperview().inset(32)
    }
    
    if pageType == .goal {
      view.addSubviews([goalValueLabel, goalUnitLabel, goalSlider])
      
      goalValueLabel.snp.makeConstraints {
        $0.top.equalTo(descriptionLabel.snp.bottom).offset(40)
        $0.centerX.equalToSuperview()
      }
      
      goalUnitLabel.snp.makeConstraints {
        $0.top.equalTo(goalValueLabel.snp.bottom).offset(4)
        $0.centerX.equalToSuperview()
      }
      
      goalSlider.snp.makeConstraints {
        $0.top.equalTo(goalUnitLabel.snp.bottom).offset(32)
        $0.leading.trailing.equalToSuperview().inset(48)
      }
    }
    
    actionButton.snp.makeConstraints {
      $0.bottom.equalToSuperview().offset(-40)
      $0.leading.trailing.equalToSuperview().inset(32)
      $0.height.equalTo(56)
    }
  }
  
  @objc private func sliderChanged(_ sender: UISlider) {
    let roundedValue = Int(sender.value / 100) * 100
    goalValueLabel.text = "\(roundedValue)"
    Task {
      await store.send(.setGoal(roundedValue))
    }
  }
  
  @objc private func actionButtonTapped() {
    switch pageType {
    case .healthKit:
      Task {
        await store.send(.requestHealthKitPermission)
        updateButtonState()
      }
    case .widget:
      onComplete?()
    default:
      break
    }
  }
  
  private func updateButtonState() {
    switch pageType {
    case .healthKit:
      if store.isHealthKitAuthorized {
        actionButton.setTitle(NSLocalizedString("onboarding.healthkit.connected", comment: ""), for: .normal)
        actionButton.backgroundColor = .systemGreen
        actionButton.isEnabled = false
      }
    default:
      break
    }
  }
}
