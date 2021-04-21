//
//  Date+Ext.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/31.
//

import Foundation

extension Date {
  var checkToday: Bool {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let today = dateFormatter.string(from: Date())
    let getDate = dateFormatter.string(from: self)
    let state = today == getDate ? true : false
    return state
  }
  
  var dateToString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: self)
  }
}
