//
//  DrinkType.swift
//  DrinkSomeWater
//
//  Created by once on 2025/01/27.
//

import Foundation

enum DrinkType: String, Codable, CaseIterable, Identifiable {
  case water
  case coffee
  case tea
  case juice
  case soda
  case milk
  case other
  
  var id: String { rawValue }
  
  /// Hydration effectiveness factor (1.0 = 100% effective)
  var hydrationFactor: Double {
    switch self {
    case .water: return 1.0
    case .tea: return 0.95
    case .milk: return 0.9
    case .juice: return 0.85
    case .coffee: return 0.8
    case .soda: return 0.7
    case .other: return 0.8
    }
  }
  
  /// Effective hydration amount
  func effectiveAmount(for ml: Int) -> Int {
    Int(Double(ml) * hydrationFactor)
  }
  
  /// SF Symbol name for the drink type
  var iconName: String {
    switch self {
    case .water: return "drop.fill"
    case .coffee: return "cup.and.saucer.fill"
    case .tea: return "leaf.fill"
    case .juice: return "carrot.fill"
    case .soda: return "bubbles.and.sparkles.fill"
    case .milk: return "mug.fill"
    case .other: return "ellipsis.circle.fill"
    }
  }
  
  /// Localized display name
  var displayName: String {
    String(localized: "drink.type.\(rawValue)")
  }
}
