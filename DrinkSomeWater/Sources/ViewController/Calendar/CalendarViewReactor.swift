//
//  CalendarViewReactor.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/30.
//

import Foundation
import ReactorKit
import RxSwift

final class CalendarViewReactor: Reactor {
  enum Action {
    case viewDidload
    case cancel
  }
  
  enum Mutation {
    case returnData([WaterRecord])
    case dismiss
  }
  
  struct State {
    var waterRecordList: [WaterRecord] = []
    var shouldDismissed: Bool = false
  }
  
  var initialState: State
  var provider: ServiceProviderProtocol
  
  init(provider: ServiceProviderProtocol) {
    self.initialState = State()
    self.provider = provider
  }
  
  func mutate(action: Action) -> Observable<Mutation> {
    switch action {
    case .viewDidload:
      return self.provider.warterService.fetchWater()
        .map { waterRecordList in
          .returnData(waterRecordList)
        }
    case .cancel:
      return .just(.dismiss)
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
    case let .updateWater(WaterRecordList):
      return .just(.returnData(WaterRecordList))
    case .updateGoal:
      return .empty()
    }
  }
  
  func reduce(state: State, mutation: Mutation) -> State {
    var newState = state
    switch mutation {
    case let .returnData(waterRecordList):
      newState.waterRecordList = waterRecordList
    case .dismiss:
      newState.shouldDismissed = true
    }
    return newState
  }
}
