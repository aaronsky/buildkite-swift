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

public struct Configuration {
    public let userAgent = "buildkite-swift"
    public var version: APIVersion
    public var graphQLVersion: APIVersion

    public static var `default`: Configuration {
        .init(version: APIVersion.REST.v2, graphQLVersion: APIVersion.GraphQL.v1)
    }

    public init(version: APIVersion = APIVersion.REST.v2, graphQLVersion: APIVersion = APIVersion.GraphQL.v1) {
        self.version = version
        self.graphQLVersion = graphQLVersion
    }

    var token: String?

    func transformRequest(_ request: inout URLRequest) {
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

}
