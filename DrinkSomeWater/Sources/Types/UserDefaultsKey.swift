//
//  UserDefaultsKey.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/30.
//

import Foundation

struct UserDefaultsKey<T> {
  typealias Key<T> = UserDefaultsKey<T>
  let key: String
}
