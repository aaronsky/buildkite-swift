# Using GraphQL

Send a GraphQL resource and receive the response.

## Overview

GraphQL support is present, but currently rudimentary.

Here's what it might look like to fetch a list of pipelines, presuming there is already an instance of the client configured.

```swift
let query = """
query Pipelines($first: Int!) {
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

let resource = GraphQL(rawQuery: query, variables: ["first": 30])
let pipeline: Pipelines = try await client.sendQuery(resource)
```

The helper method `sendQuery` can be used to automatically extract the data from a GraphQL response, without having to juggle HTTP, decoding and schema errors in separate calls. You can still use any of the `send` or `sendPublisher` methods to process a GraphQL query, if you require the response data as well. 
