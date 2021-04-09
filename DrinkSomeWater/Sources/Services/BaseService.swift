//
//  BaseService.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/19.
//

import Foundation

class BaseService {
  unowned let provider: ServiceProviderProtocol
  
  init(provider: ServiceProviderProtocol) {
    self.provider = provider
  }
}
