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
                Info(title: "Alarm".localized, key: .alarm),
                Info(title: "Review".localized, key: .review),
                Info(title: "Contact Us".localized, key: .question),
                Info(title: "Version".localized, key: .version),
                Info(title: "License".localized, key: .license)
            ]
            
        case .cancel:
            if !shouldDismiss {
                shouldDismiss = true
            }
            
        case let .itemSelect(row):
            if row == 2 {
                await provider.alertService.show(
                    title: "문의",
                    message: "feelsodev@gmail.com 으로 문의 바랍니다."
                )
            }
        }
    }
}
