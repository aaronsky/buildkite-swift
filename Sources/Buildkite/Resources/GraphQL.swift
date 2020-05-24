//
//  Emojis.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/19/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct GraphQL<T: Codable>: Resource, HasResponseBody, HasRequestBody {
    public struct Body: Encodable {
        /// The query or mutation to be sent
        public var query: String
        /// The variables to be provided alongside the query or mutation
        public var variables: JSONValue
    }

    public struct Content: Codable {
        public var data: T?
        public var type: String?
        public var errors: [Error]?

        public struct Error: Swift.Error, Codable {
            public var message: String
            public var locations: [Location]?
            public var path: [String]?
            public var extensions: JSONValue?

            public struct Location: Codable {
                public var line: Int
                public var column: Int
            }
        }
    }

    public var body: Body

    public var version: APIVersion {
        APIVersion.GraphQL.v1
    }

    public let path = ""

    public init(rawQuery query: String, variables: [String: JSONValue] = [:]) {
        self.body = Body(query: query, variables: .object(variables))
    }

    public func transformRequest(_ request: inout URLRequest) {
        request.httpMethod = "POST"
    }
}
