import Foundation

protocol ServiceProviderProtocol: AnyObject, Sendable {
    var userDefaultsService: UserDefaultsServiceProtocol { get }
    var waterService: WaterServiceProtocol { get }
    var alertService: AlertServiceProtocol { get }
}

final class ServiceProvider: ServiceProviderProtocol, @unchecked Sendable {
    lazy var userDefaultsService: UserDefaultsServiceProtocol = UserDefaultsService(provider: self)
    lazy var waterService: WaterServiceProtocol = WaterService(provider: self)
    lazy var alertService: AlertServiceProtocol = AlertService(provider: self)
}
