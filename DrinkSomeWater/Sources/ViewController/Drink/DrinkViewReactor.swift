//
//  DrinkViewReactor.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/16.
//

import Foundation
import ReactorKit
import RxSwift

final class DrinkViewReactor: Reactor {
  enum Action {
    case increseWater
    case decreseWater
    case addWater
    case cancel
  }
  
  enum Mutation {
    case increseWaterValue
    case decreseWaterValue
    case dismiss
  }
  
  struct State {
    var total: Float = 500
    var current: Float = 150
    var progress: Float = 0
    var shouldDismissed: Bool = false
  }
  
  var initialState: State
  let provider: ServiceProviderProtocol
  
  init(provider: ServiceProviderProtocol) {
    self.initialState = State()
    self.provider = provider
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .increseWater:
      return .just(.increseWaterValue)
    case .decreseWater:
      return .just(.decreseWaterValue)
    case .addWater:
      let ml = self.initialState.current
      return self.provider.warterService.updateWater(to: ml)
        .map { _ in .dismiss}
    case .cancel:
      if !self.currentState.shouldDismissed {
        return .just(.dismiss) // no need to confirm
      } else {
        return .empty()
      }
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .increseWaterValue:
      let total = newState.total
      let current = newState.current
      let progress = current / total
      
      if total >= current + 50 {
        newState.current += 50
        self.initialState.current += 50
      }
      newState.progress = progress
    case .decreseWaterValue:
      let total = newState.total
      let current = newState.current
      let progress = current / total
      
      if 0 <= current - 50 {
        newState.current -= 50
        self.initialState.current -= 50
      }
      newState.progress = progress
    case .dismiss:
      newState.shouldDismissed = true
    }
    return newState
  }
}
