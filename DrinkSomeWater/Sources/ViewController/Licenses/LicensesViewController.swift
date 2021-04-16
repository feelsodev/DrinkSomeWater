//
//  LicensesViewController.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/15.
//

import UIKit
import RxSwift
import RxCocoa

final class LicensesViewController: BaseViewController {
  
  // MARK: - Property
  
  let libraryOb: Observable<[String]> = Observable.of(Liceses.getData())
  
  
  // MARK: - UI
  
  let licenseLabel = UILabel().then {
    $0.text = "라이센스"
    $0.textColor = #colorLiteral(red: 0.1739570114, green: 0.1739570114, blue: 0.1739570114, alpha: 1)
    $0.font = .systemFont(ofSize: 20, weight: .semibold)
  }
  let backgroundView = UIView().then {
    $0.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    $0.isUserInteractionEnabled = false
  }
  let containerView = UIView().then {
    $0.backgroundColor = .red
    $0.layer.shadowColor = UIColor.black.cgColor
    $0.layer.shadowOffset = .zero
    $0.layer.shadowRadius = 10
    $0.layer.shadowOpacity = 0.5
  }
  let backButton = UIButton().then {
    $0.tintColor = .black
    $0.setImage(UIImage(systemName: "arrow.left")?
                  .withConfiguration(UIImage.SymbolConfiguration(weight: .regular)), for: .normal)
    $0.contentVerticalAlignment = .fill
    $0.contentHorizontalAlignment = .fill
    $0.imageEdgeInsets = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
    $0.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
    $0.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
    $0.layer.shadowOpacity = 1.0
    $0.layer.shadowRadius = 0.0
    $0.layer.masksToBounds = false
    $0.layer.cornerRadius = 4.0
  }
  let licenseList = IntrinsicTableView().then {
    $0.register(LicenseCell.self, forCellReuseIdentifier: LicenseCell.cellID)
    $0.isScrollEnabled = false
    $0.layer.cornerRadius = 20
    $0.layer.masksToBounds = true
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.borderWidth = 0.5
    $0.separatorColor = .clear
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.bind()
  }
  
  
  // MARK: - TableView bind
  
  private func bind() {
    self.libraryOb
      .bind(to: licenseList.rx.items(cellIdentifier: LicenseCell.cellID,
                                     cellType: LicenseCell.self)) {
        _, library, cell in
        cell.library.text = library
      }
      .disposed(by: self.disposeBag)
    
    self.licenseList.rx.modelSelected(String.self)
      .subscribe(onNext: { library in
        let vc = LicenseDetailViewController(library: library)
        self.present(vc, animated: true, completion: nil)
      })
      .disposed(by: self.disposeBag)
    
    self.backButton.rx.tap
      .subscribe(onNext: { [weak self] _ in
        guard let `self` = self else { return }
        let transition = CATransition()
        transition.duration = 0.4
        transition.timingFunction
          = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        self.view.window?.layer.add(transition, forKey: nil)
        self.dismiss(animated: false, completion: nil)
      })
      .disposed(by: self.disposeBag)
  }
  
  override func setupConstraints() {
    [self.licenseLabel, self.backButton, self.backgroundView, self.containerView, self.licenseList]
      .forEach { self.view.addSubview($0) }
    [self.licenseLabel, self.backButton, self.licenseList]
      .forEach { self.view.bringSubviewToFront($0) }

    self.backgroundView.snp.makeConstraints {
      $0.top.leading.trailing.equalToSuperview()
      $0.height.equalTo(UIScreen.main.bounds.height / 4)
    }
    self.backButton.snp.makeConstraints {
      $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
      $0.leading.equalToSuperview().offset(10)
      $0.width.height.equalTo(50)
    }
    self.licenseLabel.snp.makeConstraints {
      $0.bottom.equalTo(self.licenseList.snp.top).offset(-20)
      $0.centerX.equalToSuperview()
    }
    self.licenseList.snp.makeConstraints {
      $0.top.equalTo(self.view.snp.top).offset(UIScreen.main.bounds.height / 4 - 40)
      $0.leading.equalToSuperview().offset(15)
      $0.trailing.equalToSuperview().offset(-15)
    }
    self.containerView.snp.makeConstraints {
      $0.top.equalTo(self.view.snp.top).offset(UIScreen.main.bounds.height / 4 - 40)
      $0.leading.equalToSuperview().offset(32)
      $0.trailing.equalToSuperview().offset(-32)
      $0.bottom.equalTo(self.licenseList.snp.bottom)
    }
  }
}
