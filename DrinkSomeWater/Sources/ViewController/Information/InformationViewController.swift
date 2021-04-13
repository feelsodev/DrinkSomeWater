//
//  InformationViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/13.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift
import WaveAnimationView

final class InformationViewController: BaseViewController, View {
  let backgroundView = UIView().then {
    $0.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
  }
  
  let tableView = UITableView().then {
    $0.backgroundColor = .lightGray
    $0.register(InfoCell.self, forCellReuseIdentifier: "cell")
    $0.layer.cornerRadius = 20
    $0.layer.masksToBounds = true
    $0.separatorColor = .clear
  }
  
  // MARK: - Initialize
  
  init(reactor: InformationViewReactor) {
    super.init()
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bind(reactor: InformationViewReactor) {
    
  }
  
  override func setupConstraints() {
    self.view.backgroundColor = .white
    self.view.addSubview(self.backgroundView)
    self.view.addSubview(self.tableView)
    self.view.bringSubviewToFront(self.tableView)
    self.backgroundView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(UIScreen.main.bounds.height / 4)
    }
    self.tableView.snp.makeConstraints {
      $0.top.equalTo(self.view.snp.top).offset(UIScreen.main.bounds.height / 4 - 40)
      $0.leading.equalToSuperview().offset(15)
      $0.trailing.equalToSuperview().offset(-15)
      $0.height.equalTo(UIScreen.main.bounds.height / 3 * 2)
    }
  } 
}
