import Foundation
import Observation

@MainActor
@Observable
final class InformationStore {
  enum Action {
    case viewDidLoad
    case cancel
    case itemSelect(Int)
  }
  
  private let provider: ServiceProviderProtocol
  
  var infoList: [Info] = []
  var shouldDismiss: Bool = false
  
  init(provider: ServiceProviderProtocol) {
    self.provider = provider
  }
  
  func send(_ action: Action) async {
    switch action {
    case .viewDidLoad:
      infoList = [
         Info(title: L.Info.alarm, key: .alarm),
         Info(title: L.Info.review, key: .review),
         Info(title: L.Info.contactUs, key: .question),
         Info(title: L.Info.version, key: .version),
         Info(title: L.Info.license, key: .license)
       ]
      
    case .cancel:
      if !shouldDismiss {
        shouldDismiss = true
      }
      
    case let .itemSelect(row):
      if row == 2 {
         await provider.alertService.show(
           title: L.Contact.title,
           message: L.Contact.message
         )
       }
    }
  }
}
