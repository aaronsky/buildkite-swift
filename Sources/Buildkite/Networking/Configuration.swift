//
//  Configuration.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Generic configuration for the ``BuildkiteClient``.
public struct Configuration: Equatable, Hashable, Sendable {
    public let userAgent = "buildkite-swift"

    public var version: APIVersion
    public var graphQLVersion: APIVersion
    public var agentVersion: APIVersion
    public var testAnalyticsVersion: APIVersion

    public static var `default`: Configuration {
        .init(
            version: APIVersion.REST.v2,
            graphQLVersion: APIVersion.GraphQL.v1,
            agentVersion: APIVersion.Agent.v3,
            testAnalyticsVersion: APIVersion.TestAnalytics.v1
        )
    }

    public init(
        version: APIVersion = APIVersion.REST.v2,
        graphQLVersion: APIVersion = APIVersion.GraphQL.v1,
        agentVersion: APIVersion = APIVersion.Agent.v3,
        testAnalyticsVersion: APIVersion = APIVersion.TestAnalytics.v1
    ) {
        self.version = version
        self.graphQLVersion = graphQLVersion
        self.agentVersion = agentVersion
        self.testAnalyticsVersion = testAnalyticsVersion
    }

    func transformRequest(
        _ request: inout URLRequest,
        tokens: TokenProvider?,
        version: APIVersion
    ) async {
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        if let header = await tokens?.authorizationHeader(for: version) {
            request.addValue(header, forHTTPHeaderField: "Authorization")
        }
    }

}
