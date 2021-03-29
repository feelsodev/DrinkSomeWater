//
//  SettingViewReactor.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/30.
//

import Foundation
import ReactorKit
import RxSwift

final class SettingViewReactor: Reactor {
  enum Action {
    
  }
  
  enum Mutation {
    
  }
  
  struct State {
    
  }
  
  var initialState: State
  var provider: ServiceProviderProtocol
  
  init(provider: ServiceProviderProtocol) {
    self.initialState = State()
    self.provider = provider
  }
}
