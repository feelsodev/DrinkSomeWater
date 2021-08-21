//
//  WaveAnimationView+Reactive.swift
//  WaveAnimationView+Reactive
//
//  Created by sangwon yoon on 2021/08/21.
//

import Foundation
import RxSwift
import WaveAnimationView

extension Reactive where Base: WaveAnimationView {
  var setProgress: Binder<Float> {
    return Binder(self.base) { view, progress in
      view.setProgress(progress)
    }
  }
}
