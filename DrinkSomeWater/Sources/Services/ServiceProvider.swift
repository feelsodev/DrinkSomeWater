//
//  ServiceProvider.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/19.
//

import Foundation

protocol ServiceProviderProtocol: class {
  var userDefaultsService: UserDefaultsServiceProtocol { get }
  var warterService: WaterServiceProtocol { get }
}

final class ServiceProvider: ServiceProviderProtocol {
  lazy var userDefaultsService: UserDefaultsServiceProtocol = UserDefaultsService(provider: self)
  lazy var warterService: WaterServiceProtocol = WaterService(provider: self)
}
