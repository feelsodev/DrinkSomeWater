//
//  CalendarDescriptView.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/09.
//

import UIKit
import SnapKit

class CalendarDescriptView: UIView {
 
 let color: UIColor
 let descript: String
 let circle = UIView()
 let descriptLabel = UILabel()
 
 init(color: UIColor, descript: String) {
  self.color = color
  self.descript = descript
  super.init(frame: CGRect.zero)
  self.setupConstraints()
 }
 
 private func setupAttribute() {
  circle.backgroundColor = self.color
  circle.layer.cornerRadius = 12.5
  circle.layer.masksToBounds = true
  
  descriptLabel.text = self.descript
  descriptLabel.font = .systemFont(ofSize: 15, weight: .semibold)
  descriptLabel.textColor = .black
 }
 
 private func setupConstraints() {
  self.setupAttribute()
  [self.circle, self.descriptLabel].forEach { self.addSubview($0) }
  self.circle.snp.makeConstraints {
   $0.centerY.equalToSuperview()
   $0.leading.equalToSuperview().offset(10)
   $0.width.height.equalTo(25)
  }
  self.descriptLabel.snp.makeConstraints {
   $0.leading.equalTo(self.circle.snp.trailing).offset(10)
   $0.centerY.equalToSuperview()
  }
 }
 
 required init?(coder: NSCoder) {
  fatalError("init(coder:) has not been implemented")
 }
}
