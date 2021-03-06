//
//  ServiceProvider.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/19.
//

import Foundation

protocol ServiceProviderProtocol: AnyObject {
  var userDefaultsService: UserDefaultsServiceProtocol { get }
  var warterService: WaterServiceProtocol { get }
  var alertService: AlertServiceProtocol { get }
}

final class ServiceProvider: ServiceProviderProtocol {
  lazy var userDefaultsService: UserDefaultsServiceProtocol = UserDefaultsService(provider: self)
  lazy var warterService: WaterServiceProtocol = WaterService(provider: self)
  lazy var alertService: AlertServiceProtocol = AlertService(provider: self)
}
