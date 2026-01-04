import Foundation
import Observation

@MainActor
@Observable
final class DrinkStore {
  enum Action {
    case tapCup(Float)
    case didScroll(Float)
    case increaseWater
    case decreaseWater
    case set500
    case set300
    case addWater
    case cancel
  }
  
  private let provider: ServiceProviderProtocol
  
  let maxValue: Float = 530
  var currentValue: Float = 150
  var progress: Float = 0
  var shouldDismiss: Bool = false
  
  init(provider: ServiceProviderProtocol) {
    self.provider = provider
  }
  
  func send(_ action: Action) async {
    switch action {
    case let .tapCup(tapProgress):
      let tempValue = Int(tapProgress * 530)
      let roundedValue = tempValue - tempValue % 10
      
      if roundedValue >= 500 {
        currentValue = 500
      } else if roundedValue < 30 {
        currentValue = 30
      } else {
        currentValue = Float(roundedValue)
      }
      progress = tapProgress
      
    case let .didScroll(scrollValue):
      let value = maxValue - scrollValue
      let scrollProgress = value / maxValue
      
      if value >= 495 {
        currentValue = 500
      } else if value <= 35 {
        currentValue = 30
      } else {
        let tempValue = Int(value) - Int(value) % 10
        currentValue = Float(tempValue)
      }
      progress = scrollProgress
      
    case .increaseWater:
      currentValue = min(currentValue + 50, 500)
      progress = currentValue / maxValue
      
    case .decreaseWater:
      currentValue = max(currentValue - 50, 30)
      progress = currentValue / maxValue
      
    case .set500:
      currentValue = 500
      progress = currentValue / maxValue
      
    case .set300:
      currentValue = 300
      progress = currentValue / maxValue
      
    case .addWater:
      _ = await provider.waterService.updateWater(by: currentValue)
      shouldDismiss = true
      
    case .cancel:
      if !shouldDismiss {
        shouldDismiss = true
      }
    }
  }
}
