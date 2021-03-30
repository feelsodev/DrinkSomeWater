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
  case updateGoal(Int)
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
    guard let currentValue = self.provider.userDefaultsService.value(forkey: .current) else { return .just(0)
    }
    return .just(Float(currentValue))
  }
  
  func fetchGoal() -> Observable<Int> {
    guard let goalWater = self.provider.userDefaultsService.value(forkey: .goal) else {
      return .empty()
    }
    return .just(goalWater)
  }
  
  @discardableResult
  func updateWater(to ml: Float) -> Observable<Float> {
    if let currentValue = self.provider.userDefaultsService.value(forkey: .current) {
      self.provider.userDefaultsService.set(value: currentValue + Int(ml), forkey: .current)
      
      // 초기화 위한 슈가 코드
//      self.provider.userDefaultsService.set(value: 0, forkey: .current)
    }
    
    return self.fetchWater()
      .map { $0 }
      .do(onNext: { water in
        self.event.onNext(.updateWater(water))
      })
  }
  
  @discardableResult
  func updateGoal(to ml: Int) -> Observable<Int> {
    self.provider.userDefaultsService.set(value: ml, forkey: .goal)
    self.event.onNext(.updateGoal(ml))
    return .just(ml)
  }
}
