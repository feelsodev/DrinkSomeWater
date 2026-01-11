import SwiftUI

struct AppGuideView: View {
  @SwiftUI.Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
      VStack(spacing: 40) {
        // Header
        headerSection

        // Feature Sections
        VStack(spacing: 24) {
          homeSectionView
          historySectionView
          watchSectionView
          widgetSectionView
          notificationSectionView
          healthSectionView
        }
        .padding(.horizontal, 20)
      }
      .padding(.bottom, 40)
    }
    .background(DS.SwiftUIColor.backgroundPrimary)
  }

  // MARK: - Header

  private var headerSection: some View {
    VStack(spacing: 12) {
      Image(systemName: "drop.fill")
        .font(.system(size: 60))
        .foregroundStyle(DS.SwiftUIColor.primary)
        .padding(.top, 20)

      Text(NSLocalizedString("appguide.title", comment: ""))
        .font(.system(size: 28, weight: .bold))
        .foregroundStyle(DS.SwiftUIColor.textPrimary)

      Text(NSLocalizedString("appguide.subtitle", comment: ""))
        .font(.system(size: 16, weight: .medium))
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
    VStack(alignment: .leading, spacing: 20) {
      // Section Header
      HStack(spacing: 12) {
        ZStack {
          RoundedRectangle(cornerRadius: 12)
            .fill(iconColor.opacity(0.15))
            .frame(width: 44, height: 44)

          Image(systemName: icon)
            .font(.system(size: 22))
            .foregroundStyle(iconColor)
        }

        Text(title)
          .font(.system(size: 20, weight: .semibold))
          .foregroundStyle(DS.SwiftUIColor.textPrimary)

        Spacer()
      }

      // Features
      VStack(alignment: .leading, spacing: 16) {
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
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 16)
        .fill(DS.SwiftUIColor.backgroundSecondary)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
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
    HStack(alignment: .top, spacing: 12) {
      Image(systemName: icon)
        .font(.system(size: 18))
        .foregroundStyle(iconColor.opacity(0.8))
        .frame(width: 20)

      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .font(.system(size: 16, weight: .semibold))
          .foregroundStyle(DS.SwiftUIColor.textPrimary)

        Text(description)
          .font(.system(size: 14, weight: .medium))
          .foregroundStyle(DS.SwiftUIColor.textSecondary)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}

#Preview {
  AppGuideView()
}
