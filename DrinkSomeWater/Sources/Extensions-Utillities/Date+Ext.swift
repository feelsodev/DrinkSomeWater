//
//  Date+Ext.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/31.
//

import Foundation

extension Date {
  func checkToday() -> Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateFormatter.string(from: Date())
    let getDate = dateFormatter.string(from: self)
    let state = today == getDate ? true : false
    return state
  }
}
