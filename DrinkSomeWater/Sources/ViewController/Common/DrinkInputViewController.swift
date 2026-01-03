import UIKit

final class DrinkInputViewController: UIViewController {
    
    private var amount: Int = 200
    private let onDrink: (Int) -> Void
    
    private let titleLabel = UILabel().then {
        $0.text = "물 섭취량 입력"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .darkGray
        $0.textAlignment = .center
    }
    
    private let cupImageView = UIImageView().then {
        $0.image = UIImage(named: "cup")
        $0.contentMode = .scaleAspectFit
    }
    
    private let valueLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 48, weight: .bold)
        $0.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        $0.textAlignment = .center
    }
    
    private lazy var slider = UISlider().then {
        $0.minimumValue = 30
        $0.maximumValue = 500
        $0.value = Float(amount)
        $0.tintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        $0.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    }
    
    private let minLabel = UILabel().then {
        $0.text = "30ml"
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = .gray
    }
    
    private let maxLabel = UILabel().then {
        $0.text = "500ml"
        $0.font = .systemFont(ofSize: 12, weight: .medium)
        $0.textColor = .gray
    }
    
    private let drinkButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "💧 마시기"
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
    
    init(onDrink: @escaping (Int) -> Void) {
        self.onDrink = onDrink
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
        view.addSubviews([titleLabel, cupImageView, valueLabel, slider, minLabel, maxLabel, drinkButton])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.centerX.equalToSuperview()
        }
        
        cupImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(cupImageView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
        
        slider.snp.makeConstraints {
            $0.top.equalTo(valueLabel.snp.bottom).offset(24)
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
        
        drinkButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            $0.height.equalTo(56)
        }
    }
    
    private func setupActions() {
        drinkButton.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.onDrink(self.amount)
            self.dismiss(animated: true)
        }, for: .touchUpInside)
    }
    
    @objc private func sliderChanged() {
        let value = Int(slider.value)
        let roundedValue = value - value % 10
        amount = roundedValue
        updateValueLabel()
    }
    
    private func updateValueLabel() {
        valueLabel.text = "\(amount)ml"
    }
}
