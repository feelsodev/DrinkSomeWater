import UIKit

final class QuickButtonSettingViewController: UIViewController {
    
    private var buttons: [Int]
    private let onSave: ([Int]) -> Void
    
    private let titleLabel = UILabel().then {
        $0.text = "퀵버튼 설정"
        $0.font = .systemFont(ofSize: 20, weight: .bold)
        $0.textColor = .darkGray
        $0.textAlignment = .center
    }
    
    private let descriptionLabel = UILabel().then {
        $0.text = "자주 마시는 용량을 설정하세요"
        $0.font = .systemFont(ofSize: 14, weight: .medium)
        $0.textColor = .gray
        $0.textAlignment = .center
    }
    
    private lazy var button1Stack = createButtonEditor(index: 0)
    private lazy var button2Stack = createButtonEditor(index: 1)
    
    private let saveButton = UIButton().then {
        var config = UIButton.Configuration.filled()
        config.title = "저장"
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
    
    init(currentButtons: [Int], onSave: @escaping ([Int]) -> Void) {
        self.buttons = currentButtons.count >= 2 ? currentButtons : [250, 400]
        self.onSave = onSave
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
    }
    
    private func createButtonEditor(index: Int) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        
        let label = UILabel()
        label.text = "버튼 \(index + 1)"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .darkGray
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let slider = UISlider()
        slider.minimumValue = 50
        slider.maximumValue = 500
        slider.value = Float(buttons.count > index ? buttons[index] : 250)
        slider.tintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        slider.tag = index
        slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
        
        let valueLabel = UILabel()
        valueLabel.text = "\(Int(slider.value))ml"
        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        valueLabel.tag = 100 + index
        valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        valueLabel.snp.makeConstraints { $0.width.equalTo(70) }
        
        stack.addArrangedSubview(label)
        stack.addArrangedSubview(slider)
        stack.addArrangedSubview(valueLabel)
        
        return stack
    }
    
    private func setupConstraints() {
        view.addSubviews([titleLabel, descriptionLabel, button1Stack, button2Stack, saveButton])
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.centerX.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
        
        button1Stack.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(44)
        }
        
        button2Stack.snp.makeConstraints {
            $0.top.equalTo(button1Stack.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(24)
            $0.trailing.equalToSuperview().offset(-24)
            $0.height.equalTo(44)
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
            guard let self = self else { return }
            self.onSave(self.buttons)
            self.dismiss(animated: true)
        }, for: .touchUpInside)
    }
    
    @objc private func sliderChanged(_ sender: UISlider) {
        let index = sender.tag
        let value = Int(sender.value)
        let roundedValue = value - value % 10
        
        if buttons.count > index {
            buttons[index] = roundedValue
        }
        
        if let valueLabel = view.viewWithTag(100 + index) as? UILabel {
            valueLabel.text = "\(roundedValue)ml"
        }
    }
}
