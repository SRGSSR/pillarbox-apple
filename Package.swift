// swift-tools-version: 5.6
import PackageDescription

let package = Package(
    name: "Pillarbox",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15)
    ],
    products: [
        .library(
            name: "Analytics",
            targets: ["Analytics"]
        ),
        .library(
            name: "Appearance",
            targets: ["Appearance"]
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
            name: "UI",
            targets: ["UI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/comScore/Comscore-Swift-Package-Manager.git", .upToNextMinor(from: "6.10.0")),
        .package(url: "https://github.com/SRGSSR/GoogleCastSDK-no-bluetooth.git", .upToNextMinor(from: "4.7.1-beta.1")),
        .package(url: "https://github.com/SRGSSR/TCCore-xcframework-apple.git", .upToNextMinor(from: "4.5.4-srg5")),
        .package(url: "https://github.com/SRGSSR/TCSDK-xcframework-apple.git", .upToNextMinor(from: "4.4.1-srg5"))
    ],
    targets: [
        .target(
            name: "Analytics",
            dependencies: [
                .product(name: "ComScore", package: "Comscore-Swift-Package-Manager"),
                .product(name: "TCCore", package: "TCCore-xcframework-apple"),
                .product(name: "TCSDK", package: "TCSDK-xcframework-apple")
            ]
        ),
        .target(name: "Appearance"),
        .target(
            name: "Business",
            dependencies: [
                .target(name: "Analytics"),
                .target(name: "Diagnostics")
            ]
        ),
        .target(name: "Diagnostics"),
        .target(name: "Player"),
        .target(
            name: "UI",
            dependencies: [
                .target(name: "Appearance"),
                .target(name: "Player"),
                .product(name: "GoogleCastSDK-no-bluetooth", package: "GoogleCastSDK-no-bluetooth", condition: .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "AnalyticsTests",
            dependencies: [
                .target(name: "Analytics")
            ]
        ),
        .testTarget(
            name: "AppearanceTests",
            dependencies: [
                .target(name: "Appearance")
            ]
        ),
        .testTarget(
            name: "BusinessTests",
            dependencies: [
                .target(name: "Business")
            ]
        ),
        .testTarget(
            name: "DiagnosticsTests",
            dependencies: [
                .target(name: "Diagnostics")
            ]
        ),
        .testTarget(
            name: "PlayerTests",
            dependencies: [
                .target(name: "Player")
            ]
        ),
        .testTarget(
            name: "UITests",
            dependencies: [
                .target(name: "UI")
            ]
        )
    ]
)
