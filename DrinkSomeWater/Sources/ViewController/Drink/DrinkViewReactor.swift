//
//  DrinkViewReactor.swift
//  DrinkSomeWater
//
//  Created by once on 2021/03/16.
//

import Foundation
import ReactorKit
import RxSwift

class DrinkViewReactor: Reactor {
  
  enum Action {
    
  }
  
  enum Muatation {
    
  }
  
  struct State {
    
  }
  
  let initialState: State
  let provider: ServiceProviderProtocol
  
  init(provider: ServiceProviderProtocol) {
    self.initialState = State()
    self.provider = provider
  }
}
