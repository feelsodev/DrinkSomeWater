import SwiftUI
import StoreKit
import Analytics

struct PaywallView: View {
    @State private var premiumStore: PremiumStore
    let triggerPoint: String
    
    init(premiumStore: PremiumStore, triggerPoint: String) {
        self.premiumStore = premiumStore
        self.triggerPoint = triggerPoint
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if premiumStore.isLoading {
                ProgressView(L.Paywall.loading)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                         VStack(spacing: 8) {
                             Text(L.Paywall.title)
                                 .font(.title)
                                 .bold()
                             
                             Text(L.Paywall.subtitle)
                                 .font(.subheadline)
                                 .foregroundColor(.secondary)
                         }
                        .padding(.top)
                        
                        // Subscription products (monthly, yearly)
                        SubscriptionStoreView(groupID: "premium") {
                            VStack(spacing: 12) {
                                 Image(systemName: "sparkles")
                                     .font(.system(size: 48))
                                     .foregroundColor(.blue)
                                 
                                 Text(L.Paywall.adFree)
                                     .font(.headline)
                                 
                                 Text(L.Paywall.subscriptionDescription)
                                     .font(.caption)
                                     .foregroundColor(.secondary)
                                     .multilineTextAlignment(.center)
                             }
                            .padding()
                        }
                        
                        // Lifetime product
                        if let lifetimeProduct = premiumStore.products.first(where: { $0.id.contains("lifetime") }) {
                             VStack(spacing: 12) {
                                 Divider()
                                 
                                 Text(L.Paywall.or)
                                     .font(.caption)
                                     .foregroundColor(.secondary)
                                 
                                 ProductView(id: lifetimeProduct.id) {
                                     VStack(spacing: 8) {
                                         Image(systemName: "infinity")
                                             .font(.system(size: 32))
                                             .foregroundColor(.purple)
                                         
                                         Text(L.Paywall.lifetime)
                                             .font(.headline)
                                         
                                         Text(L.Paywall.lifetimeDescription)
                                             .font(.caption)
                                             .foregroundColor(.secondary)
                                     }
                                    .padding()
                                }
                            }
                        }
                        
                        // Restore button
                         Button {
                             Task {
                                 await premiumStore.send(.restore)
                             }
                         } label: {
                             Text(L.Paywall.restore)
                                 .font(.subheadline)
                         }
                        .buttonStyle(.bordered)
                        .padding(.top, 8)
                        
                        // Error message
                        if let error = premiumStore.error {
                            Text(error.localizedDescription)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            Analytics.shared.log(.premiumPromptShown(triggerPoint: triggerPoint, variant: nil))
            Task {
                await premiumStore.send(.loadProducts)
            }
        }
    }
}

 #Preview {
     let mockService = StoreKitService()
     PaywallView(
         premiumStore: PremiumStore(storeKitService: mockService),
         triggerPoint: "preview"
     )
 }
