//
//  WarterService.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/19.
//

import Foundation
import RxSwift

enum WaterEvent {
  case updateWater([WaterRecord])
  case updateGoal(Int)
}

protocol WaterServiceProtocol {
  var event: PublishSubject<WaterEvent> { get }
  func fetchWater() -> Observable<[WaterRecord]>
  func fetchGoal() -> Observable<Int>
  
  @discardableResult
  func saveWater(_ waterRecord: [WaterRecord]) -> Observable<Void>
  
  @discardableResult
  func updateWater(to ml: Float) -> Observable<[WaterRecord]>

  @discardableResult
  func updateGoal(to ml: Int) -> Observable<Int>
}

final class WaterService: BaseService, WaterServiceProtocol {
  let event = PublishSubject<WaterEvent>()
    
  func fetchWater() -> Observable<[WaterRecord]> {
    if let currentValue = self.provider.userDefaultsService.value(forkey: .current) {
      var water = currentValue.compactMap(WaterRecord.init)
      if !water.contains(where: { $0.date.checkToday() }) {
        guard let goalWater = self.provider.userDefaultsService.value(forkey: .goal) else {
          return .empty()
        }
        water.append(WaterRecord(date: Date(), value: 0, isSuccess: false, goal: goalWater))
      }
      _ = self.saveWater(water)
      return .just(water)
    }
    
    // 값이 존재하지 않을경우 즉, 제일 초기 앱 실행시
    guard let goalWater = self.provider.userDefaultsService.value(forkey: .goal) else {
      return .empty()
    }
    let waterRecord = WaterRecord(date: Date(), value: 0, isSuccess: false, goal: goalWater)
    let value = waterRecord.asDictionary()
    self.provider.userDefaultsService.set(value: [value], forkey: .current)
    return .just([waterRecord])
  }
  
  func fetchGoal() -> Observable<Int> {
    guard let goalWater = self.provider.userDefaultsService.value(forkey: .goal) else {
      return .empty()
    }
    return .just(goalWater)
  }
  
  func saveWater(_ waterRecord: [WaterRecord]) -> Observable<Void> {
    let dicts = waterRecord.map { $0.asDictionary() }
    self.provider.userDefaultsService.set(value: dicts, forkey: .current)
    return .just(Void())
  }
  
  @discardableResult
  func updateWater(to ml: Float) -> Observable<[WaterRecord]> {
    return self.fetchWater()
      .flatMap { [weak self] waterRecord -> Observable<[WaterRecord]> in
        guard let `self` = self else { return .empty() }
        guard let index = waterRecord.firstIndex(where: { $0.date.checkToday() }) else {
          return .empty()
        }
        var waterRecord = waterRecord
        let newRecord = waterRecord[index].with {
          $0.value += Int(ml)
          $0.date = Date()
          $0.isSuccess =
            $0.value >= $0.goal
            ? true
            : false
        }
        waterRecord[index] = newRecord
        return self.saveWater(waterRecord)
          .map { waterRecord }
          .do { waterRecordList in
            self.event.onNext(.updateWater(waterRecordList))
          }
      }
  }
  
  @discardableResult
  func updateGoal(to ml: Int) -> Observable<Int> {
    if let currentValue = self.provider.userDefaultsService.value(forkey: .current) {
      let waterRecord = currentValue.compactMap(WaterRecord.init)
      guard let index = waterRecord.firstIndex(where: { $0.date.checkToday() }) else {
        return .empty()
      }
      var tempWaterRecord = waterRecord
      let newRecord = tempWaterRecord[index].with {
        $0.goal = ml
        $0.isSuccess =
          $0.value >= $0.goal
          ? true
          : false
      }
      tempWaterRecord[index] = newRecord
      _ = self.saveWater(tempWaterRecord)
    }
    self.provider.userDefaultsService.set(value: ml, forkey: .goal)
    self.event.onNext(.updateGoal(ml))
    return .just(ml)
  }
}
