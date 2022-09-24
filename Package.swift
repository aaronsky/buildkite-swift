// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "Buildkite",
    platforms: [
        .iOS("13.2"),
        .macOS(.v10_15),
        .tvOS("13.2"),
        .watchOS("6.1"),
    ],
    products: [
        .library(
            name: "Buildkite",
            targets: ["Buildkite"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", .upToNextMajor(from: "2.0.0")),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "Buildkite",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
            ]
        ),
        .testTarget(
            name: "BuildkiteTests",
            dependencies: ["Buildkite"]
        ),
    ]
)
