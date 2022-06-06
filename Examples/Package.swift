// swift-tools-version:5.5
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
    ],
    dependencies: [
        .package(name: "Buildkite", path: "../")
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
    ]
)
