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
    let addButton = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.addTarget(self, action: #selector(addWarter), for: .touchUpInside)
    }
    let subButton = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.setTitleColor(.black, for: .normal)
    }
    let wave = WaveAnimationView(frame: CGRect(x: 200, y: 200, width: 100, height: 100),
                                 frontColor: .gray,
                                 backColor: .darkGray)
    
    var point: Float = 0.1 {
        didSet {
            self.wave.setProgress(self.point)
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        wave.layer.cornerRadius = 50
        wave.layer.masksToBounds = true
        wave.setProgress(self.point)
        wave.startAnimation()
    }
    
    func bind(reactor: MainViewReactor) {
        // Action
        self.addButton.rx.tap
            .map { Reactor.Action.increse }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.subButton.rx.tap
            .map { Reactor.Action.decrese }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // State
        reactor.state
            .map { $0.count }
            .distinctUntilChanged()
            .map { "\($0)" }
            .bind(to: goal.rx.text)
            .disposed(by: disposeBag)
    }
    
    override func setupConstraints() {
        [self.descript, self.goal, self.addButton, self.subButton, self.wave].forEach { self.view.addSubview($0) }
        
        self.descript.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
        }
        self.goal.snp.makeConstraints {
            $0.top.equalTo(self.descript.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(50)
        }
        self.addButton.snp.makeConstraints {
            $0.top.equalTo(self.goal)
            $0.leading.equalTo(self.goal.snp.trailing).offset(10)
            $0.width.height.equalTo(50)
        }
        self.subButton.snp.makeConstraints {
            $0.top.equalTo(self.goal)
            $0.trailing.equalTo(self.goal.snp.leading).offset(-10)
            $0.width.height.equalTo(50)
        }
    }
    
    @objc func addWarter() {
        self.point += 0.1
    }
}
