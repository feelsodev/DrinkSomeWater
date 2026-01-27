import SwiftUI
import UIKit
import GoogleMobileAds
import Analytics

enum HistoryViewMode: CaseIterable {
  case calendar
  case list
  case timeline

  var localizedName: String {
    switch self {
    case .calendar: return String(localized: "history.mode.calendar")
    case .list: return String(localized: "history.mode.list")
    case .timeline: return String(localized: "history.mode.timeline")
    }
  }

  var icon: String {
    switch self {
    case .calendar: return "calendar"
    case .list: return "list.bullet"
    case .timeline: return "clock"
    }
  }
}

struct HistoryView: View {
  @Bindable var store: HistoryStore
  @State private var selectedMode: HistoryViewMode = .calendar
  @State private var selectedDate: Date? = Date()
  @State private var showStatistics: Bool = false
  
  var body: some View {
    ZStack {
      WaveAnimationViewRepresentable(
        color: DS.Color.primaryLight,
        progress: 0.4,
        backgroundColor: DS.Color.backgroundPrimary
      )
      .ignoresSafeArea()

      VStack(spacing: DS.Spacing.none) {
        headerSection

        modePicker
          .padding(.top, DS.Spacing.sm)

        TabView(selection: $selectedMode) {
          HistoryCalendarTab(
            store: store,
            selectedDate: $selectedDate
          )
          .tag(HistoryViewMode.calendar)

          HistoryListTab(store: store)
            .tag(HistoryViewMode.list)

          HistoryTimelineTab(store: store)
            .tag(HistoryViewMode.timeline)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
      }
    }
    .toolbarBackgroundVisibility(.hidden, for: .tabBar)
    .ignoresSafeArea(edges: .bottom)
    .task {
      await store.send(.viewDidLoad)
      await store.send(.selectDate(Date()))
      Analytics.shared.logScreenView("history_screen")
    }
  }
  
  private var headerSection: some View {
    HStack {
      Text(String(localized: "history.title"))
        .font(DS.SwiftUIFont.title1)
        .foregroundStyle(DS.SwiftUIColor.textPrimary)
        .accessibilityAddTraits(.isHeader)

      Spacer()

      statisticsButton
      
      monthSummaryBadge
    }
    .padding(.horizontal, DS.Spacing.lg)
    .padding(.top, DS.Spacing.md)
    .sheet(isPresented: $showStatistics) {
      StatisticsView(store: StatisticsStore(provider: store.provider))
    }
  }
  
  private var statisticsButton: some View {
    Button {
      showStatistics = true
      Analytics.shared.log(.statisticsOpened(source: .history))
    } label: {
      Image(systemName: "chart.bar.xaxis")
        .font(DS.SwiftUIFont.body)
        .foregroundStyle(DS.SwiftUIColor.primary)
        .padding(DS.Spacing.xs)
        .background(DS.SwiftUIColor.primary.opacity(0.12))
        .clipShape(Circle())
    }
    .accessibilityLabel(String(localized: "accessibility.statistics.button"))
  }

  private var monthSummaryBadge: some View {
    HStack(spacing: DS.Spacing.xxs) {
      Text("📊")
        .font(DS.SwiftUIFont.subhead)
        .accessibilityHidden(true)
      Text(String(format: String(localized: "history.month.summary"), "\(store.monthlySuccessCount)"))
        .font(DS.SwiftUIFont.footnoteSemibold)
        .foregroundStyle(DS.SwiftUIColor.textPrimary)
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel(String(localized: "accessibility.history.summary", defaultValue: "This month \(store.monthlySuccessCount) days achieved"))
    .padding(.horizontal, DS.Spacing.sm)
    .padding(.vertical, DS.Spacing.xs)
    .background(
      RoundedRectangle(cornerRadius: DS.Size.cornerRadiusLarge, style: .continuous)
        .fill(.white)
        .shadow(color: DS.SwiftUIColor.primary.opacity(0.15), radius: DS.Spacing.xs, y: 2)
    )
  }
  
  private var modePicker: some View {
    HStack(spacing: DS.Spacing.none) {
      ForEach(HistoryViewMode.allCases, id: \.self) { mode in
        Button {
          withAnimation(.easeInOut(duration: 0.2)) {
            selectedMode = mode
          }
        } label: {
          HStack(spacing: DS.Spacing.xxs) {
            Image(systemName: mode.icon)
              .font(DS.SwiftUIFont.captionSemibold)
            Text(mode.localizedName)
              .font(DS.SwiftUIFont.footnoteSemibold)
          }
          .foregroundStyle(selectedMode == mode ? .white : DS.SwiftUIColor.textSecondary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, DS.Spacing.xs)
          .background(
            RoundedRectangle(cornerRadius: DS.Size.cornerRadiusMedium, style: .continuous)
              .fill(selectedMode == mode ? DS.SwiftUIColor.primary : .clear)
          )
        }
        .accessibilityLabel(mode.localizedName)
        .accessibilityAddTraits(selectedMode == mode ? [.isSelected] : [])
      }
    }
    .padding(DS.Spacing.xxs)
    .background(
      RoundedRectangle(cornerRadius: DS.Size.cornerRadiusMedium, style: .continuous)
        .fill(.white)
        .shadow(color: DS.SwiftUIColor.primary.opacity(0.1), radius: DS.Spacing.xs, y: 2)
    )
    .padding(.horizontal, DS.Spacing.lg)
  }
}

// MARK: - Calendar Tab
struct HistoryCalendarTab: View {
  @Bindable var store: HistoryStore
  @Binding var selectedDate: Date?
  
  var body: some View {
    VStack(spacing: DS.Spacing.none) {
      FSCalendarRepresentable(
        selectedDate: $selectedDate,
        successDates: store.successDates
      ) { date in
        Task { await store.send(.selectDate(date)) }
      }
      .frame(height: 320)
      .padding(.horizontal, DS.Spacing.lg)
      .padding(.top, DS.Spacing.md)
      .shadow(color: DS.SwiftUIColor.primary.opacity(0.1), radius: DS.Spacing.sm, y: DS.Spacing.xxs)
      
      legendSection
        .padding(.top, DS.Spacing.md)
      
      if let record = store.selectedRecord {
        RecordCard(
          record: record,
          streak: store.calculateStreakForDate(record.date),
          instagramSharingService: store.provider.instagramSharingService,
          socialSharingService: store.provider.socialSharingService
        )
          .padding(.horizontal, DS.Spacing.lg)
          .padding(.top, DS.Spacing.lg)
          .transition(.opacity.combined(with: .move(edge: .bottom)))
      }
      
      Spacer()
    }
    .animation(.easeInOut(duration: 0.2), value: store.selectedRecord != nil)
  }
  
  private var legendSection: some View {
    HStack(spacing: DS.Spacing.xl) {
      LegendItem(color: DS.SwiftUIColor.primary.opacity(0.3), text: String(localized: "history.legend.today"))
      LegendItem(color: Color(DS.Color.textPrimary), text: String(localized: "history.legend.selected"))
      LegendItem(color: DS.SwiftUIColor.primary, text: String(localized: "history.legend.achieved"))
    }
  }
}

// MARK: - List Tab
struct HistoryListTab: View {
  @Bindable var store: HistoryStore
  @State private var nativeAd: GADNativeAd?
  
  private var sortedRecords: [WaterRecord] {
    store.waterRecordList.sorted { $0.date > $1.date }
  }
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: DS.Spacing.sm) {
        ForEach(Array(sortedRecords.enumerated()), id: \.element.id) { index, record in
          ListRecordRow(record: record)

          if (index + 1) % 5 == 0, let ad = nativeAd {
            NativeAdCard(nativeAd: ad)
          }
        }
      }
      .padding(.horizontal, DS.Spacing.lg)
      .padding(.top, DS.Spacing.md)
      .padding(.bottom, DS.Spacing.scrollBottom)
    }
    .scrollContentBackground(.hidden)
    .ignoresSafeArea(edges: .bottom)
    .onAppear {
      nativeAd = AdMobService.shared.getNativeAd()
    }
  }
}

