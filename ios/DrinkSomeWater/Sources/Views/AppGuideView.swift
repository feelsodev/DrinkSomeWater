import SwiftUI

struct AppGuideView: View {
  @SwiftUI.Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
      VStack(spacing: DS.Spacing.xxxl) {
        // Header
        headerSection

        // Feature Sections
        VStack(spacing: DS.Spacing.xl) {
          homeSectionView
          historySectionView
          watchSectionView
          widgetSectionView
          notificationSectionView
          healthSectionView
        }
        .padding(.horizontal, DS.Spacing.lg)
      }
      .padding(.bottom, DS.Spacing.xxxl)
    }
    .background(DS.SwiftUIColor.backgroundPrimary)
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(spacing: DS.Spacing.sm) {
      Image(systemName: "drop.fill")
        .font(DS.SwiftUIFont.display)
        .foregroundStyle(DS.SwiftUIColor.primary)
        .padding(.top, DS.Spacing.lg)

      Text(L.AppGuide.title)
        .font(DS.SwiftUIFont.title1)
        .foregroundStyle(DS.SwiftUIColor.textPrimary)

      Text(L.AppGuide.subtitle)
        .font(DS.SwiftUIFont.bodyMedium)
        .foregroundStyle(DS.SwiftUIColor.textSecondary)
        .multilineTextAlignment(.center)
    }
  }

  // MARK: - Home Section

  private var homeSectionView: some View {
    FeatureSectionView(
      icon: "house.fill",
      iconColor: DS.SwiftUIColor.primary,
      title: L.AppGuide.homeTitle,
      features: [
        FeatureItem(
          icon: "drop.fill",
          title: L.AppGuide.homeFeature1Title,
          description: L.AppGuide.homeFeature1Desc
        ),
        FeatureItem(
          icon: "bolt.fill",
          title: L.AppGuide.homeFeature2Title,
          description: L.AppGuide.homeFeature2Desc
        ),
        FeatureItem(
          icon: "target",
          title: L.AppGuide.homeFeature3Title,
          description: L.AppGuide.homeFeature3Desc
        ),
        FeatureItem(
          icon: "minus.circle.fill",
          title: L.AppGuide.homeFeature4Title,
          description: L.AppGuide.homeFeature4Desc
        )
      ]
    )
  }

  // MARK: - History Section

  private var historySectionView: some View {
    FeatureSectionView(
      icon: "calendar",
      iconColor: .orange,
      title: L.AppGuide.historyTitle,
      features: [
        FeatureItem(
          icon: "calendar.badge.checkmark",
          title: L.AppGuide.historyFeature1Title,
          description: L.AppGuide.historyFeature1Desc
        ),
        FeatureItem(
          icon: "list.bullet",
          title: L.AppGuide.historyFeature2Title,
          description: L.AppGuide.historyFeature2Desc
        ),
        FeatureItem(
          icon: "chart.line.uptrend.xyaxis",
          title: L.AppGuide.historyFeature3Title,
          description: L.AppGuide.historyFeature3Desc
        )
      ]
    )
  }

  // MARK: - Watch Section

  private var watchSectionView: some View {
    FeatureSectionView(
      icon: "applewatch",
      iconColor: .red,
      title: L.AppGuide.watchTitle,
      features: [
        FeatureItem(
          icon: "plus.circle.fill",
          title: L.AppGuide.watchFeature1Title,
          description: L.AppGuide.watchFeature1Desc
        ),
        FeatureItem(
          icon: "arrow.triangle.2.circlepath",
          title: L.AppGuide.watchFeature2Title,
          description: L.AppGuide.watchFeature2Desc
        ),
        FeatureItem(
          icon: "dial.low.fill",
          title: L.AppGuide.watchFeature3Title,
          description: L.AppGuide.watchFeature3Desc
        )
      ]
    )
  }

  // MARK: - Widget Section

  private var widgetSectionView: some View {
    FeatureSectionView(
      icon: "apps.iphone",
      iconColor: .teal,
      title: L.AppGuide.widgetTitle,
      features: [
        FeatureItem(
          icon: "square.grid.2x2",
          title: L.AppGuide.widgetFeature1Title,
          description: L.AppGuide.widgetFeature1Desc
        ),
        FeatureItem(
          icon: "lock.fill",
          title: L.AppGuide.widgetFeature2Title,
          description: L.AppGuide.widgetFeature2Desc
        ),
        FeatureItem(
          icon: "hand.tap.fill",
          title: L.AppGuide.widgetFeature3Title,
          description: L.AppGuide.widgetFeature3Desc
        )
      ]
    )
  }

  // MARK: - Notification Section

  private var notificationSectionView: some View {
    FeatureSectionView(
      icon: "bell.fill",
      iconColor: .purple,
      title: L.AppGuide.notificationTitle,
      features: [
        FeatureItem(
          icon: "clock.fill",
          title: L.AppGuide.notificationFeature1Title,
          description: L.AppGuide.notificationFeature1Desc
        ),
        FeatureItem(
          icon: "calendar.badge.clock",
          title: L.AppGuide.notificationFeature2Title,
          description: L.AppGuide.notificationFeature2Desc
        ),
        FeatureItem(
          icon: "text.bubble.fill",
          title: L.AppGuide.notificationFeature3Title,
          description: L.AppGuide.notificationFeature3Desc
        )
      ]
    )
  }

  // MARK: - Health Section

  private var healthSectionView: some View {
    FeatureSectionView(
      icon: "heart.fill",
      iconColor: .pink,
      title: L.AppGuide.healthTitle,
      features: [
        FeatureItem(
          icon: "scalemass.fill",
          title: L.AppGuide.healthFeature1Title,
          description: L.AppGuide.healthFeature1Desc
        ),
        FeatureItem(
          icon: "square.and.arrow.up",
          title: L.AppGuide.healthFeature2Title,
          description: L.AppGuide.healthFeature2Desc
        )
      ]
    )
  }
}

