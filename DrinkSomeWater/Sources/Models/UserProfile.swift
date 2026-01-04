import Foundation

struct UserProfile: Codable, Equatable {
  var weight: Double
  var useHealthKitWeight: Bool
  
  var recommendedIntake: Int {
    Int(weight * 33)
  }
  
  static var `default`: UserProfile {
    UserProfile(weight: 65, useHealthKitWeight: false)
  }
}
