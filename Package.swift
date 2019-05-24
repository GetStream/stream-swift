// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GetStream",
    products: [
        .library(name: "GetStream", targets: ["GetStream"]),
        .library(name: "Faye", targets: ["Faye"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "12.0.0")),
        .package(url: "https://github.com/antitypical/Result.git", .upToNextMajor(from: "4.1.0")),
        .package(url: "https://github.com/daltoniam/Starscream.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/sendyhalim/Swime", .upToNextMajor(from: "3.0.6")),
    ],
    targets: [
    .target(name: "GetStream", dependencies: ["Moya", "Faye", "Swime", "Result"], path: "Sources", exclude: ["Token"]),
        .target(name: "Faye", dependencies: ["Starscream"], path: "Faye"),
        .testTarget(name: "GetStreamTests", dependencies: ["GetStream"], path: "Tests", exclude: ["Token"]),
    ],
    swiftLanguageVersions: [.v4_2]
)
