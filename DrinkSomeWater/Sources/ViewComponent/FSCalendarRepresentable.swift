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
    calendar.backgroundColor = UIColor.white.withAlphaComponent(0.95)
    calendar.layer.cornerRadius = 20
    calendar.layer.cornerCurve = .continuous
    calendar.clipsToBounds = true
    
    calendar.appearance.do {
      $0.selectionColor = DS.Color.textPrimary
      $0.todayColor = DS.Color.primary.withAlphaComponent(0.3)
      $0.todaySelectionColor = DS.Color.primary
      $0.headerMinimumDissolvedAlpha = 0.0
      $0.headerDateFormat = "yyyy년 M월"
      $0.headerTitleColor = DS.Color.textPrimary
      $0.weekdayTextColor = DS.Color.textSecondary
      $0.headerTitleFont = .systemFont(ofSize: 18, weight: .bold)
      $0.weekdayFont = .systemFont(ofSize: 14, weight: .semibold)
      $0.titleFont = .systemFont(ofSize: 14, weight: .medium)
      $0.eventDefaultColor = DS.Color.primary
      $0.eventSelectionColor = DS.Color.primary
    }
    
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
