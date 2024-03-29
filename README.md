# Buildkite

[![CI](https://github.com/aaronsky/buildkite-swift/actions/workflows/ci.yml/badge.svg)](https://github.com/aaronsky/buildkite-swift/actions/workflows/ci.yml)

A Swift library and client for the Buildkite REST and GraphQL APIs.

```swift
import Buildkite

let client = BuildkiteClient(token: "...")

let response = try await client.send(.pipelines(in: "buildkite"))
let pipelines = response.content
print(pipelines)
```

## Usage

[Getting Started](./Sources/Buildkite/Buildkite.docc/Articles/GettingStarted.md)

## References

-   [Buildkite](https://buildkite.com/)
-   [Buildkite API Documentation](https://buildkite.com/docs/apis)
-   [Buildkite GraphQL Explorer](https://graphql.buildkite.com/explorer)

## License

Buildkite for Swift is released under the BSD-2 license. [See LICENSE](https://github.com/aaronsky/buildkite-swift/blob/master/LICENSE) for details.
