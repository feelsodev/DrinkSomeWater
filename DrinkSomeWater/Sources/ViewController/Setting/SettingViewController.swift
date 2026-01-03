import UIKit

final class SettingViewController: BaseViewController {
    
    private let store: SettingStore
    
    private let firstBeakerLine = Beaker(ml: "2000")
    private let secondBeakerLine = Beaker(ml: "2500")
    private let thirdBeakerLine = Beaker(ml: "3000")
    
    private let backButton = UIButton().then {
        $0.tintColor = .black
        $0.setImage(UIImage(systemName: "arrow.left")?
            .withConfiguration(UIImage.SymbolConfiguration(weight: .regular)), for: .normal)
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 0.0
        $0.layer.masksToBounds = false
        $0.layer.cornerRadius = 4.0
    }
    
    private let moreButton = UIButton().then {
        $0.tintColor = .white
        $0.setImage(UIImage(systemName: "exclamationmark.circle.fill")?
            .withConfiguration(UIImage.SymbolConfiguration(weight: .regular)), for: .normal)
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 0.0
        $0.layer.masksToBounds = false
        $0.layer.cornerRadius = 4.0
    }
    
    private let lineView = UIView().then {
        $0.backgroundColor = .black
    }
    
    private let goalWater = UILabel().then {
        $0.font = .systemFont(ofSize: 40, weight: .medium)
        $0.textColor = .darkGray
    }
    
    private let slider = UISlider().then {
        $0.maximumValue = 3000
        $0.minimumValue = 1500
        $0.tintColor = .darkGray
    }
    
    private let setButton = UIButton().then {
        $0.setTitle("SET", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private lazy var waveBackground: WaveAnimationView = {
        let view = WaveAnimationView(
            frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight),
            frontColor: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1),
            backColor: #colorLiteral(red: 0.2487368572, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        )
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        return view
    }()
    
    init(store: SettingStore) {
        self.store = store
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        waveBackground.stopAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        waveBackground.startAnimation()
        observation = startObservation { [weak self] in self?.render() }
        
        Task { await store.send(.loadGoal) }
    }
    
    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            Task { await self?.store.send(.cancel) }
        }, for: .touchUpInside)
        
        setButton.addAction(UIAction { [weak self] _ in
            Task { await self?.store.send(.setGoal) }
        }, for: .touchUpInside)
        
        moreButton.addAction(UIAction { [weak self] _ in
            self?.openInformation()
        }, for: .touchUpInside)
        
        slider.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let value = Int(slider.value)
            Task { await store.send(.changeGoalWater(value)) }
        }, for: .valueChanged)
    }
    
    override func render() {
        goalWater.text = "\(store.value) ml"
        waveBackground.setProgress(store.progress)
        slider.value = Float(store.value)
        
        if store.shouldDismiss {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func openInformation() {
        let informationStore = store.createInformationStore()
        let vc = InformationViewController(store: informationStore)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func setupConstraints() {
        view.addSubview(waveBackground)
        waveBackground.addSubviews([
            backButton, moreButton, firstBeakerLine, secondBeakerLine,
            thirdBeakerLine, lineView, goalWater, slider, setButton
        ])
        
        waveBackground.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.width.height.equalTo(50)
        }
        moreButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview().offset(-10)
            $0.width.height.equalTo(50)
        }
        goalWater.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
        }
        slider.snp.makeConstraints {
            $0.top.equalTo(goalWater.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(230)
            $0.height.equalTo(70)
        }
        setButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }
        firstBeakerLine.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottom).offset(-(viewHeight / 6))
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(5)
            $0.width.equalTo(80)
        }
        secondBeakerLine.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottom).offset(-(viewHeight / 3))
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(5)
            $0.width.equalTo(80)
        }
        thirdBeakerLine.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottom).offset(-(viewHeight / 2))
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(5)
            $0.width.equalTo(80)
        }
        lineView.snp.makeConstraints {
            $0.bottom.equalTo(view.snp.bottom).offset(-(viewHeight / 6))
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(5)
            $0.height.equalTo(viewHeight / 3)
        }
    }
}
