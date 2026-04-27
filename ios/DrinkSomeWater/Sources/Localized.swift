// Localized.swift
// DrinkSomeWater
//
// Type-safe localization namespace to prevent key typos.
// Usage: L.Home.goalAchieved, L.Settings.title, etc.

import Foundation

// swiftlint:disable type_name
enum L {

    // MARK: - Main (legacy keys)
    enum Main {
        static let youAchieved = String(localized: "You achieved ")
        static let todaySuffix = String(localized: "TodaySuffix")
    }

    // MARK: - Calendar
    enum Calendar {
        static let today = String(localized: "Today")
        static let success = String(localized: "Success")
        static let selected = String(localized: "Selected")
        static let historyHint = String(localized: "You can check the history when you select a success date.")
        static let goalOfThisMonth = String(localized: "Goal of this month")
        static let dateFormat = String(localized: "MMMM, YYYY")
    }

    // MARK: - Information (legacy keys)
    enum Info {
        static let alarm = String(localized: "Alarm")
        static let review = String(localized: "Review")
        static let contactUs = String(localized: "Contact Us")
        static let version = String(localized: "Version")
        static let license = String(localized: "License")
        static let set = String(localized: "Set")
    }

    // MARK: - Common
    enum Common {
        static let confirm = String(localized: "common.confirm")
        static let cancel = String(localized: "common.cancel")
        static let save = String(localized: "common.save")
        static let delete = String(localized: "common.delete")
        static let done = String(localized: "common.done")
    }

    // MARK: - Tab Bar
    enum Tab {
        static let today = String(localized: "tab.today")
        static let history = String(localized: "tab.history")
        static let settings = String(localized: "tab.settings")
    }

    // MARK: - Home
    enum Home {
        static func goal(_ amount: String) -> String {
            String(format: String(localized: "home.goal"), amount)
        }
        static let goalAchieved = String(localized: "home.goal.achieved")
        static func goalRemaining(_ cups: String) -> String {
            String(format: String(localized: "home.goal.remaining"), cups)
        }
        static let quickAdd = String(localized: "home.quick.add")
        static let quickSubtract = String(localized: "home.quick.subtract")
        static let edit = String(localized: "home.edit")
        static let goalSettingTitle = String(localized: "home.goal.setting.title")
        static let goalSave = String(localized: "home.goal.save")
        static let goalMin = String(localized: "home.goal.min")
        static let goalMax = String(localized: "home.goal.max")
        static let goalCancel = String(localized: "home.goal.cancel")
        static let quickButtonTitle = String(localized: "home.quickbutton.title")
        static let quickButtonCurrent = String(localized: "home.quickbutton.current")
        static let quickButtonAddSection = String(localized: "home.quickbutton.add.section")
        static let quickButtonPlaceholder = String(localized: "home.quickbutton.placeholder")
        static let quickButtonAdd = String(localized: "home.quickbutton.add")
        static let quickButtonReset = String(localized: "home.quickbutton.reset")
        static let adjustmentTitle = String(localized: "home.adjustment.title")
        static let adjustmentDone = String(localized: "home.adjustment.done")
        static let adjustmentReset = String(localized: "home.adjustment.reset")
        static let adjustmentResetConfirm = String(localized: "home.adjustment.reset.confirm")
        static let adjustmentResetButton = String(localized: "home.adjustment.reset.button")
        static let adjustmentResetMessage = String(localized: "home.adjustment.reset.message")
        // Notification Banner
        static let notificationBannerTitle = String(localized: "home.notification.banner.title")
        static let notificationBannerDescription = String(localized: "home.notification.banner.description")
        static let notificationBannerSettings = String(localized: "home.notification.banner.settings")
    }

    // MARK: - History
    enum History {
        static let title = String(localized: "history.title")
        static let modeCalendar = String(localized: "history.mode.calendar")
        static let modeList = String(localized: "history.mode.list")
        static let modeTimeline = String(localized: "history.mode.timeline")
        static func monthSummary(_ count: String) -> String {
            String(format: String(localized: "history.month.summary"), count)
        }
        static let legendToday = String(localized: "history.legend.today")
        static let legendSelected = String(localized: "history.legend.selected")
        static let legendAchieved = String(localized: "history.legend.achieved")
        static func recordProgress(_ current: String, _ goal: String) -> String {
            String(format: String(localized: "history.record.progress"), current, goal)
        }
        static func timelineAchieved(_ success: String, _ total: String) -> String {
            String(format: String(localized: "history.timeline.achieved"), success, total)
        }
        static func recordGoal(_ amount: String) -> String {
            String(format: String(localized: "history.record.goal"), amount)
        }
        static let cardGoal = String(localized: "history.card.goal")
        static let cardIntake = String(localized: "history.card.intake")
        static let cardAchieved = String(localized: "history.card.achieved")
        static let labelAchieved = String(localized: "history.label.achieved")
    }

