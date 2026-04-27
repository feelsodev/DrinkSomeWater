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
        VStack(spacing: DS.Spacing.lg) {
            if premiumStore.isLoading {
                ProgressView(L.Paywall.loading)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: DS.Spacing.xl) {
                        // Header
                        headerSection
                        
                        // Feature Comparison
                        featureComparisonSection
                        
                        // Subscription products (monthly, yearly)
                        subscriptionSection
                        
                        // Restore button
                        restoreButton
                        
                        // Error message
                        errorMessage
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

// MARK: - Subviews

private extension PaywallView {
    
    var headerSection: some View {
        VStack(spacing: DS.Spacing.xs) {
            Image(systemName: "drop.fill")
                .font(.system(size: 44))
                .foregroundStyle(
                    LinearGradient(
                        colors: [DS.SwiftUIColor.primary, DS.SwiftUIColor.primaryDark],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(.bottom, DS.Spacing.xxs)
            
            Text(L.Paywall.title)
                .font(DS.SwiftUIFont.title1)
                .foregroundColor(DS.SwiftUIColor.textPrimary)
            
            Text(L.Paywall.subtitle)
                .font(DS.SwiftUIFont.subhead)
                .foregroundColor(DS.SwiftUIColor.textSecondary)
        }
        .padding(.top, DS.Spacing.md)
    }
    
    var featureComparisonSection: some View {
        VStack(spacing: DS.Spacing.none) {
            HStack {
                Text("")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(L.Paywall.featureFree)
                    .font(DS.SwiftUIFont.captionSemibold)
                    .foregroundColor(DS.SwiftUIColor.textSecondary)
                    .frame(width: 56)
                Text(L.Paywall.featureSubscribed)
                    .font(DS.SwiftUIFont.captionSemibold)
                    .foregroundColor(DS.SwiftUIColor.primary)
                    .frame(width: 56)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.bottom, DS.Spacing.xs)
            
            Divider()
            
            featureRow(title: L.Paywall.featureNoAds, freeAvailable: false, description: L.Paywall.featureAds)
            featureRow(title: L.Paywall.featureWidget, freeAvailable: false, description: L.Paywall.featureNoWidget)
            featureRow(title: L.Paywall.featureWatch, freeAvailable: false, description: L.Paywall.featureNoWatch)
        }
        .padding(DS.Spacing.md)
        .background(DS.SwiftUIColor.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Size.cornerRadiusLarge))
    }
    
    func featureRow(title: String, freeAvailable: Bool, description: String) -> some View {
        VStack(spacing: DS.Spacing.none) {
            HStack {
                Text(title)
                    .font(DS.SwiftUIFont.subheadMedium)
                    .foregroundColor(DS.SwiftUIColor.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: freeAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(freeAvailable ? DS.SwiftUIColor.success : DS.SwiftUIColor.error)
                    .frame(width: 56)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(DS.SwiftUIColor.success)
                    .frame(width: 56)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            
            Divider()
                .padding(.horizontal, DS.Spacing.md)
        }
    }
    
    var subscriptionSection: some View {
        SubscriptionStoreView(groupID: "premium") {
            VStack(spacing: DS.Spacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [DS.SwiftUIColor.primary, DS.SwiftUIColor.primaryDark],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text(L.Paywall.adFree)
                    .font(DS.SwiftUIFont.headline)
                    .foregroundColor(DS.SwiftUIColor.textPrimary)
                
                Text(L.Paywall.subscriptionDescription)
                    .font(DS.SwiftUIFont.caption)
                    .foregroundColor(DS.SwiftUIColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
    
    var restoreButton: some View {
        Button {
            Task {
                await premiumStore.send(.restore)
            }
        } label: {
            Text(L.Paywall.restore)
                .font(DS.SwiftUIFont.subhead)
                .foregroundColor(DS.SwiftUIColor.textSecondary)
        }
        .buttonStyle(.bordered)
        .padding(.top, DS.Spacing.xs)
    }
    
    @ViewBuilder
    var errorMessage: some View {
        if let error = premiumStore.error {
            Text(error.localizedDescription)
                .font(DS.SwiftUIFont.caption)
                .foregroundColor(DS.SwiftUIColor.error)
                .padding()
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
