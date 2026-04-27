import Foundation

@MainActor
protocol ReviewEligibilityServiceProtocol: AnyObject {
  func recordGoalCompletion()
  func shouldRequestReview() -> Bool
  func markReviewRequested()
  var goalCompletionCount: Int { get }
  var daysSinceInstall: Int { get }
}

@MainActor
final class ReviewEligibilityService: ReviewEligibilityServiceProtocol {
  
  private let userDefaultsService: UserDefaultsServiceProtocol
  private let currentVersion: String
  
  private let minimumCompletionsBeforeReview = 3
  private let minimumDaysSinceInstall = 7
  private let minimumDaysBetweenRequests = 14
  
  init(
    userDefaultsService: UserDefaultsServiceProtocol,
    currentVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
  ) {
    self.userDefaultsService = userDefaultsService
    self.currentVersion = currentVersion
    setInstallDateIfNeeded()
  }
  
  var goalCompletionCount: Int {
    userDefaultsService.value(forkey: .reviewGoalCompletionCount) ?? 0
  }
  
  var daysSinceInstall: Int {
    guard let installTimestamp = userDefaultsService.value(forkey: .reviewInstallDate) else { return 0 }
    let installDate = Date(timeIntervalSince1970: installTimestamp)
    return Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
  }
  
  func recordGoalCompletion() {
    let current = userDefaultsService.value(forkey: .reviewGoalCompletionCount) ?? 0
    userDefaultsService.set(value: current + 1, forkey: .reviewGoalCompletionCount)
  }
  
  func shouldRequestReview() -> Bool {
    let count = userDefaultsService.value(forkey: .reviewGoalCompletionCount) ?? 0
    guard count >= minimumCompletionsBeforeReview else { return false }
    
    guard let installTimestamp = userDefaultsService.value(forkey: .reviewInstallDate) else { return false }
    let installDate = Date(timeIntervalSince1970: installTimestamp)
    let daysSinceInstall = Calendar.current.dateComponents([.day], from: installDate, to: Date()).day ?? 0
    guard daysSinceInstall >= minimumDaysSinceInstall else { return false }
    
    if let lastRequestTimestamp = userDefaultsService.value(forkey: .reviewLastRequestDate) {
      let lastDate = Date(timeIntervalSince1970: lastRequestTimestamp)
      let daysSinceLastRequest = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
      guard daysSinceLastRequest >= minimumDaysBetweenRequests else { return false }
    }
    
    if let lastVersion = userDefaultsService.value(forkey: .reviewLastPromptedVersion),
       lastVersion == currentVersion {
      return false
    }
    
    return true
  }
  
  func markReviewRequested() {
    userDefaultsService.set(value: Date().timeIntervalSince1970, forkey: .reviewLastRequestDate)
    userDefaultsService.set(value: currentVersion, forkey: .reviewLastPromptedVersion)
  }
  
  private func setInstallDateIfNeeded() {
    if userDefaultsService.value(forkey: .reviewInstallDate) == nil {
      userDefaultsService.set(value: Date().timeIntervalSince1970, forkey: .reviewInstallDate)
    }
  }
}
