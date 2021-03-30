//
//  WarterService.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/19.
//

import Foundation
import RxSwift

enum WaterEvent {
  case updateWater(Float)
}

protocol WaterServiceProtocol {
  var event: PublishSubject<WaterEvent> { get }
  func fetchWater() -> Observable<Float>
  func fetchGoal() -> Observable<Int>
  
  @discardableResult
  func updateWater(to ml: Float) -> Observable<Float>
  
  @discardableResult
  func updateGoal(to ml: Int) -> Observable<Int>
}

final class WaterService: BaseService, WaterServiceProtocol {
  let event = PublishSubject<WaterEvent>()
  
  func fetchWater() -> Observable<Float> {
    let currentWater: Float = 500
    return .just(currentWater)
  }
  
  func fetchGoal() -> Observable<Int> {
    guard let goalWater = self.provider.userDefaultsService.value(forkey: .goal) else {
      return .empty()
    }
    return .just(goalWater)
  }
  
  @discardableResult
  func updateWater(to ml: Float) -> Observable<Float> {
    return self.fetchWater()
      .map { $0 + ml }
      .do(onNext: { water in
        self.event.onNext(.updateWater(water))
      })
  }
  
  @discardableResult
  func updateGoal(to ml: Int) -> Observable<Int> {
    self.provider.userDefaultsService.set(value: ml, forkey: .goal)
    return .just(ml)
  }
}
