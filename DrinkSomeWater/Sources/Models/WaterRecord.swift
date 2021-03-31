//
//  WaterRecord.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/31.
//

import Foundation

struct WaterRecord {
  var date: Date
  var value: Int
  
  init(date: Date, value: Int) {
    self.date = date
    self.value = value
  }
  
  init?(dictionary: [String: Any]) {
    self.date = dictionary["date"] as! Date
    self.value = dictionary["value"] as! Int
  }
  
  func asDictionary() -> [String: Any] {
    let dictionary: [String: Any] = [
      "date": self.date,
      "value": self.value,
    ]
    return dictionary
  }
}
