import UIKit
import SnapKit

final class ProfileSettingViewController: BaseViewController {
  
  private let store: ProfileStore
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = L.Profile.title
    label.font = DS.Font.title1
    label.textColor = DS.Color.textPrimary
    return label
  }()
  
  private lazy var healthKitSection: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 12
    return view
  }()
  
  private lazy var healthKitIcon: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(systemName: "heart.fill")
    imageView.tintColor = .systemRed
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private lazy var healthKitLabel: UILabel = {
    let label = UILabel()
    label.text = L.Profile.healthKitTitle
    label.font = DS.Font.headline
    label.textColor = DS.Color.textPrimary
    return label
  }()
  
  private lazy var healthKitSwitch: UISwitch = {
    let toggle = UISwitch()
    toggle.onTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    return toggle
  }()
  
  private lazy var healthKitDescription: UILabel = {
    let label = UILabel()
    label.text = L.Profile.healthKitDescription
    label.font = DS.Font.footnote
    label.textColor = DS.Color.textSecondary
    return label
  }()
  
  private lazy var weightSection: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.cornerRadius = 12
    return view
  }()
  
  private lazy var weightLabel: UILabel = {
    let label = UILabel()
    label.text = L.Profile.weight
    label.font = DS.Font.subheadSemibold
    label.textColor = DS.Color.textSecondary
    return label
  }()
  
  private lazy var weightValueLabel: UILabel = {
    let label = UILabel()
    label.text = "65 kg"
    label.font = .systemFont(ofSize: 32, weight: .bold)
    label.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    label.textAlignment = .center
    return label
  }()
  
  private lazy var weightSlider: UISlider = {
    let slider = UISlider()
    slider.minimumValue = 30
    slider.maximumValue = 150
    slider.value = 65
    slider.minimumTrackTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    return slider
  }()
  
  private lazy var weightRangeLabel: UILabel = {
    let label = UILabel()
    label.text = L.Profile.weightRange
    label.font = DS.Font.caption
    label.textColor = DS.Color.textTertiary
    label.textAlignment = .center
    return label
  }()
  
  private lazy var recommendSection: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1)
    view.layer.cornerRadius = 12
    return view
  }()
  
  private lazy var recommendIcon: UILabel = {
    let label = UILabel()
    label.text = "💡"
    label.font = .systemFont(ofSize: 24)
    return label
  }()
  
  private lazy var recommendTitleLabel: UILabel = {
    let label = UILabel()
    label.text = L.Profile.recommendedTitle
    label.font = DS.Font.subheadMedium
    label.textColor = DS.Color.textPrimary
    return label
  }()
  
  private lazy var recommendValueLabel: UILabel = {
    let label = UILabel()
    label.text = "2,145ml"
    label.font = .systemFont(ofSize: 28, weight: .bold)
    label.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    return label
  }()
  
  private lazy var recommendDescLabel: UILabel = {
    let label = UILabel()
    label.text = L.Profile.recommendedDescription
    label.font = DS.Font.caption
    label.textColor = DS.Color.textSecondary
    return label
  }()
  
  private lazy var applyButton: UIButton = {
    let button = UIButton()
    var config = UIButton.Configuration.filled()
    config.title = L.Profile.applyButton
    config.baseBackgroundColor = DS.Color.primary
    config.baseForegroundColor = .white
    config.cornerStyle = .large
    button.configuration = config
    return button
  }()
  
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
    weightSlider.addTarget(self, action: #selector(weightSliderEnded), for: [.touchUpInside, .touchUpOutside, .touchCancel])
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
      
      let message = L.Profile.applySuccessMessage("\(store.recommendedIntake)")
       let alert = UIAlertController(
         title: L.Profile.applySuccessTitle,
         message: message,
         preferredStyle: .alert
       )
       alert.addAction(UIAlertAction(title: L.Common.confirm, style: .default) { [weak self] _ in
        self?.dismiss(animated: true)
      })
      present(alert, animated: true)
    }
  }
}
