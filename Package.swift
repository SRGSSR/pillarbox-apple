// swift-tools-version: 5.7
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
            name: "Analytics",
            targets: ["Analytics"]
        ),
        .library(
            name: "Circumspect",
            targets: ["Circumspect"]
        ),
        .library(
            name: "Core",
            targets: ["Core"]
        ),
        .library(
            name: "CoreBusiness",
            targets: ["CoreBusiness"]
        ),
        .library(
            name: "Player",
            targets: ["Player"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/comScore/Comscore-Swift-Package-Manager.git", .upToNextMinor(from: "6.10.0")),
        .package(url: "https://github.com/CommandersAct/iOSV5.git", .upToNextMinor(from: "5.3.0")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.3")),
        .package(url: "https://github.com/krzysztofzablocki/Difference.git", exact: "1.0.1"),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "12.0.0")),
        .package(url: "https://github.com/icanzilb/TimelaneCombine.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "Analytics",
            dependencies: [
                .target(name: "Player"),
                .product(name: "ComScore", package: "Comscore-Swift-Package-Manager"),
                .product(name: "TCCore", package: "iOSV5"),
                .product(name: "TCServerSide", package: "iOSV5")
            ],
            linkerSettings: [
                .linkedFramework("AdSupport")
            ],
            plugins: [
                .plugin(name: "PackageInfoPlugin")
            ]
        ),
        .target(name: "Core"),
        .target(
            name: "CoreBusiness",
            dependencies: [
                .target(name: "Analytics")
            ],
            plugins: [
                .plugin(name: "PackageInfoPlugin")
            ]
        ),
        .target(
            name: "Circumspect",
            dependencies: [
                .product(name: "Difference", package: "Difference"),
                .product(name: "Nimble", package: "Nimble")
            ]
        ),
        .target(
            name: "Player",
            dependencies: [
                .target(name: "Core"),
                .product(name: "DequeModule", package: "swift-collections"),
                .product(name: "TimelaneCombine", package: "TimelaneCombine")
            ],
            plugins: [
                .plugin(name: "PackageInfoPlugin")
            ]
        ),
        .target(
            name: "Streams",
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
                .target(name: "Analytics"),
                .target(name: "Circumspect"),
                .target(name: "Streams")
            ]
        ),
        .testTarget(
            name: "CircumspectTests",
            dependencies: [
                .target(name: "Circumspect")
            ]
        ),
        .testTarget(
            name: "CoreTests",
            dependencies: [
                .target(name: "Circumspect"),
                .target(name: "Core")
            ]
        ),
        .testTarget(
            name: "CoreBusinessTests",
            dependencies: [
                .target(name: "Circumspect"),
                .target(name: "CoreBusiness")
            ]
        ),
        .testTarget(
            name: "PlayerTests",
            dependencies: [
                .target(name: "Circumspect"),
                .target(name: "Player"),
                .target(name: "Streams"),
                .product(name: "OrderedCollections", package: "swift-collections")
            ]
        )
    ]
)