    // MARK: - Settings
    enum Settings {
        static let title = String(localized: "settings.title")
        static let subtitle = String(localized: "settings.subtitle")
        static let sectionPersonal = String(localized: "settings.section.personal")
        static let sectionApp = String(localized: "settings.section.app")
        static let sectionSupport = String(localized: "settings.section.support")
        static let sectionInfo = String(localized: "settings.section.info")
        static let profile = String(localized: "settings.profile")
        static let goal = String(localized: "settings.goal")
        static let quickButtons = String(localized: "settings.quickbuttons")
        static let notification = String(localized: "settings.notification")
        static let widgetGuide = String(localized: "settings.widget.guide")
        static let review = String(localized: "settings.review")
        static let contact = String(localized: "settings.contact")
        static let version = String(localized: "settings.version")
        static let appGuide = String(localized: "settings.app.guide")
        static let supportDeveloper = String(localized: "settings.support.developer")
        // iCloud
        static let icloudStatus = String(localized: "settings.icloud.status")
        static let icloudConnected = String(localized: "settings.icloud.connected")
        static let icloudDisconnected = String(localized: "settings.icloud.disconnected")
        static let icloudInfoConnectedTitle = String(localized: "settings.icloud.info.connected.title")
        static let icloudInfoConnectedMessage = String(localized: "settings.icloud.info.connected.message")
        static let icloudInfoDisconnectedTitle = String(localized: "settings.icloud.info.disconnected.title")
        static let icloudInfoDisconnectedMessage = String(localized: "settings.icloud.info.disconnected.message")
        // Premium
        static let premium = String(localized: "settings.premium")
        static let subscriptionStatusPremium = String(localized: "settings.subscription.status.premium")
        static let manageSubscription = String(localized: "settings.manage.subscription")
        static let upgradePremium = String(localized: "settings.upgrade.premium")
        // Subscription Status
        static let subscriptionFree = String(localized: "settings.subscription.free")
        static let subscriptionSubscribed = String(localized: "settings.subscription.subscribed")
        static let subscriptionLifetime = String(localized: "settings.subscription.lifetime")
        static let subscriptionSubscribe = String(localized: "settings.subscription.subscribe")
        static let subscriptionManage = String(localized: "settings.subscription.manage")
    }

    // MARK: - Profile
    enum Profile {
        static let title = String(localized: "profile.title")
        static let healthKitTitle = String(localized: "profile.healthkit.title")
        static let healthKitDescription = String(localized: "profile.healthkit.description")
        static let weight = String(localized: "profile.weight")
        static let weightRange = String(localized: "profile.weight.range")
        static let recommendedTitle = String(localized: "profile.recommended.title")
        static let recommendedDescription = String(localized: "profile.recommended.description")
        static let applyButton = String(localized: "profile.apply.button")
        static let applySuccessTitle = String(localized: "profile.apply.success.title")
        static func applySuccessMessage(_ amount: String) -> String {
            String(format: String(localized: "profile.apply.success.message"), amount)
        }
    }

    // MARK: - Notification
    enum Notification {
        static let enable = String(localized: "notification.enable")
        static let timeStart = String(localized: "notification.time.start")
        static let timeEnd = String(localized: "notification.time.end")
        static let interval = String(localized: "notification.interval")
        static let weekdays = String(localized: "notification.weekdays")
        static let customTimes = String(localized: "notification.custom.times")
        static let customAdd = String(localized: "notification.custom.add")
        static let messageInfo = String(localized: "notification.message.info")
        // Notification Title
        static let title = String(localized: "notification.title")
    }

