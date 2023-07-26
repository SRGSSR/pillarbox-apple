// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "YouTubeIdentifier",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16)
    ],
    products: [
        .library(
            name: "YouTubeIdentifier",
            targets: ["YouTubeIdentifier"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "12.0.0"))
    ],
    targets: [
        .target(name: "YouTubeIdentifier"),
        .testTarget(
            name: "YouTubeIdentifierTests",
            dependencies: ["YouTubeIdentifier", "Nimble"]
        )
    ]
)
