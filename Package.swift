// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GetStream",
    products: [
        .library(
            name: "GetStream",
            targets: ["GetStream"]),
        ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "11.0.0"))
    ],
    targets: [
        .target(
            name: "GetStream",
            dependencies: []),
        .testTarget(
            name: "GetStreamTests",
            dependencies: ["GetStream"]),
        ]
)
