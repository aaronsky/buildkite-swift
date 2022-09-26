// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Examples",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .executable(name: "simple", targets: ["simple"]),
        .executable(name: "graphql", targets: ["graphql"]),
        .executable(name: "advanced-authorization", targets: ["advanced-authorization"]),
        .executable(name: "test-analytics", targets: ["test-analytics"]),
        .executable(name: "webhooks", targets: ["webhooks"]),
    ],
    dependencies: [
        .package(name: "Buildkite", path: "../"),
        .package(url: "https://github.com/vapor/vapor", .upToNextMajor(from: "4.0.0")),
    ],
    targets: [
        .executableTarget(
            name: "simple",
            dependencies: [
                .product(name: "Buildkite", package: "Buildkite")
            ],
            path: "simple"
        ),
        .executableTarget(
            name: "graphql",
            dependencies: [
                .product(name: "Buildkite", package: "Buildkite")
            ],
            path: "graphql"
        ),
        .executableTarget(
            name: "advanced-authorization",
            dependencies: [
                .product(name: "Buildkite", package: "Buildkite")
            ],
            path: "advanced-authorization"
        ),
        .executableTarget(
            name: "test-analytics",
            dependencies: [
                .product(name: "Buildkite", package: "Buildkite")
            ],
            path: "test-analytics"
        ),
        .executableTarget(
            name: "webhooks",
            dependencies: [
                .product(name: "Buildkite", package: "Buildkite"),
                .product(name: "Vapor", package: "vapor"),
            ],
            path: "webhooks"
        ),
    ]
)
