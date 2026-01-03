import UIKit
import UserNotifications

final class MainViewController: BaseViewController {
    
    private let store: MainStore
    
    private let waterCapacity = UILabel().then {
        $0.font = .systemFont(ofSize: 40, weight: .bold)
        $0.textColor = .darkGray
        $0.numberOfLines = 0
    }
    
    private let descript = UILabel().then {
        $0.font = .systemFont(ofSize: 20, weight: .medium)
        $0.textColor = .darkGray
        $0.numberOfLines = 0
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
            frame: CGRect(x: 0, y: 0, width: 200, height: viewHeight / 2),
            color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        )
        view.layer.borderWidth = 0.1
        view.layer.cornerRadius = 15
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var waveBackground: WaveAnimationView = {
        let view = WaveAnimationView(
            frame: CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight),
            color: #colorLiteral(red: 0.6, green: 0.8352941176, blue: 0.9019607843, alpha: 1)
        )
        view.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.setProgress(0.5)
        return view
    }()
    
    private let addWaterButton = UIButton().then {
        $0.contentMode = .scaleAspectFill
        $0.tintColor = .none
    }
    
    private let settingButton = UIButton().then {
        $0.setImage(UIImage(systemName: "slider.horizontal.3")?
            .withConfiguration(UIImage.SymbolConfiguration(weight: .bold)), for: .normal)
        $0.tintColor = .white
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 0.0
        $0.layer.masksToBounds = false
        $0.layer.cornerRadius = 4.0
    }
    
    private let calendarButton = UIButton().then {
        $0.setImage(UIImage(systemName: "calendar")?
            .withConfiguration(UIImage.SymbolConfiguration(weight: .light)), for: .normal)
        $0.tintColor = .white
        $0.contentVerticalAlignment = .fill
        $0.contentHorizontalAlignment = .fill
        $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 0.0
        $0.layer.masksToBounds = false
        $0.layer.cornerRadius = 4.0
    }
    
    init(store: MainStore) {
        self.store = store
        super.init()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        bottle.startAnimation()
        waveBackground.startAnimation()
        observation = startObservation { [weak self] in self?.render() }
        
        Task {
            await store.send(.refreshGoal)
            await store.send(.refresh)
        }
    }
    
    private func setupActions() {
        settingButton.addAction(UIAction { [weak self] _ in
            self?.openSetting()
        }, for: .touchUpInside)
        
        addWaterButton.addAction(UIAction { [weak self] _ in
            self?.openDrink()
        }, for: .touchUpInside)
        
        calendarButton.addAction(UIAction { [weak self] _ in
            self?.openCalendar()
        }, for: .touchUpInside)
    }
    
    override func render() {
        let progress = store.progress
        let image = progress.waterImage
        addWaterButton.setImage(image, for: .normal)
        bottle.setProgress(progress)
        
        descript.text = "You achieved ".localized + progress.setPercentage + "TodaySuffix".localized
        waterCapacity.text = "\(Int(store.ml))ml"
    }
    
    private func openSetting() {
        let settingStore = store.createSettingStore()
        let vc = SettingViewController(store: settingStore)
        vc.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openDrink() {
        let drinkStore = store.createDrinkStore()
        let vc = DrinkViewController(store: drinkStore)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func openCalendar() {
        let calendarStore = store.createCalendarStore()
        let vc = CalendarViewController(store: calendarStore)
        present(vc, animated: true)
    }
    
    override func setupConstraints() {
        view.addSubview(waveBackground)
        waveBackground.addSubviews([
            calendarButton, settingButton, waterCapacity, descript,
            lid, lidNeck, bottle, addWaterButton
        ])
        
        waveBackground.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        calendarButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalToSuperview().offset(10)
            $0.width.equalTo(60)
            $0.height.equalTo(50)
        }
        settingButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.trailing.equalToSuperview().offset(-10)
            $0.width.equalTo(60)
            $0.height.equalTo(50)
        }
        waterCapacity.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(30)
            $0.centerX.equalToSuperview()
        }
        descript.snp.makeConstraints {
            $0.top.equalTo(waterCapacity.snp.bottom).offset(5)
            $0.centerX.equalToSuperview()
        }
        lid.snp.makeConstraints {
            $0.top.equalTo(descript.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(30)
        }
        lidNeck.snp.makeConstraints {
            $0.top.equalTo(lid.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(50)
            $0.height.equalTo(20)
        }
        bottle.snp.makeConstraints {
            $0.top.equalTo(lidNeck.snp.bottom)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(viewHeight / 2)
        }
        addWaterButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(viewHeight / 8)
        }
    }
}
