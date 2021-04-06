//
//  Float+Ext.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/05.
//

import Foundation

extension Float {
  func setPercentage() -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .percent
    guard let precentage = numberFormatter.string(for: self) else { return "" }
    let result = "오늘은 " + precentage + " 달성하셨어요!!"
    return result
  }
}