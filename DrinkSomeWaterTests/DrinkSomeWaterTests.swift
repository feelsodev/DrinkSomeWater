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
    XCTAssertEqual(reactor.initialState.progress, 0)
  }

}
