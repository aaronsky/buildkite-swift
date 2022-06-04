// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Buildkite",
    platforms: [
        .iOS(.v10),
        .macOS(.v10_12),
        .tvOS(.v10),
        .watchOS(.v3),
    ],
    products: [
        .library(
            name: "Buildkite",
            targets: ["Buildkite"]
        )
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
        ),
    ]
)

#if swift(>=5.6)
// Add the documentation compiler plugin if possible
package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
)
#endif
