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

protocol AlertServiceProtocol: AnyObject {
  @MainActor
  func show(title: String?, message: String?) async
}

final class AlertService: BaseService, AlertServiceProtocol {
  
  @MainActor
  func show(title: String?, message: String?) async {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
       let rootViewController = windowScene.windows.first?.rootViewController else {
      return
    }
    
    await withCheckedContinuation { continuation in
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let alertAction = UIAlertAction(title: String(localized: "common.confirm"), style: .default) { _ in
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
