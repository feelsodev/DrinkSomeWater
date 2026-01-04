import UIKit

final class HomeViewController: BaseViewController {
  
  private let store: HomeStore
  
  private lazy var waveBackground: WaveAnimationView = {
    let view = WaveAnimationView(
      frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight),
      color: #colorLiteral(red: 0.6, green: 0.8352941176, blue: 0.9019607843, alpha: 1)
    )
    view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    view.setProgress(0.5)
    return view
  }()
  
  private let goalButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.image = UIImage(systemName: "flag.fill")?
      .withConfiguration(UIImage.SymbolConfiguration(pointSize: 22, weight: .medium))
    config.baseForegroundColor = .white
    $0.configuration = config
  }
  
  private let waterCapacity = UILabel().then {
    $0.font = .systemFont(ofSize: 48, weight: .bold)
    $0.textColor = .darkGray
    $0.textAlignment = .center
  }
  
  private let goalLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 18, weight: .medium)
    $0.textColor = .gray
    $0.textAlignment = .center
  }
  
  private let messageLabel = UILabel().then {
    $0.font = .systemFont(ofSize: 16, weight: .medium)
    $0.textColor = .darkGray
    $0.textAlignment = .center
    $0.backgroundColor = UIColor.white.withAlphaComponent(0.8)
    $0.layer.cornerRadius = 12
    $0.clipsToBounds = true
  }
  
  private let lid = UIView().then {
    $0.layer.borderWidth = 0.1
    $0.layer.cornerRadius = 5
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.masksToBounds = true
    $0.backgroundColor = #colorLiteral(red: 0.07843137255, green: 0.5605390058, blue: 1, alpha: 1)
  }
  
  private let lidNeck = UIView().then {
    $0.layer.borderWidth = 0.1
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.masksToBounds = true
    $0.backgroundColor = .white
  }
  
  private lazy var bottle: WaveAnimationView = {
    let view = WaveAnimationView(
      frame: CGRect(x: 0, y: 0, width: 180, height: viewHeight * 0.35),
      color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    )
    view.layer.borderWidth = 0.1
    view.layer.cornerRadius = 15
    view.layer.borderColor = UIColor.white.cgColor
    view.layer.masksToBounds = true
    view.backgroundColor = .white
    return view
  }()
  
  private let quickButtonsLabel = UILabel().then {
    $0.text = "빠른 추가"
    $0.font = .systemFont(ofSize: 14, weight: .medium)
    $0.textColor = .gray
  }
  
  private let editQuickButtonsButton = UIButton().then {
    var config = UIButton.Configuration.plain()
    config.title = "편집"
    config.baseForegroundColor = .darkGray
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
      var attr = attr
      attr.font = UIFont.systemFont(ofSize: 14, weight: .medium)
      return attr
    }
    $0.configuration = config
  }
  
  private lazy var defaultButtonStack = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.spacing = 12
  }
  
  private lazy var customButtonStack = UIStackView().then {
    $0.axis = .horizontal
    $0.distribution = .fillEqually
    $0.spacing = 12
  }
  

  
  init(store: HomeStore) {
    self.store = store
    super.init()
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationController?.isNavigationBarHidden = true
    setupQuickButtons()
    setupActions()
    bottle.startAnimation()
    waveBackground.startAnimation()
    observation = startObservation { [weak self] in self?.render() }
    
    Task {
      await store.send(.refreshGoal)
      await store.send(.refresh)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    Task {
      await store.send(.refreshGoal)
      await store.send(.refreshQuickButtons)
      await store.send(.refresh)
      setupQuickButtons()
    }
  }
  
  private func setupQuickButtons() {
    defaultButtonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    customButtonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
    
    let buttons = store.quickButtons
    let midPoint = (buttons.count + 1) / 2
    
    for (index, amount) in buttons.enumerated() {
      let button = createQuickButton(amount: amount)
      if index < midPoint {
        defaultButtonStack.addArrangedSubview(button)
      } else {
        customButtonStack.addArrangedSubview(button)
      }
    }
    
  }
  
  private func createQuickButton(amount: Int) -> UIButton {
    let button = UIButton()
    var config = UIButton.Configuration.filled()
    config.title = "+\(amount)ml"
    config.baseBackgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    config.baseForegroundColor = .white
    config.cornerStyle = .large
    config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 4, bottom: 8, trailing: 4)
    config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attr in
      var attr = attr
      attr.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
      return attr
    }
    button.configuration = config
    button.layer.shadowColor = UIColor.black.cgColor
    button.layer.shadowOffset = CGSize(width: 0, height: 2)
    button.layer.shadowOpacity = 0.1
    button.layer.shadowRadius = 4
    button.tag = amount
    button.addAction(UIAction { [weak self] _ in
      Task { await self?.store.send(.addWater(amount)) }
    }, for: .touchUpInside)
    return button
  }
  
  private func setupActions() {
    goalButton.addAction(UIAction { [weak self] _ in
      self?.presentGoalSetting()
    }, for: .touchUpInside)
    
    editQuickButtonsButton.addAction(UIAction { [weak self] _ in
      self?.presentQuickButtonSetting()
    }, for: .touchUpInside)
  }
  
  private func presentQuickButtonSetting() {
    let vc = QuickButtonSettingViewController(
      currentButtons: store.quickButtons,
      onSave: { [weak self] buttons in
        Task {
          self?.store.provider.userDefaultsService.set(value: buttons, forkey: .quickButtons)
          await self?.store.send(.refreshQuickButtons)
          self?.setupQuickButtons()
        }
      }
    )
    if let sheet = vc.sheetPresentationController {
      sheet.detents = [.large()]
      sheet.prefersGrabberVisible = true
    }
    present(vc, animated: true)
  }
  
  override func render() {
    let progress = store.progress
    bottle.setProgress(progress)
    
    waterCapacity.text = "\(Int(store.ml))ml"
    goalLabel.text = "목표 \(Int(store.total))ml"
    
    if store.remainingMl <= 0 {
      messageLabel.text = "  🎉 오늘 목표 달성!  "
    } else {
      messageLabel.text = "  ☀️ \(store.remainingCups)잔 더 마시면 목표 달성!  "
    }
  }
  
  private func presentGoalSetting() {
    let vc = GoalSettingViewController(
      currentGoal: Int(store.total),
      onSave: { [weak self] newGoal in
        Task {
          await self?.store.send(.refreshGoal)
          await self?.store.send(.refresh)
        }
      },
      provider: store.provider
    )
    if let sheet = vc.sheetPresentationController {
      sheet.detents = [.medium()]
      sheet.prefersGrabberVisible = true
    }
    present(vc, animated: true)
  }
  
  override func setupConstraints() {
    view.addSubview(waveBackground)
    waveBackground.addSubviews([
      goalButton, waterCapacity, goalLabel, messageLabel,
      lid, lidNeck, bottle,
      quickButtonsLabel, editQuickButtonsButton, defaultButtonStack, customButtonStack
    ])
    
    waveBackground.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    goalButton.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(8)
      $0.trailing.equalToSuperview().offset(-16)
      $0.width.height.equalTo(44)
    }
    
    waterCapacity.snp.makeConstraints {
      $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
      $0.centerX.equalToSuperview()
    }
    
    goalLabel.snp.makeConstraints {
      $0.top.equalTo(waterCapacity.snp.bottom).offset(4)
      $0.centerX.equalToSuperview()
    }
    
    messageLabel.snp.makeConstraints {
      $0.top.equalTo(goalLabel.snp.bottom).offset(12)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(36)
    }
    
    lid.snp.makeConstraints {
      $0.top.equalTo(messageLabel.snp.bottom).offset(20)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(90)
      $0.height.equalTo(25)
    }
    
    lidNeck.snp.makeConstraints {
      $0.top.equalTo(lid.snp.bottom)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(45)
      $0.height.equalTo(15)
    }
    
    bottle.snp.makeConstraints {
      $0.top.equalTo(lidNeck.snp.bottom)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(180)
      $0.height.equalTo(viewHeight * 0.35)
    }
    
    quickButtonsLabel.snp.makeConstraints {
      $0.top.equalTo(bottle.snp.bottom).offset(20)
      $0.leading.equalToSuperview().offset(20)
    }
    
    editQuickButtonsButton.snp.makeConstraints {
      $0.centerY.equalTo(quickButtonsLabel)
      $0.trailing.equalToSuperview().offset(-20)
    }
    
    defaultButtonStack.snp.makeConstraints {
      $0.top.equalTo(quickButtonsLabel.snp.bottom).offset(12)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.height.equalTo(50)
    }
    
    customButtonStack.snp.makeConstraints {
      $0.top.equalTo(defaultButtonStack.snp.bottom).offset(12)
      $0.leading.equalToSuperview().offset(20)
      $0.trailing.equalToSuperview().offset(-20)
      $0.height.equalTo(50)
    }
  }
}


