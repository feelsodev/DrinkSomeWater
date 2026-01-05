import SwiftUI
import UIKit

enum HistoryViewMode: String, CaseIterable {
  case calendar = "캘린더"
  case list = "리스트"
  case timeline = "타임라인"
  
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
  @State private var selectedDate: Date? = nil
  
  var body: some View {
    ZStack {
      WaveAnimationViewRepresentable(
        color: DS.Color.primaryLight,
        progress: 0.4,
        backgroundColor: DS.Color.backgroundPrimary
      )
      .ignoresSafeArea()
      
      VStack(spacing: 0) {
        headerSection
        
        modePicker
          .padding(.top, 12)
        
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
    .task {
      await store.send(.viewDidLoad)
    }
  }
  
  private var headerSection: some View {
    HStack {
      Text("기록")
        .font(.system(size: 28, weight: .bold))
        .foregroundStyle(DS.SwiftUIColor.textPrimary)
      
      Spacer()
      
      monthSummaryBadge
    }
    .padding(.horizontal, 20)
    .padding(.top, 16)
  }
  
  private var monthSummaryBadge: some View {
    HStack(spacing: 6) {
      Text("📊")
        .font(.system(size: 14))
      Text("이번 달: \(store.monthlySuccessCount)일 달성")
        .font(.system(size: 13, weight: .semibold))
        .foregroundStyle(DS.SwiftUIColor.textPrimary)
    }
    .padding(.horizontal, 12)
    .padding(.vertical, 8)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(.white)
        .shadow(color: DS.SwiftUIColor.primary.opacity(0.15), radius: 8, y: 2)
    )
  }
  
  private var modePicker: some View {
    HStack(spacing: 0) {
      ForEach(HistoryViewMode.allCases, id: \.self) { mode in
        Button {
          withAnimation(.easeInOut(duration: 0.2)) {
            selectedMode = mode
          }
        } label: {
          HStack(spacing: 6) {
            Image(systemName: mode.icon)
              .font(.system(size: 12, weight: .semibold))
            Text(mode.rawValue)
              .font(.system(size: 13, weight: .semibold))
          }
          .foregroundStyle(selectedMode == mode ? .white : DS.SwiftUIColor.textSecondary)
          .frame(maxWidth: .infinity)
          .padding(.vertical, 10)
          .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
              .fill(selectedMode == mode ? DS.SwiftUIColor.primary : .clear)
          )
        }
      }
    }
    .padding(4)
    .background(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .fill(.white)
        .shadow(color: DS.SwiftUIColor.primary.opacity(0.1), radius: 8, y: 2)
    )
    .padding(.horizontal, 20)
  }
}

// MARK: - Calendar Tab
struct HistoryCalendarTab: View {
  @Bindable var store: HistoryStore
  @Binding var selectedDate: Date?
  
  var body: some View {
    VStack(spacing: 0) {
      FSCalendarRepresentable(
        selectedDate: $selectedDate,
        successDates: store.successDates
      ) { date in
        Task { await store.send(.selectDate(date)) }
      }
      .frame(height: 320)
      .padding(.horizontal, 20)
      .padding(.top, 16)
      .shadow(color: DS.SwiftUIColor.primary.opacity(0.1), radius: 12, y: 4)
      
      legendSection
        .padding(.top, 16)
      
      if let record = store.selectedRecord {
        RecordCard(record: record)
          .padding(.horizontal, 20)
          .padding(.top, 20)
          .transition(.opacity.combined(with: .move(edge: .bottom)))
      }
      
      Spacer()
    }
    .animation(.easeInOut(duration: 0.2), value: store.selectedRecord != nil)
  }
  
  private var legendSection: some View {
    HStack(spacing: 24) {
      LegendItem(color: DS.SwiftUIColor.primary.opacity(0.3), text: "오늘")
      LegendItem(color: Color(DS.Color.textPrimary), text: "선택")
      LegendItem(color: DS.SwiftUIColor.primary, text: "달성")
    }
  }
}

// MARK: - List Tab
struct HistoryListTab: View {
  @Bindable var store: HistoryStore
  
  private var sortedRecords: [WaterRecord] {
    store.waterRecordList.sorted { $0.date > $1.date }
  }
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 12) {
        ForEach(sortedRecords, id: \.id) { record in
          ListRecordRow(record: record)
        }
      }
      .padding(.horizontal, 20)
      .padding(.top, 16)
      .padding(.bottom, 100)
    }
  }
}

struct ListRecordRow: View {
  let record: WaterRecord
  
