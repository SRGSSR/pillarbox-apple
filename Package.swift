// swift-tools-version: 5.9
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
        )
    ],
    dependencies: [
        .package(url: "https://github.com/comScore/Comscore-Swift-Package-Manager.git", .upToNextMinor(from: "6.12.0")),
        .package(url: "https://github.com/CommandersAct/iOSV5.git", .upToNextMinor(from: "5.4.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/krzysztofzablocki/Difference.git", exact: "1.0.1"),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "13.0.0")),
        .package(url: "https://github.com/icanzilb/TimelaneCombine.git", .upToNextMajor(from: "2.0.0"))
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
                .plugin(name: "PackageInfoPlugin")
            ]
        ),
        .target(
            name: "PillarboxCore",
            dependencies: [
                .product(name: "DequeModule", package: "swift-collections"),
                .product(name: "OrderedCollections", package: "swift-collections")
            ],
            path: "Sources/Core"
        ),
        .target(
            name: "PillarboxCoreBusiness",
            dependencies: [
                .target(name: "PillarboxAnalytics")
            ],
            path: "Sources/CoreBusiness",
            resources: [
                .process("Resources")
            ],
            plugins: [
                .plugin(name: "PackageInfoPlugin")
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
                .product(name: "TimelaneCombine", package: "TimelaneCombine")
            ],
            path: "Sources/Player",
            resources: [
                .process("Resources")
            ],
            plugins: [
                .plugin(name: "PackageInfoPlugin")
            ]
        ),
        .target(
            name: "PillarboxStreams",
            path: "Sources/Streams",
            resources: [
                .process("Resources")
            ]
        ),
        .binaryTarget(name: "PackageInfo", path: "Artifacts/PackageInfo.artifactbundle"),
        .plugin(
            name: "PackageInfoPlugin",
            capability: .buildTool(),
            dependencies: [
                .target(name: "PackageInfo")
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
            name: "PlayerTests",
            dependencies: [
                .target(name: "PillarboxCircumspect"),
                .target(name: "PillarboxPlayer"),
                .target(name: "PillarboxStreams"),
                .product(name: "OrderedCollections", package: "swift-collections")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
