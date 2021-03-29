//
//  SettingViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/30.
//

import UIKit
import ReactorKit
import RxCocoa
import RxSwift

final class SettingViewController: BaseViewController, View {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .red
  }
  
  init(reactor: SettingViewReactor) {
    super.init()
    self.reactor = reactor
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func bind(reactor: SettingViewReactor) {
    
  }
}
