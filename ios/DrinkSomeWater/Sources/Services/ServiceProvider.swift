import Foundation

@MainActor
protocol ServiceProviderProtocol: AnyObject {
  var userDefaultsService: UserDefaultsServiceProtocol { get }
  var cloudSyncService: CloudSyncServiceProtocol { get }
  var waterService: WaterServiceProtocol { get }
  var alertService: AlertServiceProtocol { get }
  var notificationService: NotificationServiceProtocol { get }
  var healthKitService: HealthKitServiceProtocol { get }
  var watchConnectivityService: WatchConnectivityServiceProtocol { get }
}

@MainActor
final class ServiceProvider: ServiceProviderProtocol {
  let userDefaultsService: UserDefaultsServiceProtocol
  let cloudSyncService: CloudSyncServiceProtocol
  let waterService: WaterServiceProtocol
  let alertService: AlertServiceProtocol
  let notificationService: NotificationServiceProtocol
  let healthKitService: HealthKitServiceProtocol
  let watchConnectivityService: WatchConnectivityServiceProtocol
  
  init() {
    let userDefaults = UserDefaultsService()
    let cloudSync = CloudSyncService()
    let alert = AlertService()
    let healthKit = HealthKitService()
    
    cloudSync.migrateFromUserDefaultsIfNeeded(userDefaultsService: userDefaults)
    
    let notification = NotificationService(userDefaultsService: userDefaults)
    
    let watchConnectivity = WatchConnectivityService()
    let water = WaterService(
      userDefaultsService: userDefaults,
      cloudSyncService: cloudSync,
      watchConnectivityService: watchConnectivity
    )
    watchConnectivity.setWaterService(water)
    
    self.userDefaultsService = userDefaults
    self.cloudSyncService = cloudSync
    self.alertService = alert
    self.healthKitService = healthKit
    self.notificationService = notification
    self.watchConnectivityService = watchConnectivity
    self.waterService = water
  }
}
