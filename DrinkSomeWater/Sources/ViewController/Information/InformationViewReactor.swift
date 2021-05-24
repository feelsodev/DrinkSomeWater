//
//  InformationViewReactor.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/14.
//

import UIKit
import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

typealias InfoSection = SectionModel<Void, InfoCellReactor>

final class InformationViewReactor: Reactor {
  
  enum Action {
    case viewDidload
    case cancel
    case itemSelect(IndexPath)
  }
  
  enum Mutation {
    case returnInfo([InfoSection])
    case dismiss
  }
  
  struct State {
    var shouldDismissed: Bool = false
    var sections: [InfoSection]
  }
  
  let initialState: State
  var provider: ServiceProviderProtocol
  
  init(provider: ServiceProviderProtocol) {
    self.initialState = State(
      sections: [InfoSection(model: Void(), items: [])]
    )
    self.provider = provider
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidload:
      let info: [Info] = [
        Info(title: "Alarm".localized, key: .alarm),
        Info(title: "Review".localized, key: .review),
        Info(title: "Contact Us".localized, key: .question),
        Info(title: "Version".localized, key: .version),
        Info(title: "License".localized, key: .license)
      ]
      let sectionItems = info.map(InfoCellReactor.init)
      let section = InfoSection(model: Void(), items: sectionItems)
      return .just(.returnInfo([section]))
    case .cancel:
      if !self.currentState.shouldDismissed {
        return .just(.dismiss)
      } else {
        return .empty()
      }
    case let .itemSelect(indexPath):
      switch indexPath.row {
      case 2:
        return self.provider.alertService
          .show(title: "문의", message: "feelsodev@gmail.com 으로 문의 바랍니다.")
          .flatMap { _ -> Observable<Mutation> in
            return .empty()
          }
      default:
        return .empty()
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var state = state
    switch mutation {
    case let .returnInfo(sections):
      state.sections = sections
    case .dismiss:
      state.shouldDismissed = true
    }
    return state
  }
}
