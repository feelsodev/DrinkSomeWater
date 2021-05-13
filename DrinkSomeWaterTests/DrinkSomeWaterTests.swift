//
//  DrinkSomeWaterTests.swift
//  DrinkSomeWaterTests
//
//  Created by once on 2021/05/12.
//

import XCTest
@testable import DrinkSomeWater

import RxSwift

class DrinkSomeWaterTests: XCTestCase {
  
  func testDrinkWaterFetch() {
    let provider = ServiceProvider()
    let reactor = DrinkViewReactor(provider: provider)
    XCTAssertEqual(reactor.currentState.progress, 0, "failed progress data check")
    XCTAssertEqual(reactor.currentState.current, 150, "failed current data check")
    XCTAssertEqual(reactor.currentState.total, 500, "failed total data check")
  }
  
  func testDrinkWaterIncerese() {
    let provider = ServiceProvider()
    let reactor = DrinkViewReactor(provider: provider)

    reactor.action.onNext(.increseWater)
    XCTAssertEqual(reactor.currentState.current, 200)

    reactor.action.onNext(.increseWater)
    XCTAssertEqual(reactor.currentState.current, 250)
  }
  
  func testDrinkWaterDecerese() {
    let provider = ServiceProvider()
    let reactor = DrinkViewReactor(provider: provider)

    reactor.action.onNext(.decreseWater)
    XCTAssertEqual(reactor.currentState.current, 100)

    reactor.action.onNext(.decreseWater)
    XCTAssertEqual(reactor.currentState.current, 50)
  }
}
