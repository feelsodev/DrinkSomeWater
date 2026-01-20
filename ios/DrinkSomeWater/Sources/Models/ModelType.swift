import Foundation

protocol ModelIdentifiable {
 associatedtype Identifier: Equatable
 var date: Identifier { get }
}

protocol ModelType {
}

extension Collection where Self.Iterator.Element: ModelIdentifiable {
 func index(of element: Self.Iterator.Element) -> Self.Index? {
  return self.firstIndex { $0.date == element.date }
 }
}