struct ListRecordRow: View {
  let record: WaterRecord
  
  var body: some View {
    HStack(spacing: DS.Spacing.md) {
      VStack(spacing: DS.Spacing.xxs) {
        Text(dayString)
          .font(DS.SwiftUIFont.title2)
          .foregroundStyle(record.isSuccess ? DS.SwiftUIColor.primary : DS.SwiftUIColor.textSecondary)
        Text(monthString)
          .font(DS.SwiftUIFont.captionMedium)
          .foregroundStyle(DS.SwiftUIColor.textTertiary)
      }
      .frame(width: 50)
      
      VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
        Text(weekdayString)
          .font(DS.SwiftUIFont.subheadSemibold)
          .foregroundStyle(DS.SwiftUIColor.textPrimary)
        
        ProgressView(value: min(Float(record.value) / Float(record.goal), 1.0))
          .tint(record.isSuccess ? DS.SwiftUIColor.success : DS.SwiftUIColor.primary)
          .accessibilityHidden(true)

         HStack(spacing: DS.Spacing.xxs) {
           Image(systemName: record.drinkType?.iconName ?? "drop.fill")
             .font(DS.SwiftUIFont.caption)
             .foregroundStyle(DS.SwiftUIColor.textTertiary)
           Text(String(format: String(localized: "history.record.progress"), "\(record.value)", "\(record.goal)"))
             .font(DS.SwiftUIFont.captionMedium)
             .foregroundStyle(DS.SwiftUIColor.textTertiary)
         }
      }
      
      Spacer()
      
      if record.isSuccess {
        Image(systemName: "checkmark.circle.fill")
          .font(DS.SwiftUIFont.title2)
          .foregroundStyle(DS.SwiftUIColor.success)
          .accessibilityHidden(true)
      } else {
        Text(percentageString)
          .font(DS.SwiftUIFont.bodyBold)
          .foregroundStyle(DS.SwiftUIColor.textSecondary)
      }
    }
    .padding(DS.Spacing.md)
    .background(
      RoundedRectangle(cornerRadius: DS.Size.cornerRadiusLarge, style: .continuous)
        .fill(.white)
        .shadow(color: DS.SwiftUIColor.primary.opacity(0.08), radius: DS.Spacing.xs, y: 2)
    )
    .accessibilityElement(children: .combine)
    .accessibilityLabel(accessibilityDescription)
  }
  
  private var accessibilityDescription: String {
    let status = record.isSuccess 
      ? String(localized: "accessibility.history.achieved", defaultValue: "Goal achieved")
      : String(localized: "accessibility.history.progress", defaultValue: "\(percentageString) of goal")
    return "\(weekdayString), \(monthString) \(dayString). \(record.value) of \(record.goal) milliliters. \(status)"
  }
  
  private var dayString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter.string(from: record.date)
  }
  
  private var monthString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = NSLocalizedString("dateformat.month", comment: "")
    formatter.locale = Locale.current
    return formatter.string(from: record.date)
  }
  
  private var weekdayString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    formatter.locale = Locale.current
    return formatter.string(from: record.date)
  }
  
  private var percentageString: String {
    let percentage = Float(record.value) / Float(record.goal) * 100
    return String(format: "%.0f%%", min(percentage, 999))
  }
}

