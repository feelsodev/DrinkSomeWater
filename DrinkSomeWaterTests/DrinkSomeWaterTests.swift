//
//  DrinkSomeWaterTests.swift
//  DrinkSomeWaterTests
//
//  Created by once on 2021/05/12.
//

import XCTest
@testable import DrinkSomeWater

@MainActor
final class DrinkSomeWaterTests: XCTestCase {
  
  func testDrinkWaterFetch() async {
    let provider = ServiceProvider()
    
    // when
    let store = DrinkStore(provider: provider)
    
    // then
    XCTAssertEqual(store.progress, 0, "failed progress data check")
    XCTAssertEqual(store.currentValue, 150, "failed current data check")
    XCTAssertEqual(store.maxValue, 530, "failed total data check")
  }
  
  func testDrinkWaterTap() async {
    let provider = ServiceProvider()
    
    // given
    let store = DrinkStore(provider: provider)

    // when
    await store.send(.tapCup(0.5))
    let firstTestValue = Int(0.5 * 530) - Int(0.5 * 530) % 10
    
    // then
    XCTAssertEqual(store.currentValue, Float(firstTestValue))
    
    // when
    await store.send(.tapCup(0.9))
    let secondTestValue = Int(0.9 * 530) - Int(0.9 * 530) % 10
    
    // then
    XCTAssertEqual(store.currentValue, Float(secondTestValue))
    
    // when
    await store.send(.tapCup(1))
    
    // then
    XCTAssertEqual(store.currentValue, 500)
    
    // when
    await store.send(.tapCup(0))
    
    // then
    XCTAssertEqual(store.currentValue, 30)
  }
  
  func testDrinkWaterIncrease() async {
    let provider = ServiceProvider()
    
    // given
    let store = DrinkStore(provider: provider)

    // when
    await store.send(.increaseWater)
    
    // then
    XCTAssertEqual(store.currentValue, 200)

    // when
    await store.send(.increaseWater)
    
    // then
    XCTAssertEqual(store.currentValue, 250)
  }
  
  func testDrinkWaterDecrease() async {
    let provider = ServiceProvider()
    
    // given
    let store = DrinkStore(provider: provider)

    // when
    await store.send(.decreaseWater)
    
    // then
    XCTAssertEqual(store.currentValue, 100)

    // when
    await store.send(.decreaseWater)
    
    // then
    XCTAssertEqual(store.currentValue, 50)
  }
  
  func testDrinkWaterSet500() async {
    let provider = ServiceProvider()
    
    // given
    let store = DrinkStore(provider: provider)

    // when
    await store.send(.set500)
    
    // then
    XCTAssertEqual(store.currentValue, 500)
  }
  
  func testDrinkWaterSet300() async {
    let provider = ServiceProvider()
    
    // given
    let store = DrinkStore(provider: provider)

    // when
    await store.send(.set300)
    
    // then
    XCTAssertEqual(store.currentValue, 300)
  }
  
  func testDrinkWaterDismiss() async {
    // it should dismiss on cancel
    let provider = ServiceProvider()
    
    // given
    let storeDrink = DrinkStore(provider: provider)
    let storeCalendar = CalendarStore(provider: provider)
    let storeInformation = InformationStore(provider: provider)
    let storeSetting = SettingStore(provider: provider)
    
    // when
    await storeDrink.send(.cancel)
    await storeCalendar.send(.cancel)
    await storeInformation.send(.cancel)
    await storeSetting.send(.cancel)
    
    // then
    XCTAssertEqual(storeDrink.shouldDismiss, true)
    XCTAssertEqual(storeCalendar.shouldDismiss, true)
    XCTAssertEqual(storeInformation.shouldDismiss, true)
    XCTAssertEqual(storeSetting.shouldDismiss, true)
  }
}