    // MARK: - Notification Settings
    enum NotificationSettings {
        static let title = String(localized: "notification.settings.title")
        static let enable = String(localized: "notification.settings.enable")
        static let timeRange = String(localized: "notification.settings.timerange")
        static let interval = String(localized: "notification.settings.interval")
        static let weekdays = String(localized: "notification.settings.weekdays")
        static let custom = String(localized: "notification.settings.custom")
        static let startTime = String(localized: "notification.settings.starttime")
        static let endTime = String(localized: "notification.settings.endtime")
        static let addTime = String(localized: "notification.settings.addtime")
    }

    // MARK: - Notification Messages
    enum NotificationMessage {
        static let message1 = String(localized: "notification.message.1")
        static let message2 = String(localized: "notification.message.2")
        static let message3 = String(localized: "notification.message.3")
        static let message4 = String(localized: "notification.message.4")
        static let message5 = String(localized: "notification.message.5")
        static let message6 = String(localized: "notification.message.6")
        static let message7 = String(localized: "notification.message.7")
        static let message8 = String(localized: "notification.message.8")
        static let message9 = String(localized: "notification.message.9")
        static let message10 = String(localized: "notification.message.10")
        static let message11 = String(localized: "notification.message.11")
        static let message12 = String(localized: "notification.message.12")
        static let message13 = String(localized: "notification.message.13")
        static let message14 = String(localized: "notification.message.14")
        static let message15 = String(localized: "notification.message.15")
        static let message16 = String(localized: "notification.message.16")
        static let message17 = String(localized: "notification.message.17")
        static let message18 = String(localized: "notification.message.18")
        static let message19 = String(localized: "notification.message.19")
        static let message20 = String(localized: "notification.message.20")
    }

    // MARK: - Contact
    enum Contact {
        static let title = String(localized: "contact.title")
        static let message = String(localized: "contact.message")
    }

    // MARK: - Ad
    enum Ad {
        static let confirmTitle = String(localized: "ad.confirm.title")
        static let confirmMessage = String(localized: "ad.confirm.message")
        static let loadingTitle = String(localized: "ad.loading.title")
        static let loadingMessage = String(localized: "ad.loading.message")
        static let thanksTitle = String(localized: "ad.thanks.title")
        static let thanksMessage = String(localized: "ad.thanks.message")
    }

    // MARK: - Onboarding
    enum Onboarding {
        static let skip = String(localized: "onboarding.skip")
        static let next = String(localized: "onboarding.next")
        static let start = String(localized: "onboarding.start")
        static let introTitle = String(localized: "onboarding.intro.title")
        static let introDescription = String(localized: "onboarding.intro.description")
        static let goalTitle = String(localized: "onboarding.goal.title")
        static let goalDescription = String(localized: "onboarding.goal.description")
        static let healthKitTitle = String(localized: "onboarding.healthkit.title")
        static let healthKitDescription = String(localized: "onboarding.healthkit.description")
        static let healthKitButton = String(localized: "onboarding.healthkit.button")
        static let healthKitConnected = String(localized: "onboarding.healthkit.connected")
        static let notificationTitle = String(localized: "onboarding.notification.title")
        static let notificationDescription = String(localized: "onboarding.notification.description")
        static let notificationButton = String(localized: "onboarding.notification.button")
        static let notificationEnabled = String(localized: "onboarding.notification.enabled")
        static let widgetTitle = String(localized: "onboarding.widget.title")
        static let widgetDescription = String(localized: "onboarding.widget.description")
        static let widgetButton = String(localized: "onboarding.widget.button")
    }

