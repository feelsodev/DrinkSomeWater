import UIKit

final class DrinkViewController: BaseViewController {
    
    private let store: DrinkStore
    
    private var cupHeight: CGFloat { viewHeight * 0.37 }
    
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
    
    private let addWaterButton = UIButton().then {
        $0.tintColor = .blue
        $0.setImage(UIImage(systemName: "plus.circle")?
            .withConfiguration(UIImage.SymbolConfiguration(weight: .regular)), for: .normal)
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.layer.masksToBounds = true
    }
    
    private let subWaterButton = UIButton().then {
        $0.tintColor = .red
        $0.backgroundColor = .clear
        $0.setImage(UIImage(systemName: "minus.circle")?
            .withConfiguration(UIImage.SymbolConfiguration(weight: .regular)), for: .normal)
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
    }
    
    private let lid = UIView().then {
        $0.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private lazy var cup: WaveAnimationView = {
        let view = WaveAnimationView(
            frame: CGRect(x: 0, y: 0, width: viewWidth * 0.5, height: viewHeight * 0.37),
            color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        )
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        view.maskImage = UIImage(named: "cup")
        return view
    }()
    
    private let waterCapacity = UILabel().then {
        $0.font = .systemFont(ofSize: 40, weight: .bold)
        $0.textColor = .darkGray
        $0.numberOfLines = 0
    }
    
    private let completeButton = UIButton().then {
        $0.setTitle("DRINK", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 10
        $0.layer.masksToBounds = true
    }
    
    private lazy var waveBackground: WaveAnimationView = {
        let view = WaveAnimationView(
            frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight),
            frontColor: .clear,
            backColor: #colorLiteral(red: 0.6, green: 0.8352941176, blue: 0.9019607843, alpha: 1)
        )
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        return view
    }()
    
    private let cup500Button = UIButton().then {
        $0.setImage(UIImage(named: "cup500"), for: .normal)
    }
    
    private let cup300Button = UIButton().then {
        $0.setImage(UIImage(named: "cup300"), for: .normal)
    }
    
    private let capacity500 = UILabel().then {
        $0.text = "500ml"
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }
    
    private let capacity300 = UILabel().then {
        $0.text = "300ml"
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 14, weight: .bold)
    }
    
    init(store: DrinkStore) {
        self.store = store
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cup.stopAnimation()
        waveBackground.stopAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupGestures()
        cup.startAnimation()
        waveBackground.startAnimation()
        observation = startObservation { [weak self] in self?.render() }
    }
    
    private func setupActions() {
        backButton.addAction(UIAction { [weak self] _ in
            Task { await self?.store.send(.cancel) }
        }, for: .touchUpInside)
        
        addWaterButton.addAction(UIAction { [weak self] _ in
            Task { await self?.store.send(.increaseWater) }
        }, for: .touchUpInside)
        
        subWaterButton.addAction(UIAction { [weak self] _ in
            Task { await self?.store.send(.decreaseWater) }
        }, for: .touchUpInside)
        
        cup500Button.addAction(UIAction { [weak self] _ in
            Task { await self?.store.send(.set500) }
        }, for: .touchUpInside)
        
        cup300Button.addAction(UIAction { [weak self] _ in
            Task { await self?.store.send(.set300) }
        }, for: .touchUpInside)
        
        completeButton.addAction(UIAction { [weak self] _ in
            Task { await self?.store.send(.addWater) }
        }, for: .touchUpInside)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCupTap(_:)))
        cup.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCupPan(_:)))
        cup.addGestureRecognizer(panGesture)
    }
    
    @objc private func handleCupTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: cup)
        let height = cupHeight - point.y
        let progress = height / cupHeight
        
        guard progress >= 0 && progress <= 1 else { return }
        Task { await store.send(.tapCup(Float(progress))) }
    }
    
    @objc private func handleCupPan(_ gesture: UIPanGestureRecognizer) {
        let y = gesture.location(in: cup).y
        guard y >= 0 && y <= cupHeight else { return }
        
        let scrollValue = y * 500 / cupHeight
        Task { await store.send(.didScroll(Float(scrollValue))) }
    }
    
    override func render() {
        waterCapacity.text = "\(Int(store.currentValue))ml"
        cup.setProgress(store.currentValue / store.maxValue)
        
        if store.shouldDismiss {
            navigationController?.popViewController(animated: true)
        }
    }
    
    override func setupConstraints() {
        view.addSubview(waveBackground)
        waveBackground.addSubviews([
            backButton, lid, cup, addWaterButton, subWaterButton, waterCapacity,
            completeButton, cup500Button, cup300Button, capacity500, capacity300
        ])
        
        waveBackground.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        backButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.width.height.equalTo(50)
        }
        lid.snp.makeConstraints {
            $0.bottom.equalTo(cup.snp.top)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(viewWidth * 0.55)
            $0.height.equalTo(40)
        }
        cup.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.width.equalTo(viewWidth * 0.5)
            $0.height.equalTo(viewHeight * 0.37)
        }
        addWaterButton.snp.makeConstraints {
            $0.top.equalTo(cup.snp.bottom).offset(10)
            $0.leading.equalTo(cup.snp.leading)
            $0.width.height.equalTo(70)
        }
        subWaterButton.snp.makeConstraints {
            $0.top.equalTo(cup.snp.bottom).offset(10)
            $0.trailing.equalTo(cup.snp.trailing)
            $0.width.height.equalTo(70)
        }
        waterCapacity.snp.makeConstraints {
            $0.bottom.equalTo(lid.snp.top).offset(-30)
            $0.centerX.equalToSuperview()
        }
        completeButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(40)
        }
        cup500Button.snp.makeConstraints {
            $0.leading.equalTo(completeButton.snp.trailing).offset(50)
            $0.centerY.equalTo(completeButton.snp.centerY)
            $0.width.equalTo(30)
            $0.height.equalTo(50)
        }
        cup300Button.snp.makeConstraints {
            $0.trailing.equalTo(completeButton.snp.leading).offset(-50)
            $0.centerY.equalTo(completeButton.snp.centerY)
            $0.width.equalTo(30)
            $0.height.equalTo(50)
        }
        capacity500.snp.makeConstraints {
            $0.top.equalTo(cup500Button.snp.bottom).offset(5)
            $0.centerX.equalTo(cup500Button.snp.centerX)
        }
        capacity300.snp.makeConstraints {
            $0.top.equalTo(cup300Button.snp.bottom).offset(5)
            $0.centerX.equalTo(cup300Button.snp.centerX)
        }
    }
}
