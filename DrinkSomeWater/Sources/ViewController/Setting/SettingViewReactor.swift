//
//  SettingViewReactor.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/30.
//

import Foundation
import ReactorKit
import RxSwift

final class SettingViewReactor: Reactor {
  enum Action {
    case loadGoal
    case changeGoalWater(Int)
  }
  
  enum Mutation {
    case changeGoalWaterValue(Int)
  }
  
  struct State {
    var value: Int = 1500
  }
  
  var initialState: State
  var provider: ServiceProviderProtocol
  
  init(provider: ServiceProviderProtocol) {
    self.initialState = State()
    self.provider = provider
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .loadGoal:
      return self.provider.warterService.fetchGoal()
        .map { ml in
          return .changeGoalWaterValue(ml)
        }
    case let .changeGoalWater(ml):
      return .just(.changeGoalWaterValue(ml))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case let .changeGoalWaterValue(ml):
      let value = ml - ml % 100
      newState.value = value
    }
    return newState
  }
}