// MARK: - Feature Item Model

private struct FeatureItem {
  let icon: String
  let title: String
  let description: String
}

// MARK: - Feature Section View

private struct FeatureSectionView: View {
  let icon: String
  let iconColor: Color
  let title: String
  let features: [FeatureItem]

  var body: some View {
    VStack(alignment: .leading, spacing: DS.Spacing.lg) {
      // Section Header
      HStack(spacing: DS.Spacing.sm) {
        ZStack {
          RoundedRectangle(cornerRadius: DS.Size.cornerRadiusMedium)
            .fill(iconColor.opacity(0.15))
            .frame(width: DS.Size.iconContainerLarge, height: DS.Size.iconContainerLarge)

          Image(systemName: icon)
            .font(DS.SwiftUIFont.title2)
            .foregroundStyle(iconColor)
        }

        Text(title)
          .font(DS.SwiftUIFont.title3)
          .foregroundStyle(DS.SwiftUIColor.textPrimary)

        Spacer()
      }

      // Features
      VStack(alignment: .leading, spacing: DS.Spacing.md) {
        ForEach(features.indices, id: \.self) { index in
          FeatureRowView(
            icon: features[index].icon,
            iconColor: iconColor,
            title: features[index].title,
            description: features[index].description
          )
        }
      }
    }
    .padding(DS.Spacing.lg)
    .background(
      RoundedRectangle(cornerRadius: DS.Size.cornerRadiusLarge)
        .fill(DS.SwiftUIColor.backgroundSecondary)
        .shadow(color: .black.opacity(0.05), radius: DS.Spacing.xs, x: 0, y: 2)
    )
  }
}

// MARK: - Feature Row View

private struct FeatureRowView: View {
  let icon: String
  let iconColor: Color
  let title: String
  let description: String

  var body: some View {
    HStack(alignment: .top, spacing: DS.Spacing.sm) {
      Image(systemName: icon)
        .font(DS.SwiftUIFont.headline)
        .foregroundStyle(iconColor.opacity(0.8))
        .frame(width: DS.Spacing.lg)

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(DS.SwiftUIFont.bodySemibold)
          .foregroundStyle(DS.SwiftUIColor.textPrimary)

        Text(description)
          .font(DS.SwiftUIFont.subheadMedium)
          .foregroundStyle(DS.SwiftUIColor.textSecondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}

#Preview {
  AppGuideView()
}
