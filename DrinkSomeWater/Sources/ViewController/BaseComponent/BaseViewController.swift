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
  let viewWidth = UIScreen.main.bounds.width
  let viewHeight = UIScreen.main.bounds.height
  
  
  // MARK: - Init
  
  init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    self.init()
  }
  
  
  // MARK: - LifeCycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    self.setupConstraints()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.isNavigationBarHidden = false
  }

  // override point
  func setupConstraints() {
    
  }
}
