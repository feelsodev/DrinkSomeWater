//
//  MainViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/16.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift
import WaveAnimationView

class MainViewController: BaseViewController, View {
    let descript = UILabel().then {
        $0.text = "하루 목표치"
        $0.textColor = .black
    }
    let goal = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .black
    }
    lazy var wave = WaveAnimationView(
        frame: CGRect(x: 0, y: 0, width: 100, height: 300),
        frontColor: #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1),
        backColor: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
    ).then {
        $0.layer.cornerRadius = 50
        $0.layer.borderWidth = 1
        $0.layer.masksToBounds = true
        $0.setProgress(self.point)
        $0.startAnimation()
        $0.backgroundColor = .white
    }
    let addWarter = UIButton().then {
        $0.setImage(UIImage(named: "bulkuk"), for: .normal)
    }
    
    @objc func onChangeValueSlider(_ sender: UISlider) {
        self.wave.setProgress(sender.value)
    }
    
    var point: Float = 0.7 {
        didSet {
            self.wave.setProgress(self.point)
            self.view.layoutIfNeeded()
        }
    }
    
    init(reactor: MainViewReactor) {
        super.init()
        self.reactor = reactor
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = #colorLiteral(red: 0.6, green: 0.8352941176, blue: 0.9019607843, alpha: 1)
    }
    
    func bind(reactor: MainViewReactor) {
        // Action
        self.addWarter.rx.tap
            .map { reactor.reactorForCreatingDrink }
            .subscribe { [weak self] reactor in
                guard let `self` = self else { return }
                let vc = DrinkViewController(reactor: DrinkViewReactor())
                self.present(vc, animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
        
        // State
        reactor.state
            .map { $0.count }
            .distinctUntilChanged()
            .map { "\($0) ml" }
            .bind(to: goal.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func setupConstraints() {
        [self.descript, self.goal, self.wave, self.addWarter].forEach { self.view.addSubview($0) }
        
        self.descript.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
        }
        self.goal.snp.makeConstraints {
            $0.top.equalTo(self.descript.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(50)
        }
        self.wave.snp.makeConstraints {
            $0.top.equalTo(self.goal.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(300)
        }
        self.addWarter.snp.makeConstraints {
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(60)
        }
    }
}
