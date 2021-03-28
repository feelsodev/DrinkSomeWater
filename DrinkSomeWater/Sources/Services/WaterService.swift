//
//  WarterService.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/19.
//

import Foundation
import RxSwift

enum WaterEvent {
  case updateWater(Int)
}

protocol WaterServiceProtocol {
  var event: PublishSubject<WaterEvent> { get }
  func fetchWater() -> Observable<Int>
  
  @discardableResult
  func updateWater(to ml: Int) -> Observable<Int>
}

class WaterService: BaseService, WaterServiceProtocol {
  
  let event = PublishSubject<WaterEvent>()
  
  func fetchWater() -> Observable<Int> {
    let currentWater = 500
    return .just(currentWater)
  }
  
  @discardableResult
  func updateWater(to ml: Int) -> Observable<Int> {
    event.onNext(.updateWater(ml))
    return self.fetchWater()
      .map { $0 + ml }
  }
}
