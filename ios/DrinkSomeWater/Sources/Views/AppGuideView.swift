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

      Text(NSLocalizedString("appguide.title", comment: ""))
        .font(DS.SwiftUIFont.title1)
        .foregroundStyle(DS.SwiftUIColor.textPrimary)

      Text(NSLocalizedString("appguide.subtitle", comment: ""))
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
      title: NSLocalizedString("appguide.home.title", comment: ""),
      features: [
        FeatureItem(
          icon: "drop.fill",
          title: NSLocalizedString("appguide.home.feature1.title", comment: ""),
          description: NSLocalizedString("appguide.home.feature1.desc", comment: "")
        ),
        FeatureItem(
          icon: "bolt.fill",
          title: NSLocalizedString("appguide.home.feature2.title", comment: ""),
          description: NSLocalizedString("appguide.home.feature2.desc", comment: "")
        ),
        FeatureItem(
          icon: "target",
          title: NSLocalizedString("appguide.home.feature3.title", comment: ""),
          description: NSLocalizedString("appguide.home.feature3.desc", comment: "")
        ),
        FeatureItem(
          icon: "minus.circle.fill",
          title: NSLocalizedString("appguide.home.feature4.title", comment: ""),
          description: NSLocalizedString("appguide.home.feature4.desc", comment: "")
        )
      ]
    )
  }

  // MARK: - History Section

  private var historySectionView: some View {
    FeatureSectionView(
      icon: "calendar",
      iconColor: .orange,
      title: NSLocalizedString("appguide.history.title", comment: ""),
      features: [
        FeatureItem(
          icon: "calendar.badge.checkmark",
          title: NSLocalizedString("appguide.history.feature1.title", comment: ""),
          description: NSLocalizedString("appguide.history.feature1.desc", comment: "")
        ),
        FeatureItem(
          icon: "list.bullet",
          title: NSLocalizedString("appguide.history.feature2.title", comment: ""),
          description: NSLocalizedString("appguide.history.feature2.desc", comment: "")
        ),
        FeatureItem(
          icon: "chart.line.uptrend.xyaxis",
          title: NSLocalizedString("appguide.history.feature3.title", comment: ""),
          description: NSLocalizedString("appguide.history.feature3.desc", comment: "")
        )
      ]
    )
  }

  // MARK: - Watch Section

  private var watchSectionView: some View {
    FeatureSectionView(
      icon: "applewatch",
      iconColor: .red,
      title: NSLocalizedString("appguide.watch.title", comment: ""),
      features: [
        FeatureItem(
          icon: "plus.circle.fill",
          title: NSLocalizedString("appguide.watch.feature1.title", comment: ""),
          description: NSLocalizedString("appguide.watch.feature1.desc", comment: "")
        ),
        FeatureItem(
          icon: "arrow.triangle.2.circlepath",
          title: NSLocalizedString("appguide.watch.feature2.title", comment: ""),
          description: NSLocalizedString("appguide.watch.feature2.desc", comment: "")
        ),
        FeatureItem(
          icon: "dial.low.fill",
          title: NSLocalizedString("appguide.watch.feature3.title", comment: ""),
          description: NSLocalizedString("appguide.watch.feature3.desc", comment: "")
        )
      ]
    )
  }

  // MARK: - Widget Section

  private var widgetSectionView: some View {
    FeatureSectionView(
      icon: "apps.iphone",
      iconColor: .teal,
      title: NSLocalizedString("appguide.widget.title", comment: ""),
      features: [
        FeatureItem(
          icon: "square.grid.2x2",
          title: NSLocalizedString("appguide.widget.feature1.title", comment: ""),
          description: NSLocalizedString("appguide.widget.feature1.desc", comment: "")
        ),
        FeatureItem(
          icon: "lock.fill",
          title: NSLocalizedString("appguide.widget.feature2.title", comment: ""),
          description: NSLocalizedString("appguide.widget.feature2.desc", comment: "")
        ),
        FeatureItem(
          icon: "hand.tap.fill",
          title: NSLocalizedString("appguide.widget.feature3.title", comment: ""),
          description: NSLocalizedString("appguide.widget.feature3.desc", comment: "")
        )
      ]
    )
  }

  // MARK: - Notification Section

  private var notificationSectionView: some View {
    FeatureSectionView(
      icon: "bell.fill",
      iconColor: .purple,
      title: NSLocalizedString("appguide.notification.title", comment: ""),
      features: [
        FeatureItem(
          icon: "clock.fill",
          title: NSLocalizedString("appguide.notification.feature1.title", comment: ""),
          description: NSLocalizedString("appguide.notification.feature1.desc", comment: "")
        ),
        FeatureItem(
          icon: "calendar.badge.clock",
          title: NSLocalizedString("appguide.notification.feature2.title", comment: ""),
          description: NSLocalizedString("appguide.notification.feature2.desc", comment: "")
        ),
        FeatureItem(
          icon: "text.bubble.fill",
          title: NSLocalizedString("appguide.notification.feature3.title", comment: ""),
          description: NSLocalizedString("appguide.notification.feature3.desc", comment: "")
        )
      ]
    )
  }

  // MARK: - Health Section

  private var healthSectionView: some View {
    FeatureSectionView(
      icon: "heart.fill",
      iconColor: .pink,
      title: NSLocalizedString("appguide.health.title", comment: ""),
      features: [
        FeatureItem(
          icon: "scalemass.fill",
          title: NSLocalizedString("appguide.health.feature1.title", comment: ""),
          description: NSLocalizedString("appguide.health.feature1.desc", comment: "")
        ),
        FeatureItem(
          icon: "square.and.arrow.up",
          title: NSLocalizedString("appguide.health.feature2.title", comment: ""),
          description: NSLocalizedString("appguide.health.feature2.desc", comment: "")
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
