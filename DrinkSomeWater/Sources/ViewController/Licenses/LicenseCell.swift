//
//  LicenseCell.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/15.
//

import UIKit

final class LicenseCell: BaseTableViewCell {
  static let cellID = "LicenseCellID"
  
  // MARK: - UI
  
  let library = UILabel().then {
    $0.textColor = .black
  }
  
  override func initialize() {
    self.backgroundColor = .white
    self.accessoryType = .disclosureIndicator
  }
  
  override func setupConstraints() {
    self.contentView.addSubview(library)
    self.library.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(20)
      $0.centerY.equalToSuperview()
    }
  }
}
