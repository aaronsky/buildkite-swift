// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Buildkite",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "Buildkite",
            targets: ["Buildkite"])
    ],
    targets: [
        .target(
            name: "Buildkite",
            dependencies: []
        ),

        // Examples

        .executableTarget(
            name: "graphql",
            dependencies: ["Buildkite"],
            path: "Examples/graphql"
        ),

        // Tests

        .testTarget(
            name: "BuildkiteTests",
            dependencies: ["Buildkite"]
        )
    ]
)
