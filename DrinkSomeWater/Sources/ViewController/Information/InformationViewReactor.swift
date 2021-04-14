//
//  InformationViewReactor.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/14.
//

import ReactorKit
import RxCocoa
import RxDataSources
import RxSwift

typealias InfoSection = SectionModel<Void, InfoCellReactor>

final class InformationViewReactor: Reactor {
  enum Action {
    case viewDidload
    case cancel
  }
  
  enum Mutation {
    case returnInfo([InfoSection])
    case dismiss
  }
  
  struct State {
    var shouldDismissed: Bool = false
    var sections: [InfoSection]
  }
  
  var initialState: State
  
  init() {
    self.initialState = State(sections: [InfoSection(model: Void(), items: [])])
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidload:
      let info: [Info] = [
        Info(title: "알람", key: .alarm),
        Info(title: "리뷰 쓰기", key: .review),
        Info(title: "앱 버전", key: .version),
        Info(title: "라이센스", key: .license)
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
