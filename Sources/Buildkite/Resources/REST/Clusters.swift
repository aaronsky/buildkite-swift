//
//  Clusters.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/18/23.
//  Copyright © 2023 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Cluster {
    public enum Resources {}
}

extension Cluster.Resources {
    /// List cluster.
    ///
    /// Returns a paginated list of an organization's clusters.
    public struct List: PaginatedResource, Equatable, Hashable, Sendable {
        public typealias Content = [Cluster]
        /// organization slug
        public var organization: String

        public var path: String {
            "organizations/\(organization)/clusters"
        }

        public init(
            organization: String
        ) {
            self.organization = organization
        }
    }

    /// Get a cluster.
    public struct Get: Resource, Equatable, Hashable, Sendable {
        public typealias Content = Cluster
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)"
        }

        public init(
            organization: String,
            clusterId: UUID
        ) {
            self.organization = organization
            self.clusterId = clusterId
        }
    }

    /// Create a cluster.
    public struct Create: Resource, Equatable, Hashable, Sendable {
        public typealias Content = Cluster
        /// organization slug
        public var organization: String

        public var body: Body

        public struct Body: Codable, Equatable, Hashable, Sendable {
            /// Name for the cluster.
            public var name: String
            /// Description for the cluster.
            public var description: String?
            /// Emoji for the cluster using the emoji syntax.
            public var emoji: String?
            /// Color hex code for the cluster.
            public var color: String?

            public init(
                name: String,
                description: String? = nil,
                emoji: String? = nil,
                color: String? = nil
            ) {
                self.name = name
                self.description = description
                self.emoji = emoji
                self.color = color
            }
        }

        public var path: String {
            "organizations/\(organization)/clusters"
        }

        public init(
            organization: String,
            body: Body
        ) {
            self.organization = organization
            self.body = body
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "POST"
        }
    }

    /// Update a cluster.
    public struct Update: Resource, Equatable, Hashable, Sendable {
        public typealias Content = Cluster
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID

        public var body: Body

        public struct Body: Codable, Equatable, Hashable, Sendable {
            /// Name for the cluster.
            public var name: String
            /// Description for the cluster.
            public var description: String
            /// Emoji for the cluster using the emoji syntax.
            public var emoji: String
            /// Color hex code for the cluster.
            public var color: String
            /// ID of the queue to set as the cluster's default queue. Agents that connect to the cluster without specifying a queue will accept jobs from this queue.
            public var defaultQueueId: UUID

            public init(
                name: String,
                description: String,
                emoji: String,
                color: String,
                defaultQueueId: UUID
            ) {
                self.name = name
                self.description = description
                self.emoji = emoji
                self.color = color
                self.defaultQueueId = defaultQueueId
            }

            private enum CodingKeys: String, CodingKey {
                case name
                case description
                case emoji
                case color
                case defaultQueueId = "default_queue_id"
            }
        }

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)"
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
            request.httpMethod = "PUT"
        }
    }

    /// Delete a cluster.
    public struct Delete: Resource, Equatable, Hashable, Sendable {
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)"
        }

        public init(
            organization: String,
            clusterId: UUID
        ) {
            self.organization = organization
            self.clusterId = clusterId
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "DELETE"
        }
    }
}

extension Resource where Self == Cluster.Resources.List {
    /// List clusters
    ///
    /// Returns a paginated list of an organization's clusters.
    public static func clusters(in organization: String) -> Self {
        Self(organization: organization)
    }
}

extension Resource where Self == Cluster.Resources.Get {
    /// Get a cluster.
    public static func cluster(_ id: UUID, in organization: String) -> Self {
        Self(organization: organization, clusterId: id)
    }
}

extension Resource where Self == Cluster.Resources.Create {
    /// Create a cluster.
    public static func createCluster(_ body: Self.Body, in organization: String) -> Self {
        Self(organization: organization, body: body)
    }
}

extension Resource where Self == Cluster.Resources.Update {
    /// Update a cluster.
    public static func updateCluster(_ id: UUID, in organization: String, with body: Self.Body) -> Self {
        Self(organization: organization, clusterId: id, body: body)
    }
}

extension Resource where Self == Cluster.Resources.Delete {
    /// Delete a cluster.
    public static func deleteCluster(_ id: UUID, in organization: String) -> Self {
        Self(organization: organization, clusterId: id)
    }
}
