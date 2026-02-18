// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Pillarbox",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "PillarboxAnalytics",
            targets: ["PillarboxAnalytics"]
        ),
        .library(
            name: "PillarboxCircumspect",
            targets: ["PillarboxCircumspect"]
        ),
        .library(
            name: "PillarboxCore",
            targets: ["PillarboxCore"]
        ),
        .library(
            name: "PillarboxCoreBusiness",
            targets: ["PillarboxCoreBusiness"]
        ),
        .library(
            name: "PillarboxPlayer",
            targets: ["PillarboxPlayer"]
        ),
        .library(
            name: "PillarboxMonitoring",
            targets: ["PillarboxMonitoring"]
        ),
        .library(
            name: "PillarboxStandardConnector",
            targets: ["PillarboxStandardConnector"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/comScore/Comscore-Swift-Package-Manager.git", .upToNextMinor(from: "6.16.0")),
        .package(url: "https://github.com/CommandersAct/iOSV5.git", exact: "5.4.18"),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/krzysztofzablocki/Difference.git", exact: "1.0.1"),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "13.0.0"))
    ],
    targets: [
        .target(
            name: "PillarboxAnalytics",
            dependencies: [
                .target(name: "PillarboxPlayer"),
                .product(name: "ComScore", package: "Comscore-Swift-Package-Manager"),
                .product(name: "TCCore", package: "iOSV5"),
                .product(name: "TCServerSide", package: "iOSV5")
            ],
            path: "Sources/Analytics",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("AdSupport")
            ],
            plugins: [
                .plugin(name: "PillarboxPackageInfoPlugin")
            ]
        ),
        .target(
            name: "PillarboxCore",
            dependencies: [
                .product(name: "DequeModule", package: "swift-collections")
            ],
            path: "Sources/Core"
        ),
        .target(
            name: "PillarboxCoreBusiness",
            dependencies: [
                .target(name: "PillarboxAnalytics"),
                .target(name: "PillarboxMonitoring"),
                .target(name: "PillarboxStandardConnector")
            ],
            path: "Sources/CoreBusiness",
            resources: [
                .process("Resources")
            ],
            plugins: [
                .plugin(name: "PillarboxPackageInfoPlugin")
            ]
        ),
        .target(
            name: "PillarboxMonitoring",
            dependencies: [
                .target(name: "PillarboxPlayer")
            ],
            path: "Sources/Monitoring",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "PillarboxCircumspect",
            dependencies: [
                .product(name: "Difference", package: "Difference"),
                .product(name: "Nimble", package: "Nimble")
            ],
            path: "Sources/Circumspect"
        ),
        .target(
            name: "PillarboxPlayer",
            dependencies: [
                .target(name: "PillarboxCore"),
                .product(name: "DequeModule", package: "swift-collections"),
                .product(name: "OrderedCollections", package: "swift-collections")
            ],
            path: "Sources/Player",
            resources: [
                .process("Resources")
            ],
            plugins: [
                .plugin(name: "PillarboxPackageInfoPlugin")
            ]
        ),
        .target(
            name: "PillarboxStandardConnector",
            dependencies: [
                .target(name: "PillarboxPlayer")
            ],
            path: "Sources/StandardConnector",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "PillarboxStreams",
            path: "Sources/Streams",
            resources: [
                .process("Resources")
            ]
        ),
        .binaryTarget(name: "PillarboxPackageInfo", path: "Artifacts/PackageInfo.artifactbundle"),
        .plugin(
            name: "PillarboxPackageInfoPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "PillarboxPackageInfo")
            ]
        ),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: [
                .target(name: "PillarboxAnalytics"),
                .target(name: "PillarboxCircumspect"),
                .target(name: "PillarboxStreams")
            ]
        ),
        .testTarget(
            name: "CircumspectTests",
            dependencies: [
                .target(name: "PillarboxCircumspect")
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                .target(name: "PillarboxCircumspect"),
                .target(name: "PillarboxCore")
            ]
        ),
        .testTarget(
            name: "CoreBusinessTests",
            dependencies: [
                .target(name: "PillarboxCircumspect"),
                .target(name: "PillarboxCoreBusiness")
            ]
        ),
        .testTarget(
            name: "MonitoringTests",
            dependencies: [
                .target(name: "PillarboxCircumspect"),
                .target(name: "PillarboxMonitoring"),
                .target(name: "PillarboxStreams")
            ]
        ),
        .testTarget(
            name: "PlayerTests",
            dependencies: [
                .target(name: "PillarboxCircumspect"),
                .target(name: "PillarboxPlayer"),
                .target(name: "PillarboxStreams")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "StandardConnectorTests",
            dependencies: [
                .target(name: "PillarboxCircumspect"),
                .target(name: "PillarboxStandardConnector")
            ]
        )
    ],
    swiftLanguageModes: [.v5]
)
