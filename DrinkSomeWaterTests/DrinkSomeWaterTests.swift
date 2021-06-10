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
    
    // when
    let reactor = DrinkViewReactor(provider: provider)
    
    // then
    XCTAssertEqual(reactor.currentState.progress, 0, "failed progress data check")
    XCTAssertEqual(reactor.currentState.currentValue, 150, "failed current data check")
    XCTAssertEqual(reactor.currentState.maxValue, 530, "failed total data check")
  }
  
  func testDrinkWaterIncerese() {
    let provider = ServiceProvider()
    
    // given
    let reactor = DrinkViewReactor(provider: provider)

    // when
    reactor.action.onNext(.increseWater)
    
    // then
    XCTAssertEqual(reactor.currentState.currentValue, 200)

    // when
    reactor.action.onNext(.increseWater)
    
    // then
    XCTAssertEqual(reactor.currentState.currentValue, 250)
  }
  
  func testDrinkWaterDecerese() {
    let provider = ServiceProvider()
    
    // given
    let reactor = DrinkViewReactor(provider: provider)

    // when
    reactor.action.onNext(.decreseWater)
    
    // then
    XCTAssertEqual(reactor.currentState.currentValue, 100)

    // when
    reactor.action.onNext(.decreseWater)
    
    // then
    XCTAssertEqual(reactor.currentState.currentValue, 50)
  }
  
  func testDrinkWaterSet500() {
    let provider = ServiceProvider()
    
    // given
    let reactor = DrinkViewReactor(provider: provider)

    // when
    reactor.action.onNext(.set500)
    
    // then
    XCTAssertEqual(reactor.currentState.currentValue, 500)
  }
  
  func testDrinkWaterSet300() {
    let provider = ServiceProvider()
    
    // given
    let reactor = DrinkViewReactor(provider: provider)

    // when
    reactor.action.onNext(.set300)
    
    // when
    XCTAssertEqual(reactor.currentState.currentValue, 300)
  }
  
  func testDrinkWaterDismiss() {
    // it should dismiss on cancel
    let provider = ServiceProvider()
    
    // given
    let reactorDrink = DrinkViewReactor(provider: provider)
    let reactorCalendar = CalendarViewReactor(provider: provider)
    let reactorInfomation = InformationViewReactor(provider: provider)
    let reactorSetting = SettingViewReactor(provider: provider)
    
    // when
    reactorDrink.action.onNext(.cancel)
    reactorCalendar.action.onNext(.cancel)
    reactorInfomation.action.onNext(.cancel)
    reactorSetting.action.onNext(.cancel)
    
    // then
    XCTAssertEqual(reactorDrink.currentState.shouldDismissed, true)
    XCTAssertEqual(reactorCalendar.currentState.shouldDismissed, true)
    XCTAssertEqual(reactorInfomation.currentState.shouldDismissed, true)
    XCTAssertEqual(reactorSetting.currentState.shouldDismissed, true)
  }
}
