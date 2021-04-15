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
  
  
  // MARK: -UI
  
  let licenseList = UITableView().then {
    $0.register(LicenseCell.self, forCellReuseIdentifier: LicenseCell.cellID)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.bind()
  }
  
  
  // MARK: - TableView bind
  
  private func bind() {
    let libraryOb: Observable<[String]> = Observable.of(Liceses.getData())
    libraryOb
      .bind(to: licenseList.rx.items(cellIdentifier: LicenseCell.cellID)) {
        (index: Int, library: String, cell: LicenseCell) in
        cell.library.text = library
      }
      .disposed(by: self.disposeBag)
  }
  
  override func setupConstraints() {
    self.view.addSubview(licenseList)
    self.licenseList.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}
