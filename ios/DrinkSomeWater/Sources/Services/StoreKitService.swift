import Foundation
import StoreKit

// MARK: - Entitlement State

enum EntitlementState: Sendable {
    case free
    case premium(expirationDate: Date?)
}

// MARK: - StoreKit Service Protocol

@MainActor
protocol StoreKitServiceProtocol: AnyObject {
    /// Loads available products from StoreKit
    func loadProducts() async throws -> [Product]
    
    /// Purchases a product and returns the transaction
    func purchase(_ product: Product) async throws -> Transaction
    
    /// Restores previous purchases
    func restorePurchases() async throws
    
    /// Stream of entitlement state changes
    var currentEntitlements: AsyncStream<EntitlementState> { get }
    
    /// Current premium status
    var isPremium: Bool { get }
}
