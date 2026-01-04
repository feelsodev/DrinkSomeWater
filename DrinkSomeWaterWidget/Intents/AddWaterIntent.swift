import AppIntents
import WidgetKit

struct AddWaterIntent: AppIntent {
    static let title: LocalizedStringResource = "Add Water"
    static let description: IntentDescription = IntentDescription("Add water intake from widget")
    
    @Parameter(title: "Amount (ml)")
    var amount: Int
    
    init() {
        self.amount = 150
    }
    
    init(amount: Int) {
        self.amount = amount
    }
    
    func perform() async throws -> some IntentResult {
        await WidgetDataManager.shared.addWater(amount)
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}
