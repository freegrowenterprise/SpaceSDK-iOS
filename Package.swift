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
            url: "https://github.com/freegrowenterprise/SpaceSDK-iOS/releases/download/v0.0.39/GrowSpacePrivateSDK.xcframework.zip",
            checksum: "b67703ba5d88e5b9c4b9b55bba69b4ee6258c7f3f5feabdbb8c33667cfddbde1"
        ),
        .testTarget(
            name: "GrowSpaceSDKTests",
            dependencies: ["GrowSpaceSDK"]
        ),
    ]
)

