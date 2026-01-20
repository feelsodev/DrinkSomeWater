import SnapshotTesting
import SwiftUI
import UIKit
import Testing
@testable import DrinkSomeWater

@MainActor
@Suite(.snapshots(record: .missing))
struct SettingsViewControllerSnapshotTests {
    
    @Test func settingsViewController_default() async {
        let provider = MockServiceProvider()
        let store = SettingsStore(provider: provider)
        let viewController = SettingsViewController(store: store)
        
        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13),
            named: "SettingsViewController_Default"
        )
    }
    
    @Test func settingsViewController_iPhoneSE() async {
        let provider = MockServiceProvider()
        let store = SettingsStore(provider: provider)
        let viewController = SettingsViewController(store: store)
        
        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhoneSe),
            named: "SettingsViewController_iPhoneSE"
        )
    }
    
    @Test func settingsViewController_darkMode() async {
        let provider = MockServiceProvider()
        let store = SettingsStore(provider: provider)
        let viewController = SettingsViewController(store: store)
        
        assertSnapshot(
            of: viewController,
            as: .image(
                on: .iPhone13,
                traits: UITraitCollection(userInterfaceStyle: .dark)
            ),
            named: "SettingsViewController_DarkMode"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct OnboardingViewControllerSnapshotTests {
    
    @Test func onboardingViewController_introPage() async {
        let provider = MockServiceProvider()
        let store = OnboardingStore(provider: provider)
        let viewController = OnboardingViewController(store: store)
        
        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13),
            named: "OnboardingViewController_IntroPage"
        )
    }
    
    @Test func onboardingViewController_iPhoneSE() async {
        let provider = MockServiceProvider()
        let store = OnboardingStore(provider: provider)
        let viewController = OnboardingViewController(store: store)
        
        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhoneSe),
            named: "OnboardingViewController_iPhoneSE"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct OnboardingPageViewControllerSnapshotTests {
    
    @Test func onboardingPage_intro() async {
        let provider = MockServiceProvider()
        let store = OnboardingStore(provider: provider)
        let viewController = OnboardingPageViewController(pageType: .intro, store: store)
        
        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13),
            named: "OnboardingPage_Intro"
        )
    }
    
    @Test func onboardingPage_goal() async {
        let provider = MockServiceProvider()
        let store = OnboardingStore(provider: provider)
        let viewController = OnboardingPageViewController(pageType: .goal, store: store)
        
        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13),
            named: "OnboardingPage_Goal"
        )
    }
    
    @Test func onboardingPage_healthKit() async {
        let provider = MockServiceProvider()
        let store = OnboardingStore(provider: provider)
        let viewController = OnboardingPageViewController(pageType: .healthKit, store: store)
        
        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13),
            named: "OnboardingPage_HealthKit"
        )
    }
    
    @Test func onboardingPage_notification() async {
        let provider = MockServiceProvider()
        let store = OnboardingStore(provider: provider)
        let viewController = OnboardingPageViewController(pageType: .notification, store: store)
        
        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13),
            named: "OnboardingPage_Notification"
        )
    }
    
    @Test func onboardingPage_widget() async {
        let provider = MockServiceProvider()
        let store = OnboardingStore(provider: provider)
        let viewController = OnboardingPageViewController(pageType: .widget, store: store)
        
        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13),
            named: "OnboardingPage_Widget"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct ProfileSettingViewControllerSnapshotTests {
    
    @Test func profileSettingViewController_default() async {
        let provider = MockServiceProvider()
        let store = ProfileStore(provider: provider)
        let viewController = ProfileSettingViewController(store: store)
        
        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13),
            named: "ProfileSettingViewController_Default"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct NotificationSettingViewControllerSnapshotTests {
    
    @Test func notificationSettingViewController_default() async {
        let provider = MockServiceProvider()
        let store = NotificationStore(provider: provider)
        let viewController = NotificationSettingViewController(store: store)
        
        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13),
            named: "NotificationSettingViewController_Default"
        )
    }
}

@MainActor
@Suite(.snapshots(record: .missing))
struct WidgetGuideViewControllerSnapshotTests {
    
    @Test func widgetGuideViewController_default() async {
        let viewController = WidgetGuideViewController()
        
        assertSnapshot(
            of: viewController,
            as: .image(on: .iPhone13),
            named: "WidgetGuideViewController_Default"
        )
    }
}