  var body: some View {
    HStack(spacing: 16) {
      VStack(spacing: 4) {
        Text(dayString)
          .font(.system(size: 24, weight: .bold))
          .foregroundStyle(record.isSuccess ? DS.SwiftUIColor.primary : DS.SwiftUIColor.textSecondary)
        Text(monthString)
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(DS.SwiftUIColor.textTertiary)
      }
      .frame(width: 50)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(weekdayString)
          .font(.system(size: 14, weight: .semibold))
          .foregroundStyle(DS.SwiftUIColor.textPrimary)
        
        ProgressView(value: min(Float(record.value) / Float(record.goal), 1.0))
          .tint(record.isSuccess ? DS.SwiftUIColor.success : DS.SwiftUIColor.primary)
        
        Text("\(record.value)ml / \(record.goal)ml")
          .font(.system(size: 12, weight: .medium))
          .foregroundStyle(DS.SwiftUIColor.textTertiary)
      }
      
      Spacer()
      
      if record.isSuccess {
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 24))
          .foregroundStyle(DS.SwiftUIColor.success)
      } else {
        Text(percentageString)
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(DS.SwiftUIColor.textSecondary)
      }
    }
    .padding(16)
    .background(
      RoundedRectangle(cornerRadius: 16, style: .continuous)
        .fill(.white)
        .shadow(color: DS.SwiftUIColor.primary.opacity(0.08), radius: 8, y: 2)
    )
  }
  
  private var dayString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter.string(from: record.date)
  }
  
  private var monthString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M월"
    return formatter.string(from: record.date)
  }
  
  private var weekdayString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE"
    formatter.locale = Locale(identifier: "ko_KR")
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
      formatter.dateFormat = "yyyy년 M월"
      return formatter.string(from: record.date)
    }
    return grouped.sorted { $0.key > $1.key }
  }
  
  var body: some View {
    ScrollView {
      LazyVStack(spacing: 0) {
        ForEach(groupedRecords, id: \.0) { month, records in
          TimelineMonthSection(month: month, records: records.sorted { $0.date > $1.date })
        }
      }
      .padding(.horizontal, 20)
      .padding(.top, 16)
      .padding(.bottom, 100)
    }
  }
}

struct TimelineMonthSection: View {
  let month: String
  let records: [WaterRecord]
  
  private var successCount: Int {
    records.filter { $0.isSuccess }.count
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text(month)
          .font(.system(size: 18, weight: .bold))
          .foregroundStyle(DS.SwiftUIColor.textPrimary)
        
        Spacer()
        
        Text("\(successCount)/\(records.count)일 달성")
          .font(.system(size: 13, weight: .medium))
          .foregroundStyle(DS.SwiftUIColor.textSecondary)
      }
      .padding(.vertical, 12)
      
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
    HStack(alignment: .top, spacing: 16) {
      VStack(spacing: 0) {
        Circle()
          .fill(record.isSuccess ? DS.SwiftUIColor.success : DS.SwiftUIColor.primary.opacity(0.3))
          .frame(width: 12, height: 12)
        
        if !isLast {
          Rectangle()
            .fill(DS.SwiftUIColor.primary.opacity(0.2))
            .frame(width: 2)
            .frame(maxHeight: .infinity)
        }
      }
      .frame(width: 12)
      
      VStack(alignment: .leading, spacing: 8) {
        HStack {
          Text(dateString)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(DS.SwiftUIColor.textPrimary)
          
          Spacer()
          
          if record.isSuccess {
            Label("달성", systemImage: "checkmark.circle.fill")
              .font(.system(size: 12, weight: .semibold))
              .foregroundStyle(DS.SwiftUIColor.success)
          }
        }
        
        HStack(spacing: 16) {
          Label("\(record.value)ml", systemImage: "drop.fill")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(DS.SwiftUIColor.primary)
          
          Text("목표 \(record.goal)ml")
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(DS.SwiftUIColor.textTertiary)
        }
      }
      .padding(.bottom, isLast ? 0 : 20)
    }
  }
  
  private var dateString: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M월 d일 (E)"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: record.date)
  }
}

// MARK: - Shared Components
struct RecordCard: View {
  let record: WaterRecord
  
  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 8) {
        Text(formatDate(record.date))
          .font(.system(size: 16, weight: .bold))
          .foregroundStyle(DS.SwiftUIColor.textPrimary)
        
        HStack(spacing: 16) {
          VStack(alignment: .leading, spacing: 2) {
            Text("목표량")
              .font(.system(size: 12, weight: .medium))
              .foregroundStyle(DS.SwiftUIColor.textTertiary)
            Text("\(record.goal)ml")
              .font(.system(size: 14, weight: .semibold))
              .foregroundStyle(DS.SwiftUIColor.textSecondary)
          }
          
          VStack(alignment: .leading, spacing: 2) {
            Text("섭취량")
              .font(.system(size: 12, weight: .medium))
              .foregroundStyle(DS.SwiftUIColor.textTertiary)
            Text("\(record.value)ml")
              .font(.system(size: 14, weight: .semibold))
              .foregroundStyle(DS.SwiftUIColor.textSecondary)
          }
        }
      }
      
      Spacer()
      
      VStack(spacing: 4) {
        Text(calculatePercentage(record))
          .font(.system(size: 24, weight: .bold))
          .foregroundStyle(record.isSuccess ? DS.SwiftUIColor.success : DS.SwiftUIColor.primary)
        
        if record.isSuccess {
          Text("달성! ✅")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(DS.SwiftUIColor.success)
        }
      }
    }
    .padding(20)
    .background(
      RoundedRectangle(cornerRadius: 20, style: .continuous)
        .fill(.white)
        .shadow(color: DS.SwiftUIColor.primary.opacity(0.15), radius: 12, y: 4)
    )
  }
  
  private func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "M월 d일 (E)"
    formatter.locale = Locale(identifier: "ko_KR")
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
    HStack(spacing: 6) {
      Circle()
        .fill(color)
        .frame(width: 10, height: 10)
      Text(text)
        .font(.system(size: 12, weight: .medium))
        .foregroundStyle(DS.SwiftUIColor.textSecondary)
    }
  }
}
