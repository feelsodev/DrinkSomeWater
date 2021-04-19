//
//  String+Ext.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/19.
//

import Foundation

extension String {
  var localized: String {
    return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
  }
}
