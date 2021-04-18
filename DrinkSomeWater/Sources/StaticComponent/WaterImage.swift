//
//  WaterImage.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/18.
//

import UIKit

struct WaterImage {
  static func waterImage(progress: Float) -> UIImage {
    var image: UIImage?
    switch progress {
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
