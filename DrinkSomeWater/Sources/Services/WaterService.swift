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
  
  @discardableResult
  func updateWater(to ml: Float) -> Observable<Float>
}

class WaterService: BaseService, WaterServiceProtocol {
  
  let event = PublishSubject<WaterEvent>()
  
  func fetchWater() -> Observable<Float> {
    let currentWater: Float = 500
    return .just(currentWater)
  }
  
  @discardableResult
  func updateWater(to ml: Float) -> Observable<Float> {
    return self.fetchWater()
      .map { $0 + ml }
      .do(onNext: { water in
        self.event.onNext(.updateWater(water))
      })
  }
}
