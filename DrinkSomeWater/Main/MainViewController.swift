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

class MainViewController: BaseViewController, View {
    
    let descript = UILabel().then {
        $0.text = "하루 목표치"
        $0.textColor = .black
    }
    let goal = UILabel().then {
        $0.text = "여기에 목표치"
        $0.textColor = .black
    }
    let addButton = UIButton().then {
        $0.setTitle("눌러바", for: .normal)
        $0.backgroundColor = .darkGray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
    }
    
    func bind(reactor: MainViewReactor) {
        
    }
    
    override func setupConstraints() {
        [self.descript, self.goal, self.addButton].forEach { self.view.addSubview($0) }
        
        self.descript.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
        }
        self.goal.snp.makeConstraints {
            $0.top.equalTo(self.descript.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
        }
        self.addButton.snp.makeConstraints {
            $0.top.equalTo(self.goal.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(50)
        }
    }
}
