//
//  LicenseDetailViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/16.
//

import UIKit

class LicenseDetailView: UIViewController {
  
  // MARK: - Property
  
  let library: String
  
  
  // MARK: - UI
  
  let descript = UITextView().then {
    $0.textColor = .white
    $0.isEditable = false
    $0.isUserInteractionEnabled = true
    $0.dataDetectorTypes = .link
  }
  
  
  // MARK: - Init
  
  init(library: String) {
    self.library = library
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupConstraints()
    
    if let descript = licenseDescript(library: self.library) {
      self.descript.text = descript
    }
  }
  
  private func setupConstraints() {
    self.view.addSubview(self.descript)
    self.descript.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  
  // MARK: - License Descript
  
  private func licenseDescript(library: String) -> String? {
    let license = LicesesData()
    switch library {
    case "FSCalendar":
      return license.fsCalendar
    case "Then":
      return license.then
    case "SnapKit":
      return license.snapKit
    case "RxSwift":
      return license.rxSwift
    case "RxCocoa":
      return license.rxCocoa
    case "RxDataSources":
      return license.rxDataSources
    case "RxOptional":
      return license.rxOptional
    case "RxViewController":
      return license.rxViewController
    case "ReactorKit":
      return license.reactorKit
    case "WaveAnimationView":
      return license.then
    case "URLNavigator":
      return license.urlNavigator
    default:
      return nil
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

