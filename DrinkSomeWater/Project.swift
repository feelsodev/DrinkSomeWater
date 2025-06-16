import ProjectDescription

let project = Project(
    name: "DrinkSomeWater",
    targets: [
        .target(
            name: "DrinkSomeWater",
            destinations: .iOS,
            product: .app,
            bundleId: "io.tuist.DrinkSomeWater",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["DrinkSomeWater/Sources/**"],
            resources: ["DrinkSomeWater/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "DrinkSomeWaterTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "io.tuist.DrinkSomeWaterTests",
            infoPlist: .default,
            sources: ["DrinkSomeWater/Tests/**"],
            resources: [],
            dependencies: [.target(name: "DrinkSomeWater")]
        ),
    ]
)
