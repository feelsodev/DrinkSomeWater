import SwiftUI
import Charts

struct StatisticsView: View {
  @Bindable var store: StatisticsStore
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: DS.Spacing.lg) {
          periodPicker
          summaryCards
          chartSection
        }
        .padding(DS.Spacing.md)
      }
      .background(DS.SwiftUIColor.backgroundPrimary)
      .navigationTitle(String(localized: "statistics.title"))
      .navigationBarTitleDisplayMode(.inline)
      .task {
        await store.send(.viewDidLoad)
      }
    }
  }
  
  // MARK: - Period Picker
  
  private var periodPicker: some View {
    Picker("Period", selection: Binding(
      get: { store.selectedPeriod },
      set: { period in
        Task { await store.send(.selectPeriod(period)) }
      }
    )) {
      ForEach(StatisticsPeriod.allCases, id: \.self) { period in
        Text(period.rawValue).tag(period)
      }
    }
    .pickerStyle(.segmented)
  }
  
  // MARK: - Summary Cards
  
  private var summaryCards: some View {
    HStack(spacing: DS.Spacing.sm) {
      summaryCard(
        title: String(localized: "statistics.daily.average"),
        value: "\(store.dailyAverage)",
        subtitle: "ml"
      )
      
      summaryCard(
        title: String(localized: "statistics.goal.achievement"),
        value: "\(Int(store.goalAchievementRate * 100))",
        subtitle: "%"
      )
      
      summaryCard(
        title: String(localized: "statistics.current.streak"),
        value: "\(store.currentStreak)",
        subtitle: String(localized: "statistics.days")
      )
    }
  }
  
  private func summaryCard(title: String, value: String, subtitle: String) -> some View {
    VStack(spacing: DS.Spacing.xxs) {
      Text(title)
        .font(DS.SwiftUIFont.caption)
        .foregroundStyle(DS.SwiftUIColor.textSecondary)
        .lineLimit(1)
        .minimumScaleFactor(0.8)
      
      HStack(alignment: .lastTextBaseline, spacing: 2) {
        Text(value)
          .font(DS.SwiftUIFont.title2)
          .fontWeight(.bold)
          .foregroundStyle(DS.SwiftUIColor.textPrimary)
        
        Text(subtitle)
          .font(DS.SwiftUIFont.caption)
          .foregroundStyle(DS.SwiftUIColor.textSecondary)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, DS.Spacing.md)
    .padding(.horizontal, DS.Spacing.sm)
    .background(DS.SwiftUIColor.backgroundSecondary)
    .clipShape(RoundedRectangle(cornerRadius: DS.Size.cornerRadiusMedium))
  }
  
  // MARK: - Chart Section
  
  private var chartSection: some View {
    VStack(alignment: .leading, spacing: DS.Spacing.sm) {
      Text(String(localized: "statistics.chart.title"))
        .font(DS.SwiftUIFont.headline)
        .foregroundStyle(DS.SwiftUIColor.textPrimary)
      
      if store.dailyData.isEmpty {
        emptyState
      } else {
        intakeChart
      }
    }
    .padding(DS.Spacing.md)
    .background(DS.SwiftUIColor.backgroundSecondary)
    .clipShape(RoundedRectangle(cornerRadius: DS.Size.cornerRadiusMedium))
  }
  
  private var intakeChart: some View {
    Chart {
      ForEach(store.dailyData, id: \.date) { item in
        BarMark(
          x: .value("Date", item.date, unit: .day),
          y: .value("Amount", item.amount)
        )
        .foregroundStyle(item.amount >= item.goal ? DS.SwiftUIColor.success : DS.SwiftUIColor.primary)
        .cornerRadius(4)
      }
      
      if let avgGoal = averageGoal {
        RuleMark(y: .value("Goal", avgGoal))
          .foregroundStyle(DS.SwiftUIColor.textSecondary.opacity(0.6))
          .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
          .annotation(position: .top, alignment: .trailing) {
            Text(String(localized: "statistics.chart.goal.line"))
              .font(DS.SwiftUIFont.captionSmall)
              .foregroundStyle(DS.SwiftUIColor.textSecondary)
          }
      }
    }
    .chartXAxis {
      AxisMarks(values: .stride(by: .day, count: xAxisStride)) { value in
        AxisGridLine()
        AxisValueLabel(format: .dateTime.day())
      }
    }
    .chartYAxis {
      AxisMarks(position: .leading) { value in
        AxisGridLine()
        AxisValueLabel()
      }
    }
    .frame(height: 220)
    .animation(.easeInOut, value: store.selectedPeriod)
  }
  
  private var emptyState: some View {
    VStack(spacing: DS.Spacing.sm) {
      Image(systemName: "chart.bar.xaxis")
        .font(.system(size: 40))
        .foregroundStyle(DS.SwiftUIColor.textTertiary)
      
      Text(String(localized: "statistics.empty"))
        .font(DS.SwiftUIFont.body)
        .foregroundStyle(DS.SwiftUIColor.textSecondary)
    }
    .frame(maxWidth: .infinity)
    .frame(height: 220)
  }
  
  // MARK: - Helpers
  
  private var averageGoal: Int? {
    guard !store.dailyData.isEmpty else { return nil }
    let totalGoal = store.dailyData.reduce(0) { $0 + $1.goal }
    return totalGoal / store.dailyData.count
  }
  
  private var xAxisStride: Int {
    store.selectedPeriod == .week ? 1 : 5
  }
}

#Preview {
  StatisticsView(store: StatisticsStore(provider: ServiceProvider()))
}
