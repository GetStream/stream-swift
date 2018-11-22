// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GetStream",
    products: [
        .library(name: "GetStream", targets: ["GetStream"]),
        .library(name: "GetStreamToken", targets: ["GetStreamToken"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "12.0.0")),
        .package(url: "https://github.com/JohnSundell/Require.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/kylef/JSONWebToken.swift.git", .upToNextMajor(from: "2.2.0")),
    ],
    targets: [
        .target(name: "GetStream", dependencies: ["Moya", "Require"], path: "Sources/Core"),
        .target(name: "GetStreamToken", dependencies: ["GetStream", "JWT"], path: "Sources/Token"),
        .testTarget(name: "GetStreamTests", dependencies: ["GetStream"], path: "iOS-Tests/Tests/Core"),
//        .testTarget(name: "GetStreamTokenTests", dependencies: ["GetStreamToken"], path: "iOS-Tests/Tests/Token"),
    ],
    swiftLanguageVersions: [.v4, .v4_2]
)
