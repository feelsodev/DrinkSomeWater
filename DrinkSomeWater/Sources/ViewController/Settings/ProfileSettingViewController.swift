import UIKit
import SnapKit
import Then

final class ProfileSettingViewController: BaseViewController {
    
    private let store: ProfileStore
    
    private let titleLabel = UILabel().then {
        $0.text = "프로필 설정"
        $0.font = .systemFont(ofSize: 24, weight: .bold)
        $0.textColor = .darkGray
    }
    
    private let healthKitSection = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let healthKitIcon = UIImageView().then {
        $0.image = UIImage(systemName: "heart.fill")
        $0.tintColor = .systemRed
        $0.contentMode = .scaleAspectFit
    }
    
    private let healthKitLabel = UILabel().then {
        $0.text = "Apple Health 연동"
        $0.font = .systemFont(ofSize: 17, weight: .medium)
        $0.textColor = .darkGray
    }
    
    private let healthKitSwitch = UISwitch().then {
        $0.onTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    }
    
    private let healthKitDescription = UILabel().then {
        $0.text = "건강 앱에서 체중을 자동으로 가져옵니다"
        $0.font = .systemFont(ofSize: 13, weight: .regular)
        $0.textColor = .gray
    }
    
    private let weightSection = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 12
    }
    
    private let weightLabel = UILabel().then {
        $0.text = "체중"
        $0.font = .systemFont(ofSize: 14, weight: .semibold)
        $0.textColor = .gray
    }
    
    private let weightValueLabel = UILabel().then {
        $0.text = "65 kg"
        $0.font = .systemFont(ofSize: 32, weight: .bold)
        $0.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        $0.textAlignment = .center
    }
    
    private lazy var weightSlider = UISlider().then {
        $0.minimumValue = 30
        $0.maximumValue = 150
        $0.value = 65
        $0.minimumTrackTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    }
    
    private let weightRangeLabel = UILabel().then {
        $0.text = "30kg ~ 150kg"
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .lightGray
        $0.textAlignment = .center
    }
    
    private let recommendSection = UIView().then {
        $0.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1)
        $0.layer.cornerRadius = 12
    }
    
    private let recommendIcon = UILabel().then {
        $0.text = "💡"
        $0.font = .systemFont(ofSize: 24)
    }
    
    private let recommendTitleLabel = UILabel().then {
        $0.text = "일일 권장 섭취량"
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .darkGray
    }
    
    private let recommendValueLabel = UILabel().then {
        $0.text = "2,145ml"
        $0.font = .systemFont(ofSize: 28, weight: .bold)
        $0.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    }
    
    private let recommendDescLabel = UILabel().then {
        $0.text = "체중 × 33ml 기준"
        $0.font = .systemFont(ofSize: 12, weight: .regular)
        $0.textColor = .gray
    }
    
    private let applyButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "이 권장량으로 목표 설정하기"
        config.baseBackgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        $0.configuration = config
    }
    
    init(store: ProfileStore) {
        self.store = store
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.98, alpha: 1)
        setupActions()
        observation = startObservation { [weak self] in self?.render() }
        
        Task {
            await store.send(.load)
        }
    }
    
    override func render() {
        let weight = store.profile.weight
        weightValueLabel.text = "\(Int(weight)) kg"
        weightSlider.value = Float(weight)
        weightSlider.isEnabled = !store.profile.useHealthKitWeight
        
        healthKitSwitch.isOn = store.profile.useHealthKitWeight
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let recommendedStr = formatter.string(from: NSNumber(value: store.recommendedIntake)) ?? "\(store.recommendedIntake)"
        recommendValueLabel.text = "\(recommendedStr)ml"
    }
    
    override func setupConstraints() {
        view.addSubviews([
            titleLabel,
            healthKitSection,
            weightSection,
            recommendSection,
            applyButton
        ])
        
        healthKitSection.addSubviews([healthKitIcon, healthKitLabel, healthKitSwitch, healthKitDescription])
        weightSection.addSubviews([weightLabel, weightValueLabel, weightSlider, weightRangeLabel])
        recommendSection.addSubviews([recommendIcon, recommendTitleLabel, recommendValueLabel, recommendDescLabel])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        
        healthKitSection.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        healthKitIcon.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(24)
        }
        
        healthKitLabel.snp.makeConstraints {
            $0.centerY.equalTo(healthKitIcon)
            $0.leading.equalTo(healthKitIcon.snp.trailing).offset(12)
        }
        
        healthKitSwitch.snp.makeConstraints {
            $0.centerY.equalTo(healthKitIcon)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        healthKitDescription.snp.makeConstraints {
            $0.top.equalTo(healthKitIcon.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        weightSection.snp.makeConstraints {
            $0.top.equalTo(healthKitSection.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        weightLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
        }
        
        weightValueLabel.snp.makeConstraints {
            $0.top.equalTo(weightLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        weightSlider.snp.makeConstraints {
            $0.top.equalTo(weightValueLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        weightRangeLabel.snp.makeConstraints {
            $0.top.equalTo(weightSlider.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        recommendSection.snp.makeConstraints {
            $0.top.equalTo(weightSection.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        recommendIcon.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
        }
        
        recommendTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(recommendIcon)
            $0.leading.equalTo(recommendIcon.snp.trailing).offset(8)
        }
        
        recommendValueLabel.snp.makeConstraints {
            $0.top.equalTo(recommendIcon.snp.bottom).offset(8)
            $0.leading.equalToSuperview().offset(16)
        }
        
        recommendDescLabel.snp.makeConstraints {
            $0.top.equalTo(recommendValueLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        applyButton.snp.makeConstraints {
            $0.top.equalTo(recommendSection.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
    }
    
    private func setupActions() {
        healthKitSwitch.addTarget(self, action: #selector(healthKitSwitchChanged), for: .valueChanged)
        weightSlider.addTarget(self, action: #selector(weightSliderChanged), for: .valueChanged)
        applyButton.addAction(UIAction { [weak self] _ in
            self?.applyRecommendedGoal()
        }, for: .touchUpInside)
    }
    
    @objc private func healthKitSwitchChanged() {
        Task {
            await store.send(.toggleHealthKitWeight(healthKitSwitch.isOn))
        }
    }
    
    @objc private func weightSliderChanged() {
        let weight = Double(Int(weightSlider.value))
        weightValueLabel.text = "\(Int(weight)) kg"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let recommended = Int(weight * 33)
        let recommendedStr = formatter.string(from: NSNumber(value: recommended)) ?? "\(recommended)"
        recommendValueLabel.text = "\(recommendedStr)ml"
    }
    
    @objc private func weightSliderEnded() {
        let weight = Double(Int(weightSlider.value))
        Task {
            await store.send(.updateWeight(weight))
        }
    }
    
    private func applyRecommendedGoal() {
        let weight = Double(Int(weightSlider.value))
        Task {
            await store.send(.updateWeight(weight))
            await store.send(.applyRecommendedGoal)
            
            let alert = UIAlertController(
                title: "목표 설정 완료",
                message: "일일 목표량이 \(store.recommendedIntake)ml로 설정되었습니다.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                self?.dismiss(animated: true)
            })
            present(alert, animated: true)
        }
    }
}
