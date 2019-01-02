// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GetStream",
    products: [
        .library(name: "GetStream", targets: ["GetStream"]),
        .library(name: "GetStreamToken", targets: ["GetStreamToken"]),
        .library(name: "Faye", targets: ["Faye"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "12.0.0")),
        .package(url: "https://github.com/antitypical/Result.git", .upToNextMajor(from: "4.1.0")),
        .package(url: "https://github.com/kylef/JSONWebToken.swift.git", .upToNextMajor(from: "2.2.0")),
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "3.0.0")),
    ],
    targets: [
        .target(name: "GetStream", dependencies: ["Moya", "JWT"], path: "Sources/Core"),
        .target(name: "GetStreamToken", dependencies: ["GetStream"], path: "Sources/Token"),
        .target(name: "Faye", dependencies: ["Starscream"], path: "Faye"),
        .testTarget(name: "GetStreamTests", dependencies: ["GetStream"], path: "Tests/Core"),
    ],
    swiftLanguageVersions: [.v4_2]
)