// MARK: - Timeline Tab
struct HistoryTimelineTab: View {
  @Bindable var store: HistoryStore
  
  private var groupedRecords: [(String, [WaterRecord])] {
    let grouped = Dictionary(grouping: store.waterRecordList) { record -> String in
      let formatter = DateFormatter()
      formatter.dateFormat = NSLocalizedString("dateformat.yearmonth", comment: "")
      formatter.locale = Locale.current
      return formatter.string(from: record.date)
    }
    return grouped.sorted { $0.key > $1.key }
  }
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: DS.Spacing.none) {
        ForEach(groupedRecords, id: \.0) { month, records in
          TimelineMonthSection(month: month, records: records.sorted { $0.date > $1.date })
        }
      }
      .padding(.horizontal, DS.Spacing.lg)
      .padding(.top, DS.Spacing.md)
      .padding(.bottom, DS.Spacing.scrollBottom)
    }
    .scrollContentBackground(.hidden)
    .ignoresSafeArea(edges: .bottom)
  }
}

struct TimelineMonthSection: View {
  let month: String
  let records: [WaterRecord]
  
  private var successCount: Int {
    records.filter { $0.isSuccess }.count
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: DS.Spacing.none) {
      HStack {
        Text(month)
          .font(DS.SwiftUIFont.headline)
          .foregroundStyle(DS.SwiftUIColor.textPrimary)

        Spacer()

        Text(String(format: String(localized: "history.timeline.achieved"), "\(successCount)", "\(records.count)"))
          .font(DS.SwiftUIFont.footnoteMedium)
          .foregroundStyle(DS.SwiftUIColor.textSecondary)
      }
      .padding(.vertical, DS.Spacing.sm)
      
      ForEach(records.indices, id: \.self) { index in
        TimelineRecordRow(record: records[index], isLast: index == records.count - 1)
      }
    }
  }
}