    // MARK: - Widget
    enum Widget {
        static let today = String(localized: "widget.today")
        static let guideTitle = String(localized: "widget.guide.title")
        static let guideNavTitle = String(localized: "widget.guide.nav.title")
        // Home Screen Steps
        static let guideStep1Title = String(localized: "widget.guide.step1.title")
        static let guideStep1Description = String(localized: "widget.guide.step1.description")
        static let guideStep2Title = String(localized: "widget.guide.step2.title")
        static let guideStep2Description = String(localized: "widget.guide.step2.description")
        static let guideStep3Title = String(localized: "widget.guide.step3.title")
        static let guideStep3Description = String(localized: "widget.guide.step3.description")
        static let guideStep4Title = String(localized: "widget.guide.step4.title")
        static let guideStep4Description = String(localized: "widget.guide.step4.description")
        static let guideStep5Title = String(localized: "widget.guide.step5.title")
        static let guideStep5Description = String(localized: "widget.guide.step5.description")
        // Lock Screen
        static let guideLockScreenHeader = String(localized: "widget.guide.lockscreen.header")
        static let guideLockScreenStep1Title = String(localized: "widget.guide.lockscreen.step1.title")
        static let guideLockScreenStep1Description = String(localized: "widget.guide.lockscreen.step1.description")
        static let guideLockScreenStep2Title = String(localized: "widget.guide.lockscreen.step2.title")
        static let guideLockScreenStep2Description = String(localized: "widget.guide.lockscreen.step2.description")
        static let guideLockScreenStep3Title = String(localized: "widget.guide.lockscreen.step3.title")
        static let guideLockScreenStep3Description = String(localized: "widget.guide.lockscreen.step3.description")
        // Widget display
        static let hydrationTracker = String(localized: "widget.hydration.tracker")
        static let current = String(localized: "widget.current")
        static let goal = String(localized: "widget.goal")
        static let currentHydration = String(localized: "widget.current.hydration")
        static let todaysHydration = String(localized: "widget.todays.hydration")
        static let motivationAchieved = String(localized: "widget.motivation.achieved")
        static let motivationAlmost = String(localized: "widget.motivation.almost")
        static let motivationHalfway = String(localized: "widget.motivation.halfway")
        static let motivationStart = String(localized: "widget.motivation.start")
        // Locked State
        static let lockedTitle = String(localized: "widget.locked.title")
        static let lockedSubtitle = String(localized: "widget.locked.subtitle")
        static let lockedCta = String(localized: "widget.locked.cta")
    }

    // MARK: - Watch
    enum Watch {
        static let addWater = String(localized: "watch.add.water")
        static let customInput = String(localized: "watch.custom.input")
        static let add = String(localized: "watch.add")
        static let lockedTitle = String(localized: "watch.locked.title")
        static let lockedSubtitle = String(localized: "watch.locked.subtitle")
    }

    // MARK: - Update
    enum Update {
        static let requiredTitle = String(localized: "update.required.title")
        static let availableTitle = String(localized: "update.available.title")
        static let requiredMessage = String(localized: "update.required.message")
        static let availableMessage = String(localized: "update.available.message")
        static let later = String(localized: "update.later")
        static let now = String(localized: "update.now")
    }

    // MARK: - Weekday
    enum Weekday {
        static let sun = String(localized: "weekday.sun")
        static let mon = String(localized: "weekday.mon")
        static let tue = String(localized: "weekday.tue")
        static let wed = String(localized: "weekday.wed")
        static let thu = String(localized: "weekday.thu")
        static let fri = String(localized: "weekday.fri")
        static let sat = String(localized: "weekday.sat")
    }

    // MARK: - Interval
    enum Interval {
        static let thirtyMin = String(localized: "interval.30min")
        static let oneHour = String(localized: "interval.1hour")
        static let twoHours = String(localized: "interval.2hours")
        static let threeHours = String(localized: "interval.3hours")
    }

    // MARK: - Date Format
    enum DateFormat {
        static let month = String(localized: "dateformat.month")
        static let yearMonth = String(localized: "dateformat.yearmonth")
        static let monthDay = String(localized: "dateformat.monthday")
    }

    // MARK: - Watch Complication
    enum Complication {
        static let displayName = String(localized: "complication.displayname")
        static let description = String(localized: "complication.description")
    }

    // MARK: - Accessibility
    enum Accessibility {
        static func homeCurrent(_ ml: Int) -> String {
            String(localized: "accessibility.home.current", defaultValue: "Current intake \(ml) milliliters")
        }
        static func homeGoal(_ ml: Int) -> String {
            String(localized: "accessibility.home.goal", defaultValue: "Daily goal \(ml) milliliters")
        }
        static let homeGoalHint = String(localized: "accessibility.home.goal.hint")
        static func homeAdd(_ ml: Int) -> String {
            String(localized: "accessibility.home.add", defaultValue: "Add \(ml) milliliters")
        }
        static let homeAddHint = String(localized: "accessibility.home.add.hint")
        static func homeSubtract(_ ml: Int) -> String {
            String(localized: "accessibility.home.subtract", defaultValue: "Subtract \(ml) milliliters")
        }
        static let homeSubtractHint = String(localized: "accessibility.home.subtract.hint")
        static let homeModeAdd = String(localized: "accessibility.home.mode.add")
        static let homeModeSubtract = String(localized: "accessibility.home.mode.subtract")
        static let homeModeHint = String(localized: "accessibility.home.mode.hint")
        static func historySummary(_ days: Int) -> String {
            String(localized: "accessibility.history.summary", defaultValue: "This month \(days) days achieved")
        }
        static let historyAchieved = String(localized: "accessibility.history.achieved")
        static func historyProgress(_ percentage: String) -> String {
            String(localized: "accessibility.history.progress", defaultValue: "\(percentage) of goal")
        }
        static let homeShare = String(localized: "accessibility.home.share")
        static let historyShare = String(localized: "accessibility.history.share")
        static let statisticsButton = String(localized: "accessibility.statistics.button")
    }

