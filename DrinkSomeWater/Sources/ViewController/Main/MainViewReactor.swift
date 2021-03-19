//
//  MainViewReactor.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/16.
//

import Foundation
import ReactorKit
import RxSwift

class MainViewReactor: Reactor {
  enum Action {
    case increse
    case decrese
  }
  
  enum Mutation {
    case increaseValue
    case decreaseValue
  }
  
  struct State {
    var count = 0
  }
  
  let initialState: State
  let provider: ServiceProviderProtocol
  
  init(provider: ServiceProviderProtocol) {
    self.initialState = State()
    self.provider = provider
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .increse:
      return .just(.increaseValue)
    case .decrese:
      return .just(.decreaseValue)
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case .increaseValue:
      newState.count += 1
    case .decreaseValue:
      newState.count -= 1
    }
    return newState
  }
  
  func reactorForCreatingDrink() -> DrinkViewReactor {
    return DrinkViewReactor(provider: self.provider)
  }
}
