//
//  Beaker.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/05.
//

import UIKit

class Beaker: UIView {
  let label = UILabel()
  let line = UIView().then {
    $0.backgroundColor = .black
  }
  
  init(ml: String) {
    super.init(frame: CGRect.zero)
    self.label.text = ml
    self.setupConstraints()
  }
  
  private func setupConstraints() {
    [self.label, self.line].forEach { self.addSubview($0) }
    self.line.snp.makeConstraints {
      $0.trailing.equalToSuperview()
      $0.centerY.equalToSuperview()
      $0.width.equalTo(50)
      $0.height.equalTo(5)
    }
    self.label.snp.makeConstraints {
      $0.trailing.equalTo(self.line.snp.leading).offset(-10)
      $0.centerY.equalToSuperview()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
