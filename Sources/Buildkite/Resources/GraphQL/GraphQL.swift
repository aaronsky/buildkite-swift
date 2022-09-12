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

/// The Buildkite GraphQL API provides an alternative to the [REST API](https://buildkite.com/docs/apis/rest-api).
/// It allows for more efficient retrieval of data by enabling you to fetch multiple, nested resources in a single request.
///
/// For the list of existing disparities between the GraphQL API and the REST API, see [API Differences](https://buildkite.com/docs/apis/api-differences).
public struct GraphQL<T: Decodable>: Resource, Equatable, Hashable, Sendable {
    public struct Body: Encodable, Equatable, Hashable, Sendable {
        /// The query or mutation to be sent
        public var query: String
        /// The variables to be provided alongside the query or mutation
        public var variables: JSONValue
    }

    // Making a design decision here to forbid supplying data and errors
    // simultaneously. The GraphQL spec permits it but multiple implementations,
    // including Buildkite's, choose not to.
    public enum Content: Decodable {
        case data(T)
        case errors(Errors)

        public init(
            from decoder: Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if let errors = try container.decodeIfPresent([Error].self, forKey: .errors) {
                let type = try container.decodeIfPresent(String.self, forKey: .type)
                self = .errors(Errors(errors: errors, type: type))
            } else if let data = try container.decodeIfPresent(T.self, forKey: .data) {
                self = .data(data)
            } else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: decoder.codingPath,
                        debugDescription:
                            "The GraphQL response does not contain either errors or data. One is required. If errors are present, they will be considered instead of any data that may have also been sent."
                    )
                )
            }
        }

        public func get() throws -> T {
            switch self {
            case .data(let data):
                return data
            case .errors(let errors):
                throw errors
            }
        }

        private enum CodingKeys: String, CodingKey {
            case data
            case type
            case errors
        }
    }

    public var body: Body

    public var version: APIVersion {
        APIVersion.GraphQL.v1
    }

    public let path = ""

    public init(
        rawQuery query: String,
        variables: [String: JSONValue] = [:]
    ) {
        self.body = Body(query: query, variables: .object(variables))
    }

    public func transformRequest(_ request: inout URLRequest) {
        request.httpMethod = "POST"
    }

    public struct Errors: Swift.Error, Equatable, Hashable, Sendable {
        var errors: [Error]
        var type: String?
    }

    public struct Error: Swift.Error, Decodable, Equatable, Hashable, Sendable {
        public var message: String
        public var locations: [Location]?
        public var path: [String]?
        public var extensions: JSONValue?

        public struct Location: Decodable, Equatable, Hashable, Sendable {
            public var line: Int
            public var column: Int
        }
    }
}

extension GraphQL.Content: Equatable where T: Equatable {}
extension GraphQL.Content: Hashable where T: Hashable {}
extension GraphQL.Content: Sendable where T: Sendable {}
