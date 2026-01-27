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
  
  init(date: Date, value: Int, isSuccess: Bool, goal: Int) {
   self.date = date
   self.value = value
   self.isSuccess = isSuccess
   self.goal = goal
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
  }
 
  func asDictionary() -> [String: Any] {
   var dictionary: [String: Any] = [
    "date": self.date,
    "value": self.value,
    "isSuccess": self.isSuccess,
    "goal": self.goal
   ]
   return dictionary
  }
}
