//
//  Followable.swift
//  Buildkite
//
//  Created by Aaron Sky on 8/28/21.
//  Copyright © 2021 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Followable is a container resource that allows URLs returned by Buildkite's API to be easily consumed
/// by the client.
///
/// Here's an example of using a ``Followable`` resource:
///
/// ```swift
/// let client = BuildkiteClient(token: "...")
/// let organizationResponse = await client.send(.organization("buildkite")
/// let agentsResponse = await client.send(organizationResponse.content.agentsUrl)
/// print(agentsResponse.content) // Array<Agent>(...)
/// ```
public struct Followable<R: Resource>: Codable, Equatable, Resource {
    public typealias Content = R.Content

    public let path = ""

    private var url: URL

    init(
        url: URL
    ) {
        self.url = url
    }

    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.singleValueContainer()
        let url = try container.decode(URL.self)
        self.init(url: url)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(url)
    }

    public func transformRequest(_ request: inout URLRequest) {
        request.url = url
    }
}
