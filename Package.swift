// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GrowSpaceSDK",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "GrowSpaceSDK",
            targets: ["GrowSpaceSDK"]),
    ],
    dependencies: [],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "GrowSpaceSDK",
            dependencies: ["GrowSpacePrivateSDK"]
        ),

        .binaryTarget(
            name: "GrowSpacePrivateSDK",
            url: "https://github.com/freegrowenterprise/SpaceSDK-iOS/releases/download/v0.0.4/GrowSpacePrivateSDK.xcframework.zip",
            checksum: "fd25f0c2b41f6280bb161beb5ed5046f82dd72d6ed0b15c6d16201d47d3b9c23"
        ),
        .testTarget(
            name: "GrowSpaceSDKTests",
            dependencies: ["GrowSpaceSDK"]
        ),
    ]
)

