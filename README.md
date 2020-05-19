# Buildkite

![Build Status](https://github.com/aaronsky/buildkite-swift/workflows/CI/badge.svg)

A Swift library and client for the Buildkite REST and GraphQL APIs.

## Usage

Add the dependency to your `Package.swift` file:

```swift
let package = Package(
    name: "myproject",
    dependencies: [
        .package(url: "https://github.com/aaronsky/buildkite-swift.git", from: "0.0.3"),
        ],
    targets: [
        .target(
            name: "myproject",
            dependencies: ["Buildkite"]),
        ]
)
```

As an example, here is a way you can use the closure-based interface to list all pipelines:

```swift
import Buildkite

let client = Buildkite()
client.token = "..." // Your scoped Buildkite API access token
client.send(Pipeline.Resources.List(organization: "buildkite")) { result in
    do {
        let response = try result.get()
        let pipelines = response.content
        print(pipelines)
    } catch {
        print(error)
    }
}
```

You can even use Combine, if you'd like!

```swift
import Buildkite

let client = Buildkite()
client.token = "..." // Your scoped Buildkite API access token

var cancellables: Set<AnyCancellable> = []
client.sendPublisher(Pipeline.Resources.List(organization: "buildkite"))
    .map(\.content)
    .sink(receiveCompletion: { _ in }) { pipelines in
        print(pipelines)
    }.store(in: &cancellables)
```

The entire publicly documented REST API surface is supported by this package.

### GraphQL

GraphQL support is present, but currently rudimentary. For example, here's what the same query as above would look like in GraphQL:

```swift
import Foundation
import Buildkite

let client = Buildkite()
client.token = "..."

let query = """
query MyPipelines($first: Int!) {
    organization(slug: "buildkite") {
        pipelines(first: $first) {
            edges {
                node {
                    name
                    uuid
                }
            }
        }
    }
}
"""

struct MyPipeline: Codable {
    var organization: Organization?

    struct Organization: Codable {
        var pipelines: Pipelines

        struct Pipelines: Codable {
            var edges: [PipelineEdge]

            struct PipelineEdge: Codable {
                var node: Pipeline

                struct Pipeline: Codable {
                    var name: String
                    var uuid: UUID
                }
            }
        }
    }
}

var cancellables: Set<AnyCancellable> = []
client.sendPublisher(GraphQL<MyPipeline>(rawQuery: query, variables: ["first": 30]))
    .map(\.content)
    .sink(receiveCompletion: { _ in }) { pipelines in
        print(pipelines)
    }.store(in: &cancellables)
```

## References

-   [Buildkite](https://buildkite.com/)
-   [Buildkite API Documentation](https://buildkite.com/docs/apis)
-   [Buildkite GraphQL Explorer](https://graphql.buildkite.com/explorer)

## License

Buildkite for Swift is released under the BSD-2 license. [See LICENSE](https://github.com/aaronsky/buildkite-swift/blob/master/LICENSE) for details.
