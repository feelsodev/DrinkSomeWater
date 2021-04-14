//
//  InfoCellReactor.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/14.
//

import ReactorKit
import RxCocoa
import RxSwift

final class InfoCellReactor: Reactor {
  typealias Action = NoAction

  let initialState: Info

  init(info: Info) {
    self.initialState = info
  }
}
