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
    
    // assert
    XCTAssertEqual(reactor.currentState.progress, 0, "failed progress data check")
    XCTAssertEqual(reactor.currentState.current, 150, "failed current data check")
    XCTAssertEqual(reactor.currentState.total, 500, "failed total data check")
  }
  
  func testDrinkWaterIncerese() {
    let provider = ServiceProvider()
    let reactor = DrinkViewReactor(provider: provider)

    // input
    reactor.action.onNext(.increseWater)
    
    // assert
    XCTAssertEqual(reactor.currentState.current, 200)

    // input
    reactor.action.onNext(.increseWater)
    
    // assert
    XCTAssertEqual(reactor.currentState.current, 250)
  }
  
  func testDrinkWaterDecerese() {
    let provider = ServiceProvider()
    let reactor = DrinkViewReactor(provider: provider)

    // input
    reactor.action.onNext(.decreseWater)
    
    // assert
    XCTAssertEqual(reactor.currentState.current, 100)

    // input
    reactor.action.onNext(.decreseWater)
    
    // assert
    XCTAssertEqual(reactor.currentState.current, 50)
  }
  
  func testDrinkWaterSet500() {
    let provider = ServiceProvider()
    let reactor = DrinkViewReactor(provider: provider)

    reactor.action.onNext(.set500)
    
    // assert
    XCTAssertEqual(reactor.currentState.current, 500)
  }
  
  func testDrinkWaterSet300() {
    let provider = ServiceProvider()
    let reactor = DrinkViewReactor(provider: provider)

    // input
    reactor.action.onNext(.set300)
    
    // assert
    XCTAssertEqual(reactor.currentState.current, 300)
  }
  
  func testDrinkWaterDismiss() {
    // it should dismiss on cancel
    let provider = ServiceProvider()
    let reactor = DrinkViewReactor(provider: provider)
    
    // input
    reactor.action.onNext(.cancel)
    
    // assert
    XCTAssertEqual(reactor.currentState.shouldDismissed, true)
    
    
    let reactorCalendar = CalendarViewReactor(provider: provider)
    
    // input
    reactorCalendar.action.onNext(.cancel)
    
    // assert
    XCTAssertEqual(reactorCalendar.currentState.shouldDismissed, true)
    
    
    let reactorInfomation = InformationViewReactor(provider: provider)
    
    // input
    reactorInfomation.action.onNext(.cancel)
    
    // assert
    XCTAssertEqual(reactorInfomation.currentState.shouldDismissed, true)
    
    
    let reactorSetting = SettingViewReactor(provider: provider)
    
    // input
    reactorSetting.action.onNext(.cancel)
    
    // assert
    XCTAssertEqual(reactorSetting.currentState.shouldDismissed, true)
  }
}
