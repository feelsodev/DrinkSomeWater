import UIKit

protocol AlertActionType {
  var title: String? { get }
  var style: UIAlertAction.Style { get }
}

extension AlertActionType {
  var style: UIAlertAction.Style {
    return .default
  }
}

@MainActor
protocol AlertServiceProtocol: AnyObject {
  func show(title: String?, message: String?) async
}

@MainActor
final class AlertService: AlertServiceProtocol {
  
  init() {}

  func show(title: String?, message: String?) async {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = windowScene.windows.first?.rootViewController else {
      return
    }
    
     await withCheckedContinuation { continuation in
       let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       let alertAction = UIAlertAction(title: L.Common.confirm, style: .default) { _ in
         continuation.resume()
       }
       alert.addAction(alertAction)
      
      var presenter = rootViewController
      while let presented = presenter.presentedViewController {
        presenter = presented
      }
      presenter.present(alert, animated: true)
    }
  }
}
