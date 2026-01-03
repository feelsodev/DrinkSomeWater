import Foundation
import Observation

@MainActor
@Observable
final class CalendarStore {
    enum Action {
        case viewDidLoad
        case cancel
    }
    
    private let provider: ServiceProviderProtocol
    
    var waterRecordList: [WaterRecord] = []
    var shouldDismiss: Bool = false
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func send(_ action: Action) async {
        switch action {
        case .viewDidLoad:
            waterRecordList = await provider.waterService.fetchWater()
            
        case .cancel:
            shouldDismiss = true
        }
    }
}
