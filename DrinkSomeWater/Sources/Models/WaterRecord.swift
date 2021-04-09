//
//  WaterRecord.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/31.
//

import Foundation

struct WaterRecord: ModelType, Identifiable {
  var date: Date
  var value: Int
  var isSuccess: Bool
  var goal: Int
  
  init(date: Date, value: Int, isSuccess: Bool, goal: Int) {
    self.date = date
    self.value = value
    self.isSuccess = isSuccess
    self.goal = goal
  }
  
  init?(dictionary: [String: Any]) {
    self.date = dictionary["date"] as! Date
    self.value = dictionary["value"] as! Int
    self.isSuccess = dictionary["isSuccess"] as! Bool
    self.goal = dictionary["goal"] as! Int
  }
  
  func asDictionary() -> [String: Any] {
    let dictionary: [String: Any] = [
      "date": self.date,
      "value": self.value,
      "isSuccess": self.isSuccess,
      "goal": self.goal
    ]
    return dictionary
  }
}
