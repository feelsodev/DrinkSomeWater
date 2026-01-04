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
  
  private lazy var buttonStackView = UIStackView().then {
    $0.axis = .vertical
    $0.spacing = 20
    $0.distribution = .fillEqually
  }
  
  private let addButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.title = "+ 버튼 추가"
    config.baseForegroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
      var attr = attr
      attr.font = UIFont.systemFont(ofSize: 16, weight: .medium)
      return attr
    }
    $0.configuration = config
  }
  
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
    self.buttons = currentButtons.isEmpty ? [100, 200, 300, 500] : currentButtons
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
    setupButtonEditors()
    setupActions()
    updateAddButtonVisibility()
  }
  
  private func setupConstraints() {
    view.addSubviews([titleLabel, descriptionLabel, buttonStackView, addButton, saveButton])
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview().offset(32)
      $0.centerX.equalToSuperview()
    }
    
    descriptionLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(8)
      $0.centerX.equalToSuperview()
    }
    
    buttonStackView.snp.makeConstraints {
      $0.top.equalTo(descriptionLabel.snp.bottom).offset(24)
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
    }
    
    addButton.snp.makeConstraints {
      $0.top.equalTo(buttonStackView.snp.bottom).offset(12)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(44)
    }
    
    saveButton.snp.makeConstraints {
      $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
      $0.leading.equalToSuperview().offset(32)
      $0.trailing.equalToSuperview().offset(-32)
      $0.height.equalTo(56)
    }
  }
  
  private func setupButtonEditors() {
    buttonStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    for (index, value) in buttons.enumerated() {
      let editor = createButtonEditor(index: index, value: value)
      buttonStackView.addArrangedSubview(editor)
    }
  }
  
  private func createButtonEditor(index: Int, value: Int) -> UIView {
    let container = UIView()
    
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
    slider.maximumValue = 1000
    slider.value = Float(value)
    slider.tintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    slider.tag = index
    slider.addTarget(self, action: #selector(sliderChanged(_:)), for: .valueChanged)
    
    let valueLabel = UILabel()
    valueLabel.text = "\(value)ml"
    valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
    valueLabel.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    valueLabel.tag = 100 + index
    valueLabel.textAlignment = .right
    valueLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    
    let deleteButton = UIButton()
    deleteButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
    deleteButton.tintColor = .systemRed
    deleteButton.tag = 200 + index
    deleteButton.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
    deleteButton.isHidden = buttons.count <= 2
    
    stack.addArrangedSubview(label)
    stack.addArrangedSubview(slider)
    stack.addArrangedSubview(valueLabel)
    stack.addArrangedSubview(deleteButton)
    
    container.addSubview(stack)
    stack.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalTo(44)
    }
    
    valueLabel.snp.makeConstraints { $0.width.equalTo(60) }
    deleteButton.snp.makeConstraints { $0.width.equalTo(30) }
    
    return container
  }
  
  private func setupActions() {
    saveButton.addAction(UIAction { [weak self] _ in
      guard let self = self else { return }
      self.onSave(self.buttons)
      self.dismiss(animated: true)
    }, for: .touchUpInside)
    
    addButton.addAction(UIAction { [weak self] _ in
      self?.addNewButton()
    }, for: .touchUpInside)
  }
  
  private func addNewButton() {
    guard buttons.count < 6 else { return }
    buttons.append(250)
    setupButtonEditors()
    updateAddButtonVisibility()
  }
  
  @objc private func deleteButtonTapped(_ sender: UIButton) {
    let index = sender.tag - 200
    guard buttons.count > 2, index < buttons.count else { return }
    buttons.remove(at: index)
    setupButtonEditors()
    updateAddButtonVisibility()
  }
  
  @objc private func sliderChanged(_ sender: UISlider) {
    let index = sender.tag
    let value = Int(sender.value)
    let roundedValue = value - value % 10
    
    if index < buttons.count {
      buttons[index] = roundedValue
    }
    
    if let valueLabel = view.viewWithTag(100 + index) as? UILabel {
      valueLabel.text = "\(roundedValue)ml"
    }
  }
  
  private func updateAddButtonVisibility() {
    addButton.isHidden = buttons.count >= 6
    
    for (index, view) in buttonStackView.arrangedSubviews.enumerated() {
      if let deleteButton = view.viewWithTag(200 + index) as? UIButton {
        deleteButton.isHidden = buttons.count <= 2
      }
    }
  }
}
