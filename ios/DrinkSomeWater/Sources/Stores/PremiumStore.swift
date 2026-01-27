import Foundation
import Observation
import StoreKit
import Analytics

@MainActor
@Observable
final class PremiumStore {
    enum Action {
        case loadProducts
        case purchase(Product)
        case restore
        case refreshEntitlements
    }
    
    var products: [Product] = []
    var isPremium: Bool = false
    var isLoading: Bool = false
    var error: Error?
    
    private let storeKitService: StoreKitServiceProtocol
  private nonisolated(unsafe) var transactionObserver: NSObjectProtocol?
    
    init(storeKitService: StoreKitServiceProtocol) {
        self.storeKitService = storeKitService
        Task {
            await send(.refreshEntitlements)
        }
        
        transactionObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("TransactionUpdated"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task {
                await self?.send(.refreshEntitlements)
            }
        }
    }
    
    deinit {
        if let observer = transactionObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func send(_ action: Action) async {
        switch action {
        case .loadProducts:
            isLoading = true
            error = nil
            defer { isLoading = false }
            
            do {
                products = try await storeKitService.loadProducts()
            } catch {
                self.error = error
            }
            
        case .purchase(let product):
            isLoading = true
            error = nil
            defer { isLoading = false }
            
            let price = NSDecimalNumber(decimal: product.price).doubleValue
            Analytics.shared.log(.purchaseStarted(productId: product.id, price: price))
            
            do {
                _ = try await storeKitService.purchase(product)
                isPremium = true
                Analytics.shared.log(.purchaseCompleted(
                    productId: product.id,
                    price: price,
                    currency: product.priceFormatStyle.currencyCode
                ))
                Analytics.shared.setPremiumStatus(.premium)
            } catch {
                self.error = error
                let errorCode = (error as? StoreKitServiceError)?.errorCode ?? "unknown"
                Analytics.shared.log(.purchaseFailed(productId: product.id, errorCode: errorCode))
            }
            
        case .restore:
            isLoading = true
            error = nil
            defer { isLoading = false }
            
            do {
                try await storeKitService.restorePurchases()
                await send(.refreshEntitlements)
            } catch {
                self.error = error
            }
            
        case .refreshEntitlements:
            let wasPremium = isPremium
            isPremium = storeKitService.isPremium
            
            if wasPremium != isPremium {
                Analytics.shared.setPremiumStatus(isPremium ? .premium : .free)
            }
        }
    }
}

// MARK: - StoreKitServiceError Extension

extension StoreKitServiceError {
    var errorCode: String {
        switch self {
        case .productNotFound: return "product_not_found"
        case .purchaseFailed: return "purchase_failed"
        case .userCancelled: return "user_cancelled"
        case .pending: return "pending"
        case .verificationFailed: return "verification_failed"
        case .unknown: return "unknown"
        }
    }
}
