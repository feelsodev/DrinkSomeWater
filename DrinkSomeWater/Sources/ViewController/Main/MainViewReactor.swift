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
    case refreshGoal
  }
  
  enum Mutation {
    case updateWater([WaterRecord])
    case updateGoal(Float)
  }
  
  struct State {
    var total: Float = 0
    var ml: Float = 0
    var progress: Float = 0
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
    case .refresh:
      return self.provider.warterService.fetchWater()
        .map { water in
          return .updateWater(water)
        }
    case .refreshGoal:
      return self.provider.warterService.fetchGoal()
        .map { ml in
          return .updateGoal(Float(ml))
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
    switch waterEvent {
    case let .updateWater(ml):
      return .just(.updateWater(ml))
    case let .updateGoal(ml):
      return .just(.updateGoal(Float(ml)))
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case let .updateWater(waterRecordList):
      waterRecordList.forEach { waterRecord in
        if waterRecord.date.checkToday() {
          newState.ml =
            waterRecord.value == 0
            ? 0
            : Float(waterRecord.value)
        }
      }
      newState.progress = newState.ml / newState.total
    case let .updateGoal(total):
      newState.total = total
      newState.progress = Float(newState.ml / total)
    }
    return newState
  }
  
  func reactorForCreatingDrink() -> DrinkViewReactor {
    return DrinkViewReactor(provider: self.provider)
  }
  
  func reactorForCreactingSetting() -> SettingViewReactor {
    return SettingViewReactor(provider: self.provider)
  }
  
  func reactorForCreatingCalendar() -> CalendarViewReactor {
    return CalendarViewReactor(provider: self.provider)
  }
}
