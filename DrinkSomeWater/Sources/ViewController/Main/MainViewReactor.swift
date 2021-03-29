//
//  MainViewReactor.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/16.
//

import Foundation
import ReactorKit
import RxSwift

final class MainViewReactor: Reactor {
  enum Action {
    case refresh
  }
  
  enum Mutation {
    case updateWater(Float)
  }
  
  struct State {
    var total: Float = 1000
    var ml: Float = 0
    var progress: Float = 0
  }
  
  let initialState: State
  let provider: ServiceProviderProtocol
  
  init(provider: ServiceProviderProtocol) {
    self.initialState = State()
    self.provider = provider
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .refresh:
      return self.provider.warterService.fetchWater()
        .map { ml in
          return .updateWater(ml)
        }
    }
  }
  
  func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
    let waterEventMutation = self.provider.warterService.event
      .flatMap { [weak self] waterEvent -> Observable<Mutation> in
        self?.mutate(waterEvent: waterEvent) ?? .empty()
      }
    return Observable.merge(mutation, waterEventMutation)
  }
  
  private func mutate(waterEvent: WaterEvent) -> Observable<Mutation> {
    let state = self.currentState
    switch waterEvent {
    case let .updateWater(ml):
      let total = ml + state.ml
      return .just(.updateWater(total))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case let .updateWater(ml):
      let total = newState.total
      let current = newState.ml + ml
      let progress = Float(current / total)
      newState.progress = progress
    }
    return newState
  }
  
  func reactorForCreatingDrink() -> DrinkViewReactor {
    return DrinkViewReactor(provider: self.provider)
  }
  
  func refactorForCreactingSetting() -> SettingViewReactor {
    return SettingViewReactor(provider: self.provider)
  }
}
