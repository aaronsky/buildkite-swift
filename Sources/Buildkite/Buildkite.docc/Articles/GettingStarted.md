# Getting Started with Buildkite

Initialize a client and get started with sending resources by listing all pipelines. 

## Overview

// TODO

### Get Your Access Token

In order to access the Buildkite API you must first create an API access token. Follow Buildkite's [own documentation on managing tokens](https://buildkite.com/docs/apis/managing-api-tokens) for more information on what to do. Keep in mind that securely storing tokens used with this package is the responsibility of the developer. 

### Create a Buildkite Client

Creating a client object is as simple as calling the default initializer with an authorization token. 

```swift
let client = BuildkiteClient(token: "...") // Using your scoped Buildkite API access token
```

For more advanced authorization features, see <doc:Authorization>.

### Send a Resource

To send a resource, simply use one of the `send` methods on the client. This sample is assuming you are sending from inside an async-throwing function. 

```swift
let response = try await client.send(.pipelines(in: "buildkite"))
let pipelines = response.content
```

For platforms that do not support Swift Concurrency, you can use the closure-based interface.

```swift
client.send(.pipelines(in: "buildkite")) { result in
    do {
        let response = try result.get()
        let pipelines = response.content
    } catch {
        print(error)
    }
}
```

Combine is also supported, on platforms where it is available.

```swift
var cancellables: Set<AnyCancellable> = []
client.sendPublisher(.pipelines(in: "buildkite"))
    .map(\.content)
    .sink { _ in

    } receiveValue: { pipelines in
        print(pipelines)
    }.store(in: &cancellables)
```
