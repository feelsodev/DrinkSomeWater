import Foundation
import Observation

@MainActor
@Observable
final class ProfileStore {
  enum Action {
    case load
    case requestHealthKitPermission
    case syncWeightFromHealthKit
    case updateWeight(Double)
    case toggleHealthKitWeight(Bool)
    case applyRecommendedGoal
  }
  
  let provider: ServiceProviderProtocol
  
  var profile: UserProfile = .default
  var isHealthKitAvailable: Bool = false
  var isHealthKitAuthorized: Bool = false
  
  var recommendedIntake: Int {
    profile.recommendedIntake
  }
  
  init(provider: ServiceProviderProtocol) {
    self.provider = provider
    self.isHealthKitAvailable = provider.healthKitService.isAvailable
  }
  
  func send(_ action: Action) async {
    switch action {
    case .load:
      loadProfile()
      if profile.useHealthKitWeight {
        await send(.syncWeightFromHealthKit)
      }
      
    case .requestHealthKitPermission:
      isHealthKitAuthorized = await provider.healthKitService.requestAuthorization()
      if isHealthKitAuthorized {
        await send(.syncWeightFromHealthKit)
      }
      
    case .syncWeightFromHealthKit:
      if let weight = await provider.healthKitService.fetchWeight() {
        profile.weight = weight
        saveProfile()
      }
      
    case .updateWeight(let weight):
      profile.weight = weight
      saveProfile()
      
    case .toggleHealthKitWeight(let useHealthKit):
      profile.useHealthKitWeight = useHealthKit
      saveProfile()
      if useHealthKit {
        await send(.requestHealthKitPermission)
      }
      
    case .applyRecommendedGoal:
      _ = await provider.waterService.updateGoal(to: recommendedIntake)
    }
  }
  
  private func loadProfile() {
    let defaults = provider.userDefaultsService
    let weight = defaults.value(forkey: .userWeight) ?? 65.0
    let useHealthKit = defaults.value(forkey: .useHealthKitWeight) ?? false
    profile = UserProfile(weight: weight, useHealthKitWeight: useHealthKit)
  }
  
  private func saveProfile() {
    let defaults = provider.userDefaultsService
    defaults.set(value: profile.weight, forkey: .userWeight)
    defaults.set(value: profile.useHealthKitWeight, forkey: .useHealthKitWeight)
  }
}
