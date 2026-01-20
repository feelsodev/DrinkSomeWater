//
//  WaterRecordResultView.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/09.
//

import UIKit
import SnapKit

class WaterRecordResultView: UIView {
 let goal = UILabel()
 let capacity = UILabel()
 let percentage = UILabel()
 lazy var stackView: UIStackView = {
  let stackView = UIStackView()
  stackView.axis = .vertical
  stackView.distribution = .fillEqually
  stackView.spacing = 5
  stackView.addArrangedSubview(self.goal)
  stackView.addArrangedSubview(self.capacity)
  stackView.addArrangedSubview(self.percentage)
  return stackView
 }()
 
 init() {
  super.init(frame: CGRect.zero)
  self.setupConstraints()
 }
 
 private func setupAttribute() {
  [self.goal, self.capacity, self.percentage].forEach {
   $0.font = .systemFont(ofSize: 20, weight: .medium)
   $0.textColor = .white
   $0.layer.shadowOffset = CGSize(width: 2, height: 2)
   $0.layer.shadowOpacity = 0.2
   $0.layer.shadowRadius = 1
   $0.layer.shadowColor = UIColor.black.cgColor
  }
 }
 
 private func setupConstraints() {
  self.setupAttribute()
  self.addSubview(self.stackView)
  self.stackView.snp.makeConstraints {
   $0.edges.equalToSuperview()
  }
 }
 
 required init?(coder: NSCoder) {
  fatalError("init(coder:) has not been implemented")
 }
}