    // MARK: - iCloud
    enum ICloud {
        static let errorQuotaTitle = String(localized: "icloud.error.quota.title")
        static let errorQuotaMessage = String(localized: "icloud.error.quota.message")
        static let errorAccountTitle = String(localized: "icloud.error.account.title")
        static let errorAccountMessage = String(localized: "icloud.error.account.message")
    }

    // MARK: - Share
    enum Share {
        static let title = String(localized: "share.title")
        static let instagramStories = String(localized: "share.instagram.stories")
        static let instagramFeed = String(localized: "share.instagram.feed")
        static let errorTitle = String(localized: "share.error.title")
        static let errorOk = String(localized: "share.error.ok")
        static let errorInstagramNotInstalled = String(localized: "share.error.instagram.not.installed")
        static let titleExtended = String(localized: "share.title.extended")
        static let system = String(localized: "share.system")
        static let systemDescription = String(localized: "share.system.description")
        // Share Card
        static func streakDays(_ count: Int) -> String {
            String(localized: "share.streak.days \(count)")
        }
        static let consecutiveAchievement = String(localized: "share.consecutive.achievement")
        static let appName = String(localized: "share.app.name")
    }

    // MARK: - Statistics
    enum Statistics {
        static let title = String(localized: "statistics.title")
        static let periodWeek = String(localized: "statistics.period.week")
        static let periodMonth = String(localized: "statistics.period.month")
        static let dailyAverage = String(localized: "statistics.daily.average")
        static let goalAchievement = String(localized: "statistics.goal.achievement")
        static let currentStreak = String(localized: "statistics.current.streak")
        static let longestStreak = String(localized: "statistics.longest.streak")
        static let days = String(localized: "statistics.days")
        static let chartTitle = String(localized: "statistics.chart.title")
        static let chartGoalLine = String(localized: "statistics.chart.goal.line")
        static let empty = String(localized: "statistics.empty")
        // Statistics (new keys)
        static let period7days = String(localized: "statistics.period.7days")
        static let period30days = String(localized: "statistics.period.30days")
        static let period = String(localized: "statistics.period")
        static let unitMl = String(localized: "statistics.unit.ml")
    }

