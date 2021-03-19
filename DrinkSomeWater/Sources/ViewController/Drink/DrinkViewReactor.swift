//
//  DrinkViewReactor.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/16.
//

import Foundation
import ReactorKit
import RxSwift

class DrinkViewReactor: Reactor {
  
  enum Action {
    case increseWater
    case decreseWater
  }
  
  enum Muatation {
    case increseWaterValue
    case decreseWaterValue
  }
  
  struct State {
    var total: Float = 1000
    var current: Float = 500
  }
  
  let initialState: State
  let provider: ServiceProviderProtocol
  
  init(provider: ServiceProviderProtocol) {
    self.initialState = State()
    self.provider = provider
  }
  
  func mutate(action: Action) -> Observable<Action> {
    switch action {
    case .increseWater:
      return .just(.increseWater)
    case .decreseWater:
      return .just(.decreseWater)
    }
  }
  
  func reduce(state: State, mutation: Action) -> State {
    var newState = state
    switch mutation {
    case .increseWater:
      if newState.total >= newState.current + 50 {
          newState.current += 50
      }
    case .decreseWater:
      if 0 <= newState.current - 50 {
        newState.current -= 50
      }
    }
    return newState
  }
}
