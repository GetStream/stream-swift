// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "GetStream",
    products: [
        .library(name: "GetStream", targets: ["GetStream"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "12.0.0"))
        .package(url: "https://github.com/JohnSundell/Require.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        .target(name: "GetStream", path: "Sources/Core", dependencies: ["Moya", "Require"])
    ],
    swiftLanguageVersions: [4]
)
