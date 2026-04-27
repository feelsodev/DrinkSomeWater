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
            if premiumStore.isLoading && premiumStore.products.isEmpty {
                ProgressView(L.Paywall.loading)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: DS.Spacing.xl) {
                        headerSection
                        featureComparisonSection
                        productsSection
                        legalDisclosureSection
                        restoreButton
                        statusMessage
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            Analytics.shared.log(.premiumPromptShown(triggerPoint: triggerPoint, variant: nil))
        }
        .task {
            guard !premiumStore.hasLoadedProducts else { return }
            await premiumStore.send(.loadProducts)
        }
    }
}

// MARK: - Subviews

private extension PaywallView {
    
    var premiumProducts: [(Product, PremiumProductKind)] {
        premiumStore.products.compactMap { product in
            guard let kind = PremiumProductKind(productID: product.id) else { return nil }
            return (product, kind)
        }
    }
    
    var hasCompleteProductCatalog: Bool {
        PremiumStore.hasCompletePremiumProductCatalog(productIDs: premiumStore.products.map(\.id))
    }
    
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
                .multilineTextAlignment(.center)
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
                    .frame(width: 64)
                Text(L.Paywall.featurePremium)
                    .font(DS.SwiftUIFont.captionSemibold)
                    .foregroundColor(DS.SwiftUIColor.primary)
                    .frame(width: 76)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.bottom, DS.Spacing.xs)
            
            Divider()
            
            featureRow(title: L.Paywall.featureNoAds, freeAvailable: false, description: L.Paywall.featureAds)
            featureRow(title: L.Paywall.featureWidget, freeAvailable: false, description: L.Paywall.featureNoWidget)
            featureRow(title: L.Paywall.featureWatch, freeAvailable: false, description: L.Paywall.featureNoWatch, showsDivider: false)
            
            Text(L.Paywall.featureCaption)
                .font(DS.SwiftUIFont.caption)
                .foregroundColor(DS.SwiftUIColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DS.Spacing.md)
                .padding(.top, DS.Spacing.md)
        }
        .padding(DS.Spacing.md)
        .background(DS.SwiftUIColor.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Size.cornerRadiusLarge))
    }
    
    func featureRow(
        title: String,
        freeAvailable: Bool,
        description: String,
        showsDivider: Bool = true
    ) -> some View {
        VStack(spacing: DS.Spacing.none) {
            HStack(alignment: .center, spacing: DS.Spacing.sm) {
                VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                    Text(title)
                        .font(DS.SwiftUIFont.subheadMedium)
                        .foregroundColor(DS.SwiftUIColor.textPrimary)
                    Text(description)
                        .font(DS.SwiftUIFont.caption)
                        .foregroundColor(DS.SwiftUIColor.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: freeAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(freeAvailable ? DS.SwiftUIColor.success : DS.SwiftUIColor.error)
                    .frame(width: 64)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(DS.SwiftUIColor.success)
                    .frame(width: 76)
            }
            .padding(.horizontal, DS.Spacing.md)
            .padding(.vertical, DS.Spacing.sm)
            
            if showsDivider {
                Divider()
                    .padding(.horizontal, DS.Spacing.md)
            }
        }
    }
    
    @ViewBuilder
    var productsSection: some View {
        if !hasCompleteProductCatalog {
            unavailableProductsView
        } else {
            VStack(spacing: DS.Spacing.md) {
                ForEach(premiumStore.products, id: \.id) { product in
                    if let kind = PremiumProductKind(productID: product.id) {
                        PaywallProductCard(product: product, kind: kind) {
                            Task {
                                await premiumStore.send(.purchase(product))
                            }
                        }
                    }
                }
            }
        }
    }
    
    var unavailableProductsView: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 30))
                .foregroundColor(DS.SwiftUIColor.warning)
            
            Text(L.Paywall.productsUnavailable)
                .font(DS.SwiftUIFont.subheadMedium)
                .foregroundColor(DS.SwiftUIColor.textPrimary)
                .multilineTextAlignment(.center)
            
            Button(L.Paywall.productsRetry) {
                Task {
                    await premiumStore.send(.loadProducts)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(DS.SwiftUIColor.primary)
        }
        .padding(DS.Spacing.lg)
        .frame(maxWidth: .infinity)
        .background(DS.SwiftUIColor.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: DS.Size.cornerRadiusLarge))
    }
    
    var legalDisclosureSection: some View {
        VStack(spacing: DS.Spacing.sm) {
            Text(L.Paywall.legalNotice)
                .font(DS.SwiftUIFont.caption)
                .foregroundColor(DS.SwiftUIColor.textSecondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: DS.Spacing.md) {
                if let termsURL = URL(string: PaywallLegalURL.terms) {
                    Link(L.Paywall.legalTerms, destination: termsURL)
                }
                
                Text("•")
                    .foregroundColor(DS.SwiftUIColor.textTertiary)
                
                if let privacyURL = URL(string: PaywallLegalURL.privacy) {
                    Link(L.Paywall.legalPrivacy, destination: privacyURL)
                }
            }
            .font(DS.SwiftUIFont.captionSemibold)
            .foregroundColor(DS.SwiftUIColor.primary)
        }
        .padding(.horizontal, DS.Spacing.md)
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
    var statusMessage: some View {
        if premiumStore.restoreSuccess {
            Label(L.Paywall.restoreSuccess, systemImage: "checkmark.circle.fill")
                .font(DS.SwiftUIFont.subhead)
                .foregroundColor(DS.SwiftUIColor.success)
                .padding()
                .transition(.opacity)
        } else if let error = premiumStore.error {
            Text(error.localizedDescription)
                .font(DS.SwiftUIFont.caption)
                .foregroundColor(DS.SwiftUIColor.error)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

private struct PaywallProductCard: View {
    let product: Product
    let kind: PremiumProductKind
    let purchase: () -> Void
    
    var body: some View {
        Button(action: purchase) {
            VStack(alignment: .leading, spacing: DS.Spacing.md) {
                HStack(alignment: .top, spacing: DS.Spacing.md) {
                    Image(systemName: kind.iconName)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [DS.SwiftUIColor.primary, DS.SwiftUIColor.primaryDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 38, height: 38)
                    
                    VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
                        HStack(spacing: DS.Spacing.xs) {
                            Text(kind.title)
                                .font(DS.SwiftUIFont.headline)
                                .foregroundColor(DS.SwiftUIColor.textPrimary)
                            
                            if let badge = kind.badgeText {
                                Text(badge)
                                    .font(DS.SwiftUIFont.captionSemibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, DS.Spacing.xs)
                                    .padding(.vertical, DS.Spacing.xxs)
                                    .background(DS.SwiftUIColor.primary)
                                    .clipShape(Capsule())
                            }
                        }
                        
                        Text(kind.subtitle)
                            .font(DS.SwiftUIFont.caption)
                            .foregroundColor(DS.SwiftUIColor.textSecondary)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer(minLength: DS.Spacing.sm)
                    
                    VStack(alignment: .trailing, spacing: DS.Spacing.xxs) {
                        Text(product.displayPrice)
                            .font(DS.SwiftUIFont.title3Bold)
                            .foregroundColor(DS.SwiftUIColor.textPrimary)
                        Text(kind.periodText)
                            .font(DS.SwiftUIFont.captionSemibold)
                            .foregroundColor(DS.SwiftUIColor.textSecondary)
                    }
                }
                
                HStack(spacing: DS.Spacing.xs) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(DS.SwiftUIColor.success)
                    Text(L.Paywall.planIncludesPremium)
                        .font(DS.SwiftUIFont.captionSemibold)
                        .foregroundColor(DS.SwiftUIColor.textSecondary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(DS.SwiftUIFont.captionSemibold)
                        .foregroundColor(DS.SwiftUIColor.textTertiary)
                }
                
                if kind.showsTrialBadge {
                    Text(L.Paywall.planTrial)
                        .font(DS.SwiftUIFont.caption)
                        .foregroundColor(DS.SwiftUIColor.primary)
                }
                
                Text(kind.renewalText(for: product.displayPrice))
                    .font(DS.SwiftUIFont.caption)
                    .foregroundColor(DS.SwiftUIColor.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(DS.Spacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DS.SwiftUIColor.backgroundPrimary)
            .overlay(
                RoundedRectangle(cornerRadius: DS.Size.cornerRadiusLarge)
                    .stroke(kind.borderColor, lineWidth: kind == .yearly ? 2 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: DS.Size.cornerRadiusLarge))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(kind.title), \(product.displayPrice), \(kind.periodText)")
    }
}

private enum PaywallLegalURL {
    static let terms = "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/"
    static let privacy = "https://www.notion.so/feelsonce/c7f60cf405bd40cfadbf1d971698fa9d"
}

private extension PremiumProductKind {
    var title: String {
        switch self {
        case .monthly: return L.Paywall.planMonthly
        case .yearly: return L.Paywall.planYearly
        case .lifetime: return L.Paywall.planLifetime
        }
    }
    
    var subtitle: String {
        switch self {
        case .monthly: return L.Paywall.planMonthlyDescription
        case .yearly: return L.Paywall.planYearlyDescription
        case .lifetime: return L.Paywall.planLifetimeDescription
        }
    }
    
    var periodText: String {
        switch self {
        case .monthly: return L.Paywall.planMonthlyPeriod
        case .yearly: return L.Paywall.planYearlyPeriod
        case .lifetime: return L.Paywall.planLifetimePeriod
        }
    }
    
    var badgeText: String? {
        switch self {
        case .monthly, .lifetime: return nil
        case .yearly: return L.Paywall.planYearlyBadge
        }
    }
    
    var iconName: String {
        switch self {
        case .monthly: return "calendar"
        case .yearly: return "sparkles"
        case .lifetime: return "infinity.circle.fill"
        }
    }
    
    var showsTrialBadge: Bool {
        switch self {
        case .monthly, .yearly: return true
        case .lifetime: return false
        }
    }
    
    func renewalText(for displayPrice: String) -> String {
        switch self {
        case .monthly:
            return String(format: L.Paywall.planMonthlyRenewal, displayPrice)
        case .yearly:
            return String(format: L.Paywall.planYearlyRenewal, displayPrice)
        case .lifetime:
            return String(format: L.Paywall.planLifetimePurchase, displayPrice)
        }
    }
    
    var borderColor: Color {
        switch self {
        case .yearly: return DS.SwiftUIColor.primary
        default: return DS.SwiftUIColor.textTertiary.opacity(0.35)
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
