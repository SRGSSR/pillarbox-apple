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
            name: "Appearance",
            targets: ["Appearance"]
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
        .package(url: "https://github.com/SRGSSR/TCCore-xcframework-apple.git", .upToNextMinor(from: "4.5.4-srg5")),
        .package(url: "https://github.com/SRGSSR/TCSDK-xcframework-apple.git", .upToNextMinor(from: "4.4.1-srg5")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(name: "Appearance"),
        .target(
            name: "CoreBusiness",
            dependencies: [
                .target(name: "Diagnostics"),
                .product(name: "ComScore", package: "Comscore-Swift-Package-Manager"),
                .product(name: "TCCore", package: "TCCore-xcframework-apple"),
                .product(name: "TCSDK", package: "TCSDK-xcframework-apple")
            ]
        ),
        .target(name: "Diagnostics"),
        .target(name: "Player"),
        .target(
            name: "UserInterface",
            dependencies: [
                .target(name: "Appearance"),
                .target(name: "Player"),
                .product(name: "GoogleCastSDK-no-bluetooth", package: "GoogleCastSDK-no-bluetooth", condition: .when(platforms: [.iOS]))
            ]
        ),
        .testTarget(
            name: "AppearanceTests",
            dependencies: [
                .target(name: "Appearance")
            ]
        ),
        .testTarget(
            name: "CoreBusinessTests",
            dependencies: [
                .target(name: "CoreBusiness")
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
            name: "UserInterfaceTests",
            dependencies: [
                .target(name: "UserInterface")
            ]
        )
    ]
)