struct TimelineRecordRow: View {
  let record: WaterRecord
  let isLast: Bool
  
  var body: some View {
    HStack(alignment: .top, spacing: DS.Spacing.md) {
      VStack(spacing: DS.Spacing.none) {
        Circle()
          .fill(record.isSuccess ? DS.SwiftUIColor.success : DS.SwiftUIColor.primary.opacity(0.3))
          .frame(width: DS.Spacing.sm, height: DS.Spacing.sm)
        
        if !isLast {
          Rectangle()
            .fill(DS.SwiftUIColor.primary.opacity(0.2))
            .frame(width: 2)
            .frame(maxHeight: .infinity)
        }
      }
      .frame(width: DS.Spacing.sm)
      
      VStack(alignment: .leading, spacing: DS.Spacing.xs) {
        HStack {
          Text(dateString)
            .font(DS.SwiftUIFont.subheadSemibold)
            .foregroundStyle(DS.SwiftUIColor.textPrimary)
          
          Spacer()
          
          if record.isSuccess {
            Label(String(localized: "history.label.achieved"), systemImage: "checkmark.circle.fill")
              .font(DS.SwiftUIFont.captionSemibold)
              .foregroundStyle(DS.SwiftUIColor.success)
          }
        }

         HStack(spacing: DS.Spacing.md) {
           Label("\(record.value)ml", systemImage: record.drinkType?.iconName ?? "drop.fill")
             .font(DS.SwiftUIFont.footnoteMedium)
             .foregroundStyle(DS.SwiftUIColor.primary)

          Text(String(format: String(localized: "history.record.goal"), "\(record.goal)"))
            .font(DS.SwiftUIFont.footnoteMedium)
            .foregroundStyle(DS.SwiftUIColor.textTertiary)
        }
      }
      .padding(.bottom, isLast ? DS.Spacing.none : DS.Spacing.lg)
    }
  }
  
  private var dateString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = NSLocalizedString("dateformat.monthday", comment: "")
    formatter.locale = Locale.current
    return formatter.string(from: record.date)
  }
}

