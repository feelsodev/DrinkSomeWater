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
    case setGoal
  }
  
  enum Mutation {
    case changeGoalWaterValue(Int)
    case dismiss
  }
  
  struct State {
    var value: Int = 0
    var shouldDismissed: Bool = false
    var progress: Float = 0
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
    case .setGoal:
      let currentValue = self.initialState.value
      return self.provider.warterService.updateGoal(to: currentValue)
        .map { _ in .dismiss }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case let .changeGoalWaterValue(ml):
      let value = ml - ml % 100
      let progress = (Float(value) - 1500) / 3000
      self.initialState.value = value
      newState.value = value
      newState.progress = progress
    case .dismiss:
      newState.shouldDismissed = true
    }
    return newState
  }
}
