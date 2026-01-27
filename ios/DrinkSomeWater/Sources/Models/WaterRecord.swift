//
//  WaterRecord.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/31.
//

import Foundation

struct WaterRecord: ModelType, Identifiable {
  var id: String { date.dateToString }
  var date: Date
  var value: Int
  var isSuccess: Bool
  var goal: Int
  var drinkType: DrinkType?
  
  init(date: Date, value: Int, isSuccess: Bool, goal: Int, drinkType: DrinkType? = nil) {
   self.date = date
   self.value = value
   self.isSuccess = isSuccess
   self.goal = goal
   self.drinkType = drinkType
  }
 
  init?(dictionary: [String: Any]) {
   guard let date = dictionary["date"] as? Date,
         let value = dictionary["value"] as? Int,
         let isSuccess = dictionary["isSuccess"] as? Bool,
         let goal = dictionary["goal"] as? Int else {
    return nil
   }
   self.date = date
   self.value = value
   self.isSuccess = isSuccess
   self.goal = goal
   
   if let drinkTypeString = dictionary["drinkType"] as? String {
    self.drinkType = DrinkType(rawValue: drinkTypeString)
   } else {
    self.drinkType = nil
   }
  }
 
  func asDictionary() -> [String: Any] {
   var dictionary: [String: Any] = [
    "date": self.date,
    "value": self.value,
    "isSuccess": self.isSuccess,
    "goal": self.goal
   ]
   if let drinkType = drinkType {
    dictionary["drinkType"] = drinkType.rawValue
   }
   return dictionary
  }
  
  var effectiveValue: Int {
    let type = drinkType ?? .water
    return type.effectiveAmount(for: value)
  }
}
