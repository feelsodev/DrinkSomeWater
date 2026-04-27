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
  var instagramSharingService: InstagramSharingServiceProtocol { get }
  var socialSharingService: SocialSharingServiceProtocol { get }
  var storeKitService: StoreKitServiceProtocol { get }
  var reviewEligibilityService: ReviewEligibilityServiceProtocol { get }
  var freeDrinkCounterService: FreeDrinkCounterServiceProtocol { get }
  var rewardedAdCoordinator: RewardedAdCoordinatorProtocol { get }
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
  let instagramSharingService: InstagramSharingServiceProtocol
  let socialSharingService: SocialSharingServiceProtocol
  let storeKitService: StoreKitServiceProtocol
  let reviewEligibilityService: ReviewEligibilityServiceProtocol
  let freeDrinkCounterService: FreeDrinkCounterServiceProtocol
  let rewardedAdCoordinator: RewardedAdCoordinatorProtocol
  
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
    
    let instagramSharing = InstagramSharingService()
    let socialSharing = SocialSharingService()
    let storeKit = StoreKitService()
    watchConnectivity.setStoreKitService(storeKit)
    let reviewEligibility = ReviewEligibilityService(userDefaultsService: userDefaults)
    let freeDrinkCounter = FreeDrinkCounterService()
    let rewardedAdCoord = RewardedAdCoordinator()
    
    AdMobService.configure(storeKitService: storeKit)
    
    Task { @MainActor [weak watchConnectivity] in
      for await _ in storeKit.currentEntitlements {
        watchConnectivity?.syncSubscriptionStatus()
      }
    }
    
    self.userDefaultsService = userDefaults
    self.cloudSyncService = cloudSync
    self.alertService = alert
    self.healthKitService = healthKit
    self.notificationService = notification
    self.watchConnectivityService = watchConnectivity
    self.waterService = water
    self.instagramSharingService = instagramSharing
    self.socialSharingService = socialSharing
    self.storeKitService = storeKit
    self.reviewEligibilityService = reviewEligibility
    self.freeDrinkCounterService = freeDrinkCounter
    self.rewardedAdCoordinator = rewardedAdCoord
  }
}
