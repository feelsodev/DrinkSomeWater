import Foundation

@MainActor
protocol ServiceProviderProtocol: AnyObject {
  var userDefaultsService: UserDefaultsServiceProtocol { get }
  var waterService: WaterServiceProtocol { get }
  var alertService: AlertServiceProtocol { get }
  var notificationService: NotificationServiceProtocol { get }
  var healthKitService: HealthKitServiceProtocol { get }
  var watchConnectivityService: WatchConnectivityServiceProtocol { get }
}

@MainActor
final class ServiceProvider: ServiceProviderProtocol {
  let userDefaultsService: UserDefaultsServiceProtocol
  let waterService: WaterServiceProtocol
  let alertService: AlertServiceProtocol
  let notificationService: NotificationServiceProtocol
  let healthKitService: HealthKitServiceProtocol
  let watchConnectivityService: WatchConnectivityServiceProtocol
  
  init() {
    // 1. Services with no dependencies
    let userDefaults = UserDefaultsService()
    let alert = AlertService()
    let healthKit = HealthKitService()
    
    // 2. Services depending on UserDefaults
    let notification = NotificationService(userDefaultsService: userDefaults)
    
    // 3. Circular dependency resolution: WaterService <-> WatchConnectivityService
    let watchConnectivity = WatchConnectivityService()
    let water = WaterService(
      userDefaultsService: userDefaults,
      watchConnectivityService: watchConnectivity
    )
    watchConnectivity.setWaterService(water)
    
    // 4. Assign properties
    self.userDefaultsService = userDefaults
    self.alertService = alert
    self.healthKitService = healthKit
    self.notificationService = notification
    self.watchConnectivityService = watchConnectivity
    self.waterService = water
  }
}
