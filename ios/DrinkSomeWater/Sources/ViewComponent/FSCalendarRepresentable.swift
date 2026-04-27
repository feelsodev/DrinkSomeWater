import SwiftUI
import UIKit
import FSCalendar

struct FSCalendarRepresentable: UIViewRepresentable {
  @Binding var selectedDate: Date?
  let successDates: [String]
  let onDateSelected: (Date) -> Void
  
  func makeUIView(context: Context) -> FSCalendar {
    let calendar = FSCalendar()
    calendar.delegate = context.coordinator
    calendar.dataSource = context.coordinator
    calendar.locale = Locale.current
    calendar.backgroundColor = UIColor.white.withAlphaComponent(0.95)
    calendar.layer.cornerRadius = 20
    calendar.layer.cornerCurve = .continuous
    calendar.clipsToBounds = true

    let appearance = calendar.appearance
     appearance.selectionColor = DS.Color.textPrimary
     appearance.todayColor = DS.Color.primary.withAlphaComponent(0.3)
     appearance.todaySelectionColor = DS.Color.primary
     appearance.headerMinimumDissolvedAlpha = 0.0
     appearance.headerDateFormat = L.Calendar.dateFormat
     appearance.headerTitleColor = DS.Color.textPrimary
    appearance.weekdayTextColor = DS.Color.textSecondary
    appearance.headerTitleFont = UIFont.systemFont(ofSize: 18, weight: .bold)
    appearance.weekdayFont = UIFont.systemFont(ofSize: 14, weight: .semibold)
    appearance.titleFont = UIFont.systemFont(ofSize: 14, weight: .medium)
    appearance.eventDefaultColor = DS.Color.primary
    appearance.eventSelectionColor = DS.Color.primary

    calendar.select(Date())

    return calendar
  }
  
  func updateUIView(_ uiView: FSCalendar, context: Context) {
    context.coordinator.successDates = successDates
    uiView.reloadData()
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  @MainActor
  class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    var parent: FSCalendarRepresentable
    var successDates: [String] = []
    
    init(_ parent: FSCalendarRepresentable) {
      self.parent = parent
      self.successDates = parent.successDates
    }
    
    nonisolated func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
      Task { @MainActor in
        parent.selectedDate = date
        parent.onDateSelected(date)
      }
    }
    
    nonisolated func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
      MainActor.assumeIsolated {
        successDates.contains(date.dateToString) ? DS.Color.primary : nil
      }
    }
    
    nonisolated func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
      MainActor.assumeIsolated {
        successDates.contains(date.dateToString) ? .white : nil
      }
    }
  }
}
