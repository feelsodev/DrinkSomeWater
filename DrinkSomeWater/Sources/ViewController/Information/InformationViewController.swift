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
    self.backgroundView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(100)
    }
  }
  
}
