import SnapshotTesting
import SwiftUI
import Testing
@testable import DrinkSomeWater

@MainActor
@Suite(.snapshots(record: .missing))
struct HomeViewSnapshotTests {
    
    @Test func homeView_empty() async {
        let store = SnapshotFixtures.emptyHomeStore
        let view = HomeView(store: store)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13)),
            named: "HomeView_Empty"
        )
    }
    
    @Test func homeView_halfProgress() async {
        let store = SnapshotFixtures.halfProgressHomeStore
        let view = HomeView(store: store)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13)),
            named: "HomeView_HalfProgress"
        )
    }
    
    @Test func homeView_goalAchieved() async {
        let store = SnapshotFixtures.goalAchievedHomeStore
        let view = HomeView(store: store)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13)),
            named: "HomeView_GoalAchieved"
        )
    }
    
    @Test func homeView_withNotificationBanner() async {
        let store = SnapshotFixtures.notificationBannerHomeStore
        let view = HomeView(store: store)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13)),
            named: "HomeView_NotificationBanner"
        )
    }
    
    @Test func homeView_darkMode() async {
        let store = SnapshotFixtures.halfProgressHomeStore
        let view = HomeView(store: store)
        
        assertSnapshot(
            of: view,
            as: .image(
                layout: .device(config: .iPhone13),
                traits: UITraitCollection(userInterfaceStyle: .dark)
            ),
            named: "HomeView_DarkMode"
        )
    }
    
    @Test func homeView_iPhoneSE() async {
        let store = SnapshotFixtures.halfProgressHomeStore
        let view = HomeView(store: store)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhoneSe)),
            named: "HomeView_iPhoneSE"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct GoalSettingViewSnapshotTests {
    
    @Test func goalSettingView_default() async {
        let store = SnapshotFixtures.halfProgressHomeStore
        let view = GoalSettingView(
            currentGoal: 2000,
            provider: store.provider,
            onSave: {}
        )
        
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13)),
            named: "GoalSettingView_Default"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct QuickButtonSettingViewSnapshotTests {
    
    @Test func quickButtonSettingView_default() async {
        let store = SnapshotFixtures.halfProgressHomeStore
        let view = QuickButtonSettingView(
            currentButtons: [100, 200, 300, 500],
            provider: store.provider,
            onSave: {}
        )
        
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13)),
            named: "QuickButtonSettingView_Default"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct WaterAdjustmentViewSnapshotTests {
    
    @Test func waterAdjustmentView_default() async {
        let store = SnapshotFixtures.halfProgressHomeStore
        let view = WaterAdjustmentView(store: store)
        
        assertSnapshot(
            of: view,
            as: .image(layout: .device(config: .iPhone13)),
            named: "WaterAdjustmentView_Default"
        )
    }
}
