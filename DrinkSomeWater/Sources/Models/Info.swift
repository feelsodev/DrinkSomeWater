//
//  Info.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/14.
//

import UIKit

enum InfoKey {
  case alarm
  case review
  case version
  case license
  
  func getImage() -> UIImage {
    switch self {
    case .alarm:
      return UIImage(systemName: "bell")!
        .withConfiguration(UIImage.SymbolConfiguration(weight: .regular))
    case .review:
      return UIImage(systemName: "questionmark.circle")!
        .withConfiguration(UIImage.SymbolConfiguration(weight: .regular))
    case .version:
      return UIImage(systemName: "exclamationmark.circle")!
        .withConfiguration(UIImage.SymbolConfiguration(weight: .regular))
    case .license:
      return UIImage(systemName: "pencil")!
        .withConfiguration(UIImage.SymbolConfiguration(weight: .regular))
    }
  }
}

struct Info {
  var title: String
  var key: InfoKey
}
