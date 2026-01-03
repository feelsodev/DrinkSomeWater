import UIKit

final class GoalSettingViewController: UIViewController {
    
    private var currentGoal: Int
    private let onSave: (Int) -> Void
    private let provider: ServiceProviderProtocol
    
    private let titleLabel = UILabel().then {
        $0.text = "일일 목표량 설정"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .darkGray
        $0.textAlignment = .center
    }
    
    private let valueLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 48, weight: .bold)
        $0.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        $0.textAlignment = .center
    }
    
    private lazy var slider = UISlider().then {
        $0.minimumValue = 1500
        $0.maximumValue = 4500
        $0.value = Float(currentGoal)
        $0.tintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        $0.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    private let minLabel = UILabel().then {
        $0.text = "1,500ml"
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = .gray
    }
    
    private let maxLabel = UILabel().then {
        $0.text = "4,500ml"
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = .gray
    }
    
    private let saveButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "💧 적용"
        config.baseBackgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        config.baseForegroundColor = .white
        config.cornerStyle = .large
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
            var attr = attr
            attr.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            return attr
        }
        $0.configuration = config
    }
    
    init(currentGoal: Int, onSave: @escaping (Int) -> Void, provider: ServiceProviderProtocol) {
        self.currentGoal = currentGoal
        self.onSave = onSave
        self.provider = provider
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
        updateValueLabel()
    }
    
    private func setupConstraints() {
        view.addSubviews([titleLabel, valueLabel, slider, minLabel, maxLabel, saveButton])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.centerX.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
        
        slider.snp.makeConstraints {
            $0.top.equalTo(valueLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
        }
        
        minLabel.snp.makeConstraints {
            $0.top.equalTo(slider.snp.bottom).offset(8)
            $0.leading.equalTo(slider)
        }
        
        maxLabel.snp.makeConstraints {
            $0.top.equalTo(slider.snp.bottom).offset(8)
            $0.trailing.equalTo(slider)
        }
        
        saveButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(56)
        }
    }
    
    private func setupActions() {
        saveButton.addAction(UIAction { [weak self] _ in
            self?.saveGoal()
        }, for: .touchUpInside)
    }
    
    @objc private func sliderChanged() {
        let value = Int(slider.value)
        let roundedValue = value - value % 100
        currentGoal = roundedValue
        updateValueLabel()
    }
    
    private func updateValueLabel() {
        valueLabel.text = "\(currentGoal)ml"
    }
    
    private func saveGoal() {
        Task {
            _ = await provider.waterService.updateGoal(to: currentGoal)
            onSave(currentGoal)
            dismiss(animated: true)
        }
    }
}
