//
//  ServiceProvider.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/19.
//

import Foundation

protocol ServiceProviderProtocol: class {
    var warterService: WaterServiceProtocol { get }
}

final class ServiceProvider: ServiceProviderProtocol {
    lazy var warterService: WaterServiceProtocol = WaterService(provider: self)
}
