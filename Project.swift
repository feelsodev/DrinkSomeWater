import ProjectDescription

let project = Project(
    name: "DrinkSomeWater",
    options: .options(
        defaultKnownRegions: ["en", "ko"],
        developmentRegion: "ko"
    ),
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "IPHONEOS_DEPLOYMENT_TARGET": "26.0",
            "TARGETED_DEVICE_FAMILY": "1,2",
            "DEVELOPMENT_TEAM": "TG4L9MF5FD",
            "CODE_SIGN_STYLE": "Automatic",
        ],
        configurations: [
            .debug(name: "Debug"),
            .release(name: "Release"),
        ]
    ),
    targets: [
        .target(
            name: "DrinkSomeWater",
            destinations: .iOS,
            product: .app,
            bundleId: "com.feelso.DrinkSomeWater",
            deploymentTargets: .iOS("26.0"),
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "$(PRODUCT_NAME)",
                "CFBundleShortVersionString": "2.0.0",
                "CFBundleVersion": "1",
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
            ]),
            sources: ["DrinkSomeWater/Sources/**"],
            resources: [
                "DrinkSomeWater/Resources/**",
                .glob(pattern: "DrinkSomeWater/Support/**", excluding: ["DrinkSomeWater/Support/Info.plist"])
            ],
            dependencies: [
                .external(name: "SnapKit"),
                .external(name: "Then"),
                .external(name: "FSCalendar"),
            ],
            settings: .settings(
                base: [
                    "OTHER_LDFLAGS": ["-ObjC"]
                ]
            )
        ),
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
