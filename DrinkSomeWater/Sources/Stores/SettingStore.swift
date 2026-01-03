import Foundation
import Observation

@MainActor
@Observable
final class SettingStore {
    enum Action {
        case loadGoal
        case changeGoalWater(Int)
        case setGoal
        case cancel
    }
    
    private let provider: ServiceProviderProtocol
    
    var value: Int = 0
    var shouldDismiss: Bool = false
    var progress: Float { (Float(value) - 1500) / 3000 }
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func send(_ action: Action) async {
        switch action {
        case .loadGoal:
            let goal = await provider.waterService.fetchGoal()
            let roundedValue = goal - goal % 100
            value = roundedValue
            
        case let .changeGoalWater(ml):
            let roundedValue = ml - ml % 100
            value = roundedValue
            
        case .setGoal:
            _ = await provider.waterService.updateGoal(to: value)
            shouldDismiss = true
            
        case .cancel:
            if !shouldDismiss {
                shouldDismiss = true
            }
        }
    }
    
    func createInformationStore() -> InformationStore {
        InformationStore(provider: provider)
    }
}
