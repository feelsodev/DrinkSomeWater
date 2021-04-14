//
//  BaseTableViewCell.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/14.
//

import Foundation
import RxSwift

class BaseTableViewCell: UITableViewCell {
  
  // MARK: Properties
  
  var disposeBag: DisposeBag = DisposeBag()
  
  
  // MARK: Initializing
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    self.initialize()
    self.setupConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func initialize() {
    // Override point
  }
  
  func setupConstraints() {
    // Override point
  }
}
