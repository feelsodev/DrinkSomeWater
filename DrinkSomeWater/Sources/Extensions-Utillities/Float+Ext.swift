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
    guard let result = numberFormatter.string(for: self) else { return "" }
    return result
  }
}
