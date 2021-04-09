//
//  BaseViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/16.
//

import UIKit
import SnapKit
import RxSwift
import Then

class BaseViewController: UIViewController {
  
  // MARK: - Property
  
  var disposeBag = DisposeBag()
  let viewHeight = UIScreen.main.bounds.height
  
  
  // MARK: - Init
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    self.init()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.setupConstraints()
  }
  
  // override point
  func setupConstraints() {
    
  }
}
