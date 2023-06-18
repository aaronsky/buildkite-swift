//
//  ClusterTokens.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/18/23.
//  Copyright © 2023 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension ClusterToken {
    public enum Resources {}
}

extension ClusterToken.Resources {
    /// List cluster tokens
    ///
    /// Returns a paginated list of a cluster's tokens.
    public struct List: PaginatedResource, Equatable, Hashable, Sendable {
        public typealias Content = [ClusterToken]
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)/tokens"
        }

        public init(
            organization: String,
            clusterId: UUID
        ) {
            self.organization = organization
            self.clusterId = clusterId
        }
    }

    /// Get a cluster token.
    public struct Get: Resource, Equatable, Hashable, Sendable {
        public typealias Content = ClusterToken
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID
        /// cluster token ID
        public var tokenId: UUID

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)/tokens/\(tokenId)"
        }

        public init(
            organization: String,
            clusterId: UUID,
            tokenId: UUID
        ) {
            self.organization = organization
            self.clusterId = clusterId
            self.tokenId = tokenId
        }
    }

    /// Create a cluster token.
    public struct Create: Resource, Equatable, Hashable, Sendable {
        public typealias Content = ClusterToken
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID

        public var body: Body

        public struct Body: Codable, Equatable, Hashable, Sendable {
            /// Description for the token.
            public var description: String

            public init(
                description: String
            ) {
                self.description = description
            }
        }

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)/tokens"
        }

        public init(
            organization: String,
            clusterId: UUID,
            body: Body
        ) {
            self.organization = organization
            self.clusterId = clusterId
            self.body = body
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "POST"
        }
    }

    /// Update a cluster token.
    public struct Update: Resource, Equatable, Hashable, Sendable {
        public typealias Content = ClusterToken
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID
        /// cluster token ID
        public var tokenId: UUID

        public var body: Body

        public struct Body: Codable, Equatable, Hashable, Sendable {
            /// Description for the token.
            public var description: String

            public init(
                description: String
            ) {
                self.description = description
            }
        }

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)/tokens/\(tokenId)"
        }

        public init(
            organization: String,
            clusterId: UUID,
            tokenId: UUID,
            body: Body
        ) {
            self.organization = organization
            self.clusterId = clusterId
            self.tokenId = tokenId
            self.body = body
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "PUT"
        }
    }

    /// Delete a cluster token.
    public struct Delete: Resource, Equatable, Hashable, Sendable {
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID
        /// cluster token ID
        public var tokenId: UUID

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)/tokens/\(tokenId)"
        }

        public init(
            organization: String,
            clusterId: UUID,
            tokenId: UUID
        ) {
            self.organization = organization
            self.clusterId = clusterId
            self.tokenId = tokenId
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "DELETE"
        }
    }
}

extension Resource where Self == ClusterToken.Resources.List {
    /// List cluster tokens
    ///
    /// Returns a paginated list of a cluster's tokens.
    public static func clusterTokens(in organization: String, clusterId: UUID) -> Self {
        Self(organization: organization, clusterId: clusterId)
    }
}

extension Resource where Self == ClusterToken.Resources.Get {
    /// Get a cluster token.
    public static func clusterToken(_ id: UUID, in organization: String, clusterId: UUID) -> Self {
        Self(organization: organization, clusterId: clusterId, tokenId: id)
    }
}

extension Resource where Self == ClusterToken.Resources.Create {
    /// Create a cluster token.
    public static func createClusterToken(with description: String, in organization: String, clusterId: UUID) -> Self {
        Self(organization: organization, clusterId: clusterId, body: Self.Body(description: description))
    }
}

extension Resource where Self == ClusterToken.Resources.Update {
    /// Update a cluster token.
    public static func updateClusterToken(
        _ id: UUID,
        in organization: String,
        clusterId: UUID,
        with description: String
    ) -> Self {
        Self(organization: organization, clusterId: clusterId, tokenId: id, body: Self.Body(description: description))
    }
}

extension Resource where Self == ClusterToken.Resources.Delete {
    /// Delete a cluster token.
    public static func deleteClusterToken(_ id: UUID, in organization: String, clusterId: UUID) -> Self {
        Self(organization: organization, clusterId: clusterId, tokenId: id)
    }
}
