import UIKit

// Detect if running in test environment
let isRunningTests = NSClassFromString("XCTestCase") != nil

// Use TestAppDelegate in test environment to prevent CI crashes from
// initializing Firebase, AdMob, WatchConnectivity, and other frameworks
let appDelegateClass: AnyClass = isRunningTests
    ? TestAppDelegate.self
    : AppDelegate.self

UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    NSStringFromClass(appDelegateClass)
)
