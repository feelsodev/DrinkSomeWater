//
//  DrinkViewReactor.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/16.
//

import UIKit
import ReactorKit
import RxSwift

final class DrinkViewReactor: Reactor {
  enum Action {
    case tapCup(CGFloat)
    case increseWater
    case decreseWater
    case set500
    case set300
    case addWater
    case cancel
  }
  
  enum Mutation {
    case chageCupState(CGFloat)
    case increseWaterValue
    case decreseWaterValue
    case set500Value
    case set300Value
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
  
  
  // MARK: - Initialize
  
  init(provider: ServiceProviderProtocol) {
    self.initialState = State()
    self.provider = provider
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case let .tapCup(progress):
      return .just(.chageCupState(progress))
    case .increseWater:
      return .just(.increseWaterValue)
    case .decreseWater:
      return .just(.decreseWaterValue)
    case .set500:
      return .just(.set500Value)
    case .set300:
      return .just(.set300Value)
    case .addWater:
      let ml = self.currentState.current
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
    case let .chageCupState(progress):
      let currentValue = Int(progress * 500)
      let current = currentValue - currentValue % 10
      newState.current = Float(current)
      newState.progress = Float(progress)
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
    case .set500Value:
      newState.current = 500
      self.initialState.current = 500
    case .set300Value:
      newState.current = 300
      self.initialState.current = 300
    case .dismiss:
      newState.shouldDismissed = true
    }
    return newState
  }
}
