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
            name: "Diagnostics",
            targets: ["Diagnostics"]
        ),
        .library(
            name: "Player",
            targets: ["Player"]
        ),
        .library(
            name: "UserInterface",
            targets: ["UserInterface"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/comScore/Comscore-Swift-Package-Manager.git", .upToNextMinor(from: "6.10.0")),
        .package(url: "https://github.com/SRGSSR/GoogleCastSDK-no-bluetooth.git", .upToNextMinor(from: "4.7.1-beta.1")),
        .package(url: "https://github.com/SRGSSR/TCCore-xcframework-apple.git", .upToNextMinor(from: "5.1.1")),
        .package(url: "https://github.com/SRGSSR/TCServerSide-xcframework-apple.git", .upToNextMinor(from: "5.1.2")),
        .package(url: "https://github.com/apple/swift-collections.git", .upToNextMajor(from: "1.0.3")),
        .package(url: "https://github.com/krzysztofzablocki/Difference.git", exact: "1.0.1"),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "11.1.1")),
        .package(url: "https://github.com/icanzilb/TimelaneCombine.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(
            name: "Analytics",
            dependencies: [
                .product(name: "ComScore", package: "Comscore-Swift-Package-Manager"),
                .product(name: "TCCore", package: "TCCore-xcframework-apple"),
                .product(name: "TCServerSide", package: "TCServerSide-xcframework-apple")
            ]
        ),
        .target(name: "Core"),
        .target(
            name: "CoreBusiness",
            dependencies: [
                .target(name: "Analytics"),
                .target(name: "Diagnostics"),
                .target(name: "Player")
            ]
        ),
        .target(
            name: "Circumspect",
            dependencies: [
                .product(name: "Difference", package: "Difference"),
                .product(name: "Nimble", package: "Nimble")
            ]
        ),
        .target(name: "Diagnostics"),
        .target(
            name: "Player",
            dependencies: [
                .target(name: "Core"),
                .product(name: "DequeModule", package: "swift-collections"),
                .product(name: "TimelaneCombine", package: "TimelaneCombine")
            ]
        ),
        .target(
            name: "UserInterface",
            dependencies: [
                .target(name: "Player"),
                .product(name: "GoogleCastSDK-no-bluetooth", package: "GoogleCastSDK-no-bluetooth", condition: .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: [
                .target(name: "Analytics"),
                .target(name: "Circumspect")
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
            name: "DiagnosticsTests",
            dependencies: [
                .target(name: "Circumspect"),
                .target(name: "Diagnostics")
            ]
        ),
        .testTarget(
            name: "PlayerTests",
            dependencies: [
                .target(name: "Circumspect"),
                .target(name: "Player"),
                .product(name: "OrderedCollections", package: "swift-collections")
            ],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "UserInterfaceTests",
            dependencies: [
                .target(name: "Circumspect"),
                .target(name: "UserInterface")
            ]
        )
    ]
)