// MARK: - Shared Components
struct RecordCard: View {
  let record: WaterRecord
  let streak: Int
  let instagramSharingService: InstagramSharingServiceProtocol
  let socialSharingService: SocialSharingServiceProtocol
  @State private var showShareSheet = false
  @State private var showInstagramNotInstalledAlert = false
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: DS.Spacing.xs) {
        Text(formatDate(record.date))
          .font(DS.SwiftUIFont.bodyBold)
          .foregroundStyle(DS.SwiftUIColor.textPrimary)
        
        HStack(spacing: DS.Spacing.md) {
          VStack(alignment: .leading, spacing: 2) {
            Text(String(localized: "history.card.goal"))
              .font(DS.SwiftUIFont.captionMedium)
              .foregroundStyle(DS.SwiftUIColor.textTertiary)
            Text("\(record.goal)ml")
              .font(DS.SwiftUIFont.subheadSemibold)
              .foregroundStyle(DS.SwiftUIColor.textSecondary)
          }

           VStack(alignment: .leading, spacing: 2) {
             Text(String(localized: "history.card.intake"))
               .font(DS.SwiftUIFont.captionMedium)
               .foregroundStyle(DS.SwiftUIColor.textTertiary)
             HStack(spacing: DS.Spacing.xxs) {
               Image(systemName: record.drinkType?.iconName ?? "drop.fill")
                 .font(DS.SwiftUIFont.caption)
               Text("\(record.value)ml")
                 .font(DS.SwiftUIFont.subheadSemibold)
                 .foregroundStyle(DS.SwiftUIColor.textSecondary)
             }
           }
        }
      }

      Spacer()

      VStack(spacing: DS.Spacing.xxs) {
        Text(calculatePercentage(record))
          .font(DS.SwiftUIFont.title2)
          .foregroundStyle(record.isSuccess ? DS.SwiftUIColor.success : DS.SwiftUIColor.primary)

        if record.isSuccess {
          Text(String(localized: "history.card.achieved"))
            .font(DS.SwiftUIFont.captionSemibold)
            .foregroundStyle(DS.SwiftUIColor.success)
        }
      }
      
      Button {
        showShareSheet = true
      } label: {
        Image(systemName: "square.and.arrow.up")
          .font(DS.SwiftUIFont.body)
          .foregroundStyle(DS.SwiftUIColor.primary)
          .frame(width: DS.Size.iconContainerSmall, height: DS.Size.iconContainerSmall)
          .background(DS.SwiftUIColor.primary.opacity(0.12))
          .clipShape(Circle())
      }
      .accessibilityLabel(String(localized: "accessibility.history.share", defaultValue: "Share to Instagram"))
    }
    .padding(DS.Spacing.lg)
    .background(
      RoundedRectangle(cornerRadius: DS.Size.cornerRadiusXLarge, style: .continuous)
        .fill(.white)
        .shadow(color: DS.SwiftUIColor.primary.opacity(0.15), radius: DS.Spacing.sm, y: DS.Spacing.xxs)
    )
    .confirmationDialog(
      String(localized: "share.title.extended"),
      isPresented: $showShareSheet,
      titleVisibility: .visible
    ) {
      Button(String(localized: "share.instagram.stories")) {
        Task { await shareToInstagram(destination: .stories) }
      }
      Button(String(localized: "share.instagram.feed")) {
        Task { await shareToInstagram(destination: .feed) }
      }
      Button(String(localized: "share.system")) {
        Task { await shareViaSystemSheet() }
      }
      Button(String(localized: "home.goal.cancel"), role: .cancel) {}
    }
    .alert(
      String(localized: "share.error.title"),
      isPresented: $showInstagramNotInstalledAlert
    ) {
      Button(String(localized: "share.error.ok"), role: .cancel) {}
    } message: {
      Text(String(localized: "share.error.instagram.not.installed"))
    }
  }
  
  private func shareToInstagram(destination: ShareDestination) async {
    let analyticsDestination: InstagramShareDestination = destination == .stories ? .stories : .feed
    
    Analytics.shared.log(.instagramShareInitiated(destination: analyticsDestination, source: .history))
    
    guard instagramSharingService.isInstagramInstalled() else {
      Analytics.shared.log(.instagramShareFailed(destination: analyticsDestination, reason: "instagram_not_installed"))
      showInstagramNotInstalledAlert = true
      return
    }
    
    do {
      switch destination {
      case .stories:
        try await instagramSharingService.shareToStories(record: record, streak: streak)
      case .feed:
        try await instagramSharingService.shareToFeed(record: record, streak: streak)
      }
      Analytics.shared.log(.instagramShareCompleted(destination: analyticsDestination, source: .history))
    } catch {
      Analytics.shared.log(.instagramShareFailed(destination: analyticsDestination, reason: error.localizedDescription))
      showInstagramNotInstalledAlert = true
    }
  }
  
  private func shareViaSystemSheet() async {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let rootVC = windowScene.windows.first?.rootViewController else { return }
    
    do {
      try await socialSharingService.shareViaSystemSheet(record: record, streak: streak, source: .history, from: rootVC)
    } catch {
    }
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = NSLocalizedString("dateformat.monthday", comment: "")
    formatter.locale = Locale.current
    return "📌 " + formatter.string(from: date)
  }
  
  private func calculatePercentage(_ record: WaterRecord) -> String {
    let percentage = Float(record.value) / Float(record.goal) * 100
    return String(format: "%.0f%%", min(percentage, 999))
  }
}

struct LegendItem: View {
  let color: Color
  let text: String
  
  var body: some View {
    HStack(spacing: DS.Spacing.xxs) {
      Circle()
        .fill(color)
        .frame(width: DS.Spacing.xs + 2, height: DS.Spacing.xs + 2)
      Text(text)
        .font(DS.SwiftUIFont.captionMedium)
        .foregroundStyle(DS.SwiftUIColor.textSecondary)
    }
  }
}
