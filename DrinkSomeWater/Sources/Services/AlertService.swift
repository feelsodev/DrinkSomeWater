//
//  AlertService.swift
//  DrinkSomeWater
//
//  Created by once on 2021/04/15.
//

import UIKit
import RxSwift
import URLNavigator

protocol AlertActionType {
  var title: String? { get }
  var style: UIAlertAction.Style { get }
}

extension AlertActionType {
  var style: UIAlertAction.Style {
    return .default
  }
}

protocol AlertServiceProtocol: AnyObject {
  func show(
    title: String?,
    message: String?
  ) -> Observable<Void>
}

final class AlertService: BaseService, AlertServiceProtocol {
  
  func show(
    title: String?,
    message: String?
  ) -> Observable<Void> {
    return Observable.create { _ in
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let alertAction = UIAlertAction(title: "확인", style: .default, handler: nil)
      alert.addAction(alertAction)
      Navigator().present(alert)
      return Disposables.create {
        alert.dismiss(animated: true, completion: nil)
      }
    }
  }
}
