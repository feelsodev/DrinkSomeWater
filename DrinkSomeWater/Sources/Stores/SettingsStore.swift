import Foundation
import Observation

@MainActor
@Observable
final class SettingsStore {
    enum Action {
        case loadGoal
        case updateGoal(Int)
        case loadCustomButtons
        case updateCustomButtons([Int])
    }
    
    let provider: ServiceProviderProtocol
    
    var goalValue: Int = 2000
    var customQuickButtons: [Int] = [250, 400]
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    init(provider: ServiceProviderProtocol) {
        self.provider = provider
    }
    
    func send(_ action: Action) async {
        switch action {
        case .loadGoal:
            let goal = await provider.waterService.fetchGoal()
            goalValue = goal - goal % 100
            
        case .updateGoal(let value):
            let roundedValue = value - value % 100
            goalValue = roundedValue
            _ = await provider.waterService.updateGoal(to: roundedValue)
            
        case .loadCustomButtons:
            if let buttons = provider.userDefaultsService.value(forkey: .customQuickButtons), !buttons.isEmpty {
                customQuickButtons = buttons
            }
            
        case .updateCustomButtons(let buttons):
            customQuickButtons = buttons
            provider.userDefaultsService.set(value: buttons, forkey: .customQuickButtons)
        }
    }
}