    // MARK: - App Guide
    enum AppGuide {
        static let title = String(localized: "appguide.title")
        static let subtitle = String(localized: "appguide.subtitle")
        // Home
        static let homeTitle = String(localized: "appguide.home.title")
        static let homeFeature1Title = String(localized: "appguide.home.feature1.title")
        static let homeFeature1Desc = String(localized: "appguide.home.feature1.desc")
        static let homeFeature2Title = String(localized: "appguide.home.feature2.title")
        static let homeFeature2Desc = String(localized: "appguide.home.feature2.desc")
        static let homeFeature3Title = String(localized: "appguide.home.feature3.title")
        static let homeFeature3Desc = String(localized: "appguide.home.feature3.desc")
        static let homeFeature4Title = String(localized: "appguide.home.feature4.title")
        static let homeFeature4Desc = String(localized: "appguide.home.feature4.desc")
        // History
        static let historyTitle = String(localized: "appguide.history.title")
        static let historyFeature1Title = String(localized: "appguide.history.feature1.title")
        static let historyFeature1Desc = String(localized: "appguide.history.feature1.desc")
        static let historyFeature2Title = String(localized: "appguide.history.feature2.title")
        static let historyFeature2Desc = String(localized: "appguide.history.feature2.desc")
        static let historyFeature3Title = String(localized: "appguide.history.feature3.title")
        static let historyFeature3Desc = String(localized: "appguide.history.feature3.desc")
        // Watch
        static let watchTitle = String(localized: "appguide.watch.title")
        static let watchFeature1Title = String(localized: "appguide.watch.feature1.title")
        static let watchFeature1Desc = String(localized: "appguide.watch.feature1.desc")
        static let watchFeature2Title = String(localized: "appguide.watch.feature2.title")
        static let watchFeature2Desc = String(localized: "appguide.watch.feature2.desc")
        static let watchFeature3Title = String(localized: "appguide.watch.feature3.title")
        static let watchFeature3Desc = String(localized: "appguide.watch.feature3.desc")
        // Widget
        static let widgetTitle = String(localized: "appguide.widget.title")
        static let widgetFeature1Title = String(localized: "appguide.widget.feature1.title")
        static let widgetFeature1Desc = String(localized: "appguide.widget.feature1.desc")
        static let widgetFeature2Title = String(localized: "appguide.widget.feature2.title")
        static let widgetFeature2Desc = String(localized: "appguide.widget.feature2.desc")
        static let widgetFeature3Title = String(localized: "appguide.widget.feature3.title")
        static let widgetFeature3Desc = String(localized: "appguide.widget.feature3.desc")
        // Notification
        static let notificationTitle = String(localized: "appguide.notification.title")
        static let notificationFeature1Title = String(localized: "appguide.notification.feature1.title")
        static let notificationFeature1Desc = String(localized: "appguide.notification.feature1.desc")
        static let notificationFeature2Title = String(localized: "appguide.notification.feature2.title")
        static let notificationFeature2Desc = String(localized: "appguide.notification.feature2.desc")
        static let notificationFeature3Title = String(localized: "appguide.notification.feature3.title")
        static let notificationFeature3Desc = String(localized: "appguide.notification.feature3.desc")
        // Health
        static let healthTitle = String(localized: "appguide.health.title")
        static let healthFeature1Title = String(localized: "appguide.health.feature1.title")
        static let healthFeature1Desc = String(localized: "appguide.health.feature1.desc")
        static let healthFeature2Title = String(localized: "appguide.health.feature2.title")
        static let healthFeature2Desc = String(localized: "appguide.health.feature2.desc")
    }

    // MARK: - Paywall
    enum Paywall {
        static let loading = String(localized: "paywall.loading")
        static let title = String(localized: "paywall.title")
        static let subtitle = String(localized: "paywall.subtitle")
        static let adFree = String(localized: "paywall.ad.free")
        static let subscriptionDescription = String(localized: "paywall.subscription.description")
        static let or = String(localized: "paywall.or")
        static let lifetime = String(localized: "paywall.lifetime")
        static let lifetimeDescription = String(localized: "paywall.lifetime.description")
        static let restore = String(localized: "paywall.restore")
        // Feature Comparison
        static let featureFree = String(localized: "paywall.feature.free")
        static let featureSubscribed = String(localized: "paywall.feature.subscribed")
        static let featureAds = String(localized: "paywall.feature.ads")
        static let featureNoAds = String(localized: "paywall.feature.noAds")
        static let featureNoWidget = String(localized: "paywall.feature.noWidget")
        static let featureWidget = String(localized: "paywall.feature.widget")
        static let featureNoWatch = String(localized: "paywall.feature.noWatch")
        static let featureWatch = String(localized: "paywall.feature.watch")
    }

    // MARK: - Ad Gate
    enum AdGate {
        static let title = String(localized: "adGate.title")
        static let subtitle = String(localized: "adGate.subtitle")
    }

    // MARK: - Errors
    enum Error {
        static let imageGenerationFailed = String(localized: "error.image.generation.failed")
        static let shareSheetUnavailable = String(localized: "error.share.sheet.unavailable")
        static let instagramNotInstalled = String(localized: "error.instagram.not.installed")
        static let photoLibraryPermission = String(localized: "error.photo.library.permission")
        static let photoSaveFailed = String(localized: "error.photo.save.failed")
        static let instagramCannotOpen = String(localized: "error.instagram.cannot.open")
        static let productNotFound = String(localized: "error.product.not.found")
        static let purchaseFailed = String(localized: "error.purchase.failed")
        static let purchaseCancelled = String(localized: "error.purchase.cancelled")
        static let purchasePending = String(localized: "error.purchase.pending")
        static let verificationFailed = String(localized: "error.verification.failed")
        static let unknown = String(localized: "error.unknown")
    }
}
// swiftlint:enable type_name
