//
//  Float+Ext.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/05.
//

import UIKit

extension Float {
  var setPercentage: String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .percent
    guard let precentage = numberFormatter.string(for: self) else { return "" }
    return precentage
  }
  
  var waterImage: UIImage {
    var image: UIImage?
    switch self {
    case 0..<0.3:
      image = UIImage(named: "bang3")
    case 0.3..<0.7:
      image = UIImage(named: "bang2")
    case 0.7...1.0:
      image = UIImage(named: "bang")
    default:
      image = UIImage(named: "bang")
    }
    return image ?? UIImage()
  }  
}
