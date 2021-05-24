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
    case didScroll(CGFloat)
    case increseWater
    case decreseWater
    case set500
    case set300
    case addWater
    case cancel
  }
  
  enum Mutation {
    case didTapChangeWater(CGFloat)
    case didScrollChangeWater(CGFloat)
    case increseWaterValue
    case decreseWaterValue
    case set500Value
    case set300Value
    case dismiss
  }
  
  struct State {
    var maxValue: Float = 530
    var currentValue: Float = 150
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
      return .just(.didTapChangeWater(progress))
    case .increseWater:
      return .just(.increseWaterValue)
    case .decreseWater:
      return .just(.decreseWaterValue)
    case .set500:
      return .just(.set500Value)
    case .set300:
      return .just(.set300Value)
    case .addWater:
      let ml = self.currentState.currentValue
      return self.provider.warterService.updateWater(to: ml)
        .map { _ in .dismiss}
    case .cancel:
      if !self.currentState.shouldDismissed {
        return .just(.dismiss) // no need to confirm
      } else {
        return .empty()
      }
    case let .didScroll(value):
      return .just(.didScrollChangeWater(value))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case let .didTapChangeWater(progress):
      let tempValue = Int(progress * 530)
      let currentValue = tempValue - tempValue % 10
      if currentValue >= 500 {
        newState.currentValue = 500
      } else if currentValue < 30 {
        newState.currentValue = 30
      } else {
        newState.currentValue = Float(currentValue)
      }
      
      newState.progress = Float(progress)
    case let .didScrollChangeWater(value):
      let currentValue = self.currentState.maxValue - Float(value)
      let progress = currentValue / self.currentState.maxValue
      if currentValue >= 495 {
        newState.currentValue = 500
      } else if currentValue <= 35 {
        newState.currentValue = 30
      } else {
        let tempValue = Int(currentValue) - Int(currentValue) % 10
        newState.currentValue = Float(tempValue)
      }
      newState.progress = progress
    case .increseWaterValue:
      newState.currentValue =
        newState.currentValue + 50 > 500
        ? 500
        : self.currentState.currentValue + 50
      
      let maxValue = self.currentState.maxValue
      let currentValue = newState.currentValue
      let progress = currentValue / maxValue
      newState.progress = progress
    case .decreseWaterValue:
      newState.currentValue =
        newState.currentValue - 50 < 30
        ? 30
        : self.currentState.currentValue - 50
      
      let maxValue = self.currentState.maxValue
      let currentValue = newState.currentValue
      let progress = currentValue / maxValue
      newState.progress = progress
    case .set500Value:
      newState.currentValue = 500
      self.initialState.currentValue = 500
    case .set300Value:
      newState.currentValue = 300
      self.initialState.currentValue = 300
    case .dismiss:
      newState.shouldDismissed = true
    }
    return newState
  }
}
