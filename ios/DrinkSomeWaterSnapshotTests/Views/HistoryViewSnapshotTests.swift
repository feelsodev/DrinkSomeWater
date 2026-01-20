import SnapshotTesting
import SwiftUI
import Testing
@testable import DrinkSomeWater

@MainActor
@Suite(.snapshots(record: .missing))
struct HistoryViewSnapshotTests {
    
    @Test func historyView_calendar() async {
        let store = SnapshotFixtures.makeHistoryStore()
        let view = HistoryView(store: store)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13)),
            named: "HistoryView_Calendar"
        )
    }
    
    @Test func historyView_darkMode() async {
        let store = SnapshotFixtures.makeHistoryStore()
        let view = HistoryView(store: store)
        
        assertSnapshot(
            of: view,
            as: .image(
                layout: .device(config: .iPhone13),
                traits: UITraitCollection(userInterfaceStyle: .dark)
            ),
            named: "HistoryView_DarkMode"
        )
    }
    
    @Test func historyView_iPhoneSE() async {
        let store = SnapshotFixtures.makeHistoryStore()
        let view = HistoryView(store: store)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhoneSe)),
            named: "HistoryView_iPhoneSE"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct HistoryCalendarTabSnapshotTests {
    
    @Test func historyCalendarTab_withRecords() async {
        let store = SnapshotFixtures.makeHistoryStore()
        let view = HistoryCalendarTab(
            store: store,
            selectedDate: .constant(Date())
        )
        
        assertSnapshot(
            of: view,
            as: .image(layout: .fixed(width: 390, height: 500)),
            named: "HistoryCalendarTab_WithRecords"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct HistoryListTabSnapshotTests {
    
    @Test func historyListTab_withRecords() async {
        let store = SnapshotFixtures.makeHistoryStore()
        let view = HistoryListTab(store: store)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .fixed(width: 390, height: 600)),
            named: "HistoryListTab_WithRecords"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct HistoryTimelineTabSnapshotTests {
    
    @Test func historyTimelineTab_withRecords() async {
        let store = SnapshotFixtures.makeHistoryStore()
        let view = HistoryTimelineTab(store: store)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .fixed(width: 390, height: 600)),
            named: "HistoryTimelineTab_WithRecords"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct ListRecordRowSnapshotTests {
    
    @Test func listRecordRow_success() async {
        let record = WaterRecord(
            date: Date(),
            value: 2200,
            isSuccess: true,
            goal: 2000
        )
        let view = ListRecordRow(record: record)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .fixed(width: 358, height: 80)),
            named: "ListRecordRow_Success"
        )
    }
    
    @Test func listRecordRow_inProgress() async {
        let record = WaterRecord(
            date: Date(),
            value: 1200,
            isSuccess: false,
            goal: 2000
        )
        let view = ListRecordRow(record: record)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .fixed(width: 358, height: 80)),
            named: "ListRecordRow_InProgress"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct RecordCardSnapshotTests {
    
    @Test func recordCard_success() async {
        let record = WaterRecord(
            date: Date(),
            value: 2200,
            isSuccess: true,
            goal: 2000
        )
        let view = RecordCard(record: record)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .fixed(width: 358, height: 120)),
            named: "RecordCard_Success"
        )
    }
    
    @Test func recordCard_inProgress() async {
        let record = WaterRecord(
            date: Date(),
            value: 1200,
            isSuccess: false,
            goal: 2000
        )
        let view = RecordCard(record: record)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .fixed(width: 358, height: 120)),
            named: "RecordCard_InProgress"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct LegendItemSnapshotTests {
    
    @Test func legendItem_primary() async {
        let view = LegendItem(color: .blue, text: "Today")
        
        assertSnapshot(
            of: view,
            as: .image(layout: .sizeThatFits),
            named: "LegendItem_Primary"
        )
    }
}
