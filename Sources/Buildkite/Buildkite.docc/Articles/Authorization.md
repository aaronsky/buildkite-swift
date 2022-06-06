# Authorization

Buildkite supports resources across several different APIs with a variety of versions and authorization interfaces. ``BuildkiteClient`` has built-in support to interoperate between the different APIs from a single client. 

## Overview

The most basic means of authorizing with a single service in Buildkite is by the declaration of a fixed token string. The client instance will store a copy of this string in memory and use it with all subsequent requests.

```swift
let client = BuildkiteClient(token: "...")
```

Sometimes you may want to keep control of the token, either to customize how it's loaded from a credential store, or more commonly, to provide a different token based on the Buildkite API you are targeting. To opt-in to this behavior, implement your own ``TokenProvider`` type to manage your token and provide that to the ``BuildkiteClient`` when it's created.  

```swift
struct MyTokenProvider: TokenProvider {
    let myGraphQLToken: String = "..."
    let myRESTToken: String = "..."

    func token(for version: APIVersion) -> String? {
        switch version {
        case .GraphQL.v1:
            return myGraphQLToken
        case .REST.v2:
            return myRESTToken
        default:
            return nil
        }
    }
}

let client = BuildkiteClient(tokens: MyTokenProvider())
```
