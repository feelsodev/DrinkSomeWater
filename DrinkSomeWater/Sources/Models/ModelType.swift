//
//  ModelType.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/31.
//

import Then

protocol Identifiable {
  associatedtype Identifier: Equatable
  var date: Identifier { get }
}

protocol ModelType: Then {
}

extension Collection where Self.Iterator.Element: Identifiable {
  func index(of element: Self.Iterator.Element) -> Self.Index? {
    return self.firstIndex { $0.date == element.date }
  }
}
