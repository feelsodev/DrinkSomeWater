import ProjectDescription

let project = Project(
    name: "DrinkSomeWater",
    options: .options(
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko"
    ),
    packages: [
        .remote(url: "https://github.com/firebase/firebase-ios-sdk.git", requirement: .upToNextMajor(from: "11.0.0")),
    ],
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "IPHONEOS_DEPLOYMENT_TARGET": "26.0",
            "TARGETED_DEVICE_FAMILY": "1,2",
            "DEVELOPMENT_TEAM": "TG4L9MF5FD",
            "CODE_SIGN_STYLE": "Automatic",
        ],
        configurations: [
            .debug(name: "Debug", xcconfig: "Tuist/Config/Debug.xcconfig"),
            .release(name: "Release", xcconfig: "Tuist/Config/Release.xcconfig"),
        ]
    ),
    targets: [
        // MARK: - Main App
        .target(
            name: "DrinkSomeWater",
            destinations: .iOS,
            product: .app,
            bundleId: "$(APP_BUNDLE_ID)",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "$(APP_NAME)",
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "UILaunchStoryboardName": "LaunchScreen",
                "UIMainStoryboardFile": "Main",
                "UISupportedInterfaceOrientations": [
                    "UIInterfaceOrientationPortrait"
                ],
                "UISupportedInterfaceOrientations~ipad": [
                    "UIInterfaceOrientationPortrait",
                    "UIInterfaceOrientationPortraitUpsideDown",
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight"
                ],
                "UIApplicationSceneManifest": [
                    "UIApplicationSupportsMultipleScenes": false,
                    "UISceneConfigurations": [
                        "UIWindowSceneSessionRoleApplication": [
                            [
                                "UISceneConfigurationName": "Default Configuration",
                                "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
                                "UISceneStoryboardFile": "Main"
                            ]
                        ]
                    ]
                ],
                "NSHealthShareUsageDescription": "체중 정보를 읽어 맞춤 권장량을 계산합니다.",
                "NSHealthUpdateUsageDescription": "물 섭취 기록을 건강 앱과 동기화합니다.",
                "GADApplicationIdentifier": "$(ADMOB_APP_ID)",
                "API_BASE_URL": "$(API_BASE_URL)",
                "ADMOB_APP_ID": "$(ADMOB_APP_ID)",
                "ADMOB_BANNER_ID": "$(ADMOB_BANNER_ID)",
                "ADMOB_REWARDED_ID": "$(ADMOB_REWARDED_ID)",
                "ADMOB_NATIVE_ID": "$(ADMOB_NATIVE_ID)",
                "LOG_LEVEL": "$(LOG_LEVEL)",
                "ENABLE_ANALYTICS": "$(ENABLE_ANALYTICS)",
                "ENABLE_DEBUG_MENU": "$(ENABLE_DEBUG_MENU)",
                "NSUserTrackingUsageDescription": "맞춤 광고를 제공하기 위해 사용됩니다.",
                "SKAdNetworkItems": [
                    ["SKAdNetworkIdentifier": "cstr6suwn9.skadnetwork"],
                    ["SKAdNetworkIdentifier": "4fzdc2evr5.skadnetwork"],
                    ["SKAdNetworkIdentifier": "4pfyvq9l8r.skadnetwork"],
                    ["SKAdNetworkIdentifier": "2fnua5tdw4.skadnetwork"],
                    ["SKAdNetworkIdentifier": "ydx93a7ass.skadnetwork"],
                    ["SKAdNetworkIdentifier": "5a6flpkh64.skadnetwork"],
                    ["SKAdNetworkIdentifier": "p78aez3dtr.skadnetwork"],
                    ["SKAdNetworkIdentifier": "v72qych5uu.skadnetwork"],
                    ["SKAdNetworkIdentifier": "ludvb6z3bs.skadnetwork"],
                    ["SKAdNetworkIdentifier": "cp8zw746q7.skadnetwork"],
                    ["SKAdNetworkIdentifier": "3sh42y64q3.skadnetwork"],
                    ["SKAdNetworkIdentifier": "c6k4g5qg8m.skadnetwork"],
                    ["SKAdNetworkIdentifier": "s39g8k73mm.skadnetwork"],
                    ["SKAdNetworkIdentifier": "3qy4746246.skadnetwork"],
                    ["SKAdNetworkIdentifier": "f38h382jlk.skadnetwork"],
                    ["SKAdNetworkIdentifier": "hs6bdukanm.skadnetwork"],
                    ["SKAdNetworkIdentifier": "v4nxqhlyqp.skadnetwork"],
                    ["SKAdNetworkIdentifier": "wzmmz9fp6w.skadnetwork"],
                    ["SKAdNetworkIdentifier": "yclnxrl5pm.skadnetwork"],
                    ["SKAdNetworkIdentifier": "t38b2kh725.skadnetwork"],
                    ["SKAdNetworkIdentifier": "7ug5zh24hu.skadnetwork"],
                    ["SKAdNetworkIdentifier": "gta9lk7p23.skadnetwork"],
                    ["SKAdNetworkIdentifier": "vutu7akeur.skadnetwork"],
                    ["SKAdNetworkIdentifier": "y5ghdn5j9k.skadnetwork"],
                    ["SKAdNetworkIdentifier": "n6fk4nfna4.skadnetwork"],
                    ["SKAdNetworkIdentifier": "v9wttpbfk9.skadnetwork"],
                    ["SKAdNetworkIdentifier": "n38lu8286q.skadnetwork"],
                    ["SKAdNetworkIdentifier": "47vhws6wlr.skadnetwork"],
                    ["SKAdNetworkIdentifier": "kbd757ywx3.skadnetwork"],
                    ["SKAdNetworkIdentifier": "9t245vhmpl.skadnetwork"],
                    ["SKAdNetworkIdentifier": "a2p9lx4jpn.skadnetwork"],
                    ["SKAdNetworkIdentifier": "22mmun2rn5.skadnetwork"],
                    ["SKAdNetworkIdentifier": "4468km3ulz.skadnetwork"],
                    ["SKAdNetworkIdentifier": "2u9pt9hc89.skadnetwork"],
                    ["SKAdNetworkIdentifier": "8s468mfl3y.skadnetwork"],
                    ["SKAdNetworkIdentifier": "klf5c3l5u5.skadnetwork"],
                    ["SKAdNetworkIdentifier": "ppxm28t8ap.skadnetwork"],
                    ["SKAdNetworkIdentifier": "ecpz2srf59.skadnetwork"],
                    ["SKAdNetworkIdentifier": "uw77j35x4d.skadnetwork"],
                    ["SKAdNetworkIdentifier": "pwa73g5rt2.skadnetwork"],
                    ["SKAdNetworkIdentifier": "mlmmfzh3r3.skadnetwork"],
                    ["SKAdNetworkIdentifier": "578prtvx9j.skadnetwork"],
                    ["SKAdNetworkIdentifier": "4dzt52r2t5.skadnetwork"],
                    ["SKAdNetworkIdentifier": "e5fvkxwrpn.skadnetwork"],
                    ["SKAdNetworkIdentifier": "8c4e2ghe7u.skadnetwork"],
                    ["SKAdNetworkIdentifier": "zq492l623r.skadnetwork"],
                    ["SKAdNetworkIdentifier": "3rd42ekr43.skadnetwork"],
                    ["SKAdNetworkIdentifier": "3qcr597p9d.skadnetwork"],
                ],
            ]),
            sources: [
                "DrinkSomeWater/Sources/**",
                "Shared/**",
            ],
            resources: [
                "DrinkSomeWater/Resources/**",
                .glob(pattern: "DrinkSomeWater/Support/**", excluding: ["DrinkSomeWater/Support/Info.plist", "DrinkSomeWater/Support/DrinkSomeWater.entitlements"])
            ],
            entitlements: "DrinkSomeWater/Support/DrinkSomeWater.entitlements",
            dependencies: [
                .target(name: "DrinkSomeWaterWidget"),
                .target(name: "Analytics"),
                .external(name: "SnapKit"),
                .external(name: "FSCalendar"),
                .external(name: "GoogleMobileAds"),
                .package(product: "FirebaseRemoteConfig"),
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": ["-ObjC"]
                ]
            )
        ),
        // MARK: - Widget Extension
        .target(
            name: "DrinkSomeWaterWidget",
            destinations: .iOS,
            product: .appExtension,
            bundleId: "$(APP_BUNDLE_ID).Widget",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "벌컥벌컥 위젯",
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "NSExtension": [
                    "NSExtensionPointIdentifier": "com.apple.widgetkit-extension"
                ]
            ]),
            sources: [
                "DrinkSomeWaterWidget/**",
                "Shared/**",
            ],
            entitlements: "DrinkSomeWaterWidget/DrinkSomeWaterWidget.entitlements",
            dependencies: []
        ),
        // MARK: - Watch App
        .target(
            name: "DrinkSomeWaterWatch",
            destinations: [.appleWatch],
            product: .app,
            bundleId: "$(APP_BUNDLE_ID).watchkitapp",
            deploymentTargets: .watchOS("11.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "$(APP_NAME)",
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "WKApplication": true,
                "WKCompanionAppBundleIdentifier": "$(APP_BUNDLE_ID)",
            ]),
            sources: ["DrinkSomeWaterWatch/Sources/**"],
            resources: ["DrinkSomeWaterWatch/Resources/**"],
            entitlements: "DrinkSomeWaterWatch/DrinkSomeWaterWatch.entitlements",
            dependencies: []
        ),
        // MARK: - Analytics Module
        .target(
            name: "Analytics",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.onceagain.DrinkSomeWater.Analytics",
            deploymentTargets: .iOS("26.0"),
            sources: ["Analytics/Sources/**"],
            dependencies: [
                .package(product: "FirebaseAnalytics"),
                .package(product: "FirebaseCrashlytics"),
            ]
        ),
        // MARK: - Unit Tests
        .target(
            name: "DrinkSomeWaterTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.feelso.DrinkSomeWaterTests",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .default,
            sources: ["DrinkSomeWaterTests/**"],
            dependencies: [
                .target(name: "DrinkSomeWater")
            ]
        ),
    ]
)
