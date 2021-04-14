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
  case question
  case license
  
  func getImage() -> UIImage {
    switch self {
    case .alarm:
      return UIImage(systemName: "bell")!
        .withConfiguration(UIImage.SymbolConfiguration(weight: .light))
    case .review:
      return UIImage(systemName: "pencil")!
        .withConfiguration(UIImage.SymbolConfiguration(weight: .light))
    case .version:
      return UIImage(systemName: "exclamationmark.circle")!
        .withConfiguration(UIImage.SymbolConfiguration(weight: .light))
    case .license:
      return UIImage(systemName: "doc.plaintext")!
        .withConfiguration(UIImage.SymbolConfiguration(weight: .light))
    case .question:
      return UIImage(systemName: "questionmark.circle")!
        .withConfiguration(UIImage.SymbolConfiguration(weight: .light))
    }
  }
}

struct Info {
  var title: String
  var key: InfoKey
}
