# Buildkite

![Build Status](https://github.com/aaronsky/buildkite-swift/workflows/CI/badge.svg)

A Swift library and client for the Buildkite REST and GraphQL APIs.

## Usage

Add the dependency to your `Package.swift` file:

```swift
let package = Package(
    name: "myproject",
    dependencies: [
        .package(url: "https://github.com/aaronsky/buildkite-swift.git", from: "0.2.0"),
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

let client = BuildkiteClient()
client.token = "..." // Your scoped Buildkite API access token
client.send(.pipelines(in: "buildkite")) { result in
    do {
        let response = try result.get()
        let pipelines = response.content
        print(pipelines)
    } catch {
        print(error)
    }
}
```

You can also use Combine, if you'd like!

```swift
import Buildkite

let client = BuildkiteClient()
client.token = "..." // Your scoped Buildkite API access token

var cancellables: Set<AnyCancellable> = []
client.sendPublisher(.pipelines(in: "buildkite"))
    .map(\.content)
    .sink(receiveCompletion: { _ in }) { pipelines in
        print(pipelines)
    }.store(in: &cancellables)
```

If you're using Swift 5.5 or Xcode 13, and are shipping on a supported OS, you can even use the new async/await syntax:

```swift
import Buildkite

let client = BuildkiteClient()
client.token = "..." // Your scoped Buildkite API access token

let response = try await client.send(.pipelines(in: "buildkite"))
let pipelines = response.content

print(pipelines)
```

The entire publicly documented REST API surface is supported by this package.

### GraphQL

GraphQL support is present, but currently rudimentary. For example, here's what the same query as above would look like in GraphQL:

```swift
import Foundation
import Buildkite

let client = BuildkiteClient()
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
let pipeline: MyPipeline = try await client.sendQuery(GraphQL(rawQuery: query, 
                                                              variables: ["first": 30])
print(pipeline))
```

The helper method `sendQuery` can be used to automatically extract the data from a GraphQL response, without having to juggle HTTP, decoding and schema errors in separate calls. You can still use any of the `send` or `sendPublisher` methods to process a GraphQL query, if you require the response data as well. 

## References

-   [Buildkite](https://buildkite.com/)
-   [Buildkite API Documentation](https://buildkite.com/docs/apis)
-   [Buildkite GraphQL Explorer](https://graphql.buildkite.com/explorer)

## License

Buildkite for Swift is released under the BSD-2 license. [See LICENSE](https://github.com/aaronsky/buildkite-swift/blob/master/LICENSE) for details.
