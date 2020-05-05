# Buildkite

![Build Status](https://github.com/aaronsky/buildkite-swift/workflows/CI/badge.svg)

A Swift library and client for the Buildkite REST API.

## Usage

Add the dependency to your `Package.swift` file:

```swift
let package = Package(
    name: "myproject",
    dependencies: [
        .package(url: "https://github.com/aaronsky/buildkite-swift.git", from: "0.1.0"),
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
    .sink(recieveCompletion: { _ in }) { pipelines in
        print(pipelines)   
    }.store(in: &cancellables)
```

The entire publicly documented REST API surface is supported by this package.

## References

- [Buildkite](https://buildkite.com/)
- [Buildkite API Documentation](https://buildkite.com/docs/apis/rest-api)

## License

Buildkite for Swift is released under the BSD-2 license. [See LICENSE](https://github.com/aaronsky/buildkite-swift/blob/master/LICENSE) for details.
