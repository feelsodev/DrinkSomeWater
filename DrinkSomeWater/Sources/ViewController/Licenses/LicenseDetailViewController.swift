//
//  LicenseDetailViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/16.
//

import UIKit
import RxSwift
import RxCocoa

final class LicenseDetailViewController: UIViewController {
  
  // MARK: - Property
  
  let disposeBag = DisposeBag()
  let library: String
  
  
  // MARK: - UI
  
  let dismissButton = UIButton().then {
    $0.tintColor = .black
    $0.setImage(UIImage(systemName: "xmark")?
                  .withConfiguration(UIImage.SymbolConfiguration(weight: .medium)), for: .normal)
    $0.contentVerticalAlignment = .fill
    $0.contentHorizontalAlignment = .fill
//    $0.imageEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
    $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    $0.layer.shadowOpacity = 1.0
    $0.layer.shadowRadius = 0.0
    $0.layer.masksToBounds = false
    $0.layer.cornerRadius = 4.0
  }
  
  let descript = UITextView().then {
    $0.textColor = .black
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
    self.view.backgroundColor = .white
    self.setupConstraints()
    
    if let descript = licenseDescript(library: self.library) {
      self.descript.text = descript
    }
    
    self.dismissButton.rx.tap
      .subscribe { [weak self] _ in
        guard let `self` = self else { return }
        self.dismiss(animated: true, completion: nil)
      }
      .disposed(by: self.disposeBag)
  }
  
  private func setupConstraints() {
    self.view.addSubview(self.dismissButton)
    self.view.addSubview(self.descript)
    self.dismissButton.snp.makeConstraints {
      $0.top.leading.equalToSuperview().offset(8)
      $0.width.height.equalTo(30)
    }
    self.descript.snp.makeConstraints {
      $0.top.equalTo(self.dismissButton.snp.bottom).offset(5)
      $0.leading.trailing.bottom.equalToSuperview()
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
