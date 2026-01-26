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
                ProgressView("상품 로딩 중...")
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Text("프리미엄 업그레이드")
                                .font(.title)
                                .bold()
                            
                            Text("광고 없이 깨끗한 경험을 즐기세요")
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
                                
                                Text("광고 없이 사용하기")
                                    .font(.headline)
                                
                                Text("월간 또는 연간 구독으로 광고를 제거하세요")
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
                                
                                Text("또는")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                ProductView(id: lifetimeProduct.id) {
                                    VStack(spacing: 8) {
                                        Image(systemName: "infinity")
                                            .font(.system(size: 32))
                                            .foregroundColor(.purple)
                                        
                                        Text("평생 이용권")
                                            .font(.headline)
                                        
                                        Text("한 번 구매로 영원히 사용하세요")
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
                            Text("구매 복원")
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
    PaywallView(
        premiumStore: PremiumStore(storeKitService: MockStoreKitService()),
        triggerPoint: "preview"
    )
}
