# Getting Started

Initialize a client and get started with sending resources by listing all pipelines. 

## Overview

This article is an overview of how to set up your Buildkite client to interact with the REST API.

### Get Your Access Token

In order to access the Buildkite API you must first create an API access token. Follow Buildkite's own documentation on [managing API tokens](https://buildkite.com/docs/apis/managing-api-tokens) for more information on what to do. Keep in mind that securely storing tokens used with this package is the responsibility of the developer. 

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

## See Also

- <doc:UsingGraphQL>
- <doc:Authorization>
- <doc:Webhooks>
