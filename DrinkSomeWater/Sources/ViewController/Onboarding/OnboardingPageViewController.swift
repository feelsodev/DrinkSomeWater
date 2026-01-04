import UIKit
import SnapKit
import Then

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
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.tintColor = DS.Color.primary
    }
    
    private let titleLabel = UILabel().then {
        $0.font = DS.Font.title1
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private let descriptionLabel = UILabel().then {
        $0.font = DS.Font.body
        $0.textColor = DS.Color.textSecondary
        $0.textAlignment = .center
        $0.numberOfLines = 0
    }
    
    private lazy var goalSlider = UISlider().then {
        $0.minimumValue = 1500
        $0.maximumValue = 4500
        $0.value = Float(store.goal)
        $0.minimumTrackTintColor = DS.Color.primary
        $0.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    private let goalValueLabel = UILabel().then {
        $0.font = DS.Font.display
        $0.textColor = DS.Color.primary
        $0.textAlignment = .center
    }
    
    private let goalUnitLabel = UILabel().then {
        $0.text = "ml"
        $0.font = DS.Font.title3
        $0.textColor = DS.Color.textSecondary
        $0.textAlignment = .center
    }
    
    private lazy var actionButton = UIButton(type: .system).then {
        $0.backgroundColor = DS.Color.primary
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = DS.Font.headline
        $0.layer.cornerRadius = DS.Size.cornerRadiusMedium
        $0.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
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
            actionButton.setTitle(NSLocalizedString("onboarding.notification.button", comment: ""), for: .normal)
            
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
        case .notification:
            Task {
                await store.send(.requestNotificationPermission)
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
        case .notification:
            if store.isNotificationAuthorized {
                actionButton.setTitle(NSLocalizedString("onboarding.notification.enabled", comment: ""), for: .normal)
                actionButton.backgroundColor = .systemGreen
                actionButton.isEnabled = false
            }
        default:
            break
        }
    }
}
