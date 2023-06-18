//
//  ClusterQueues.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/18/23.
//  Copyright © 2023 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension ClusterQueue {
    public enum Resources {}
}

extension ClusterQueue.Resources {
    /// List cluster.
    ///
    /// Returns a paginated list of an organization's clusters.
    public struct List: PaginatedResource, Equatable, Hashable, Sendable {
        public typealias Content = [ClusterQueue]
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID

        public var path: String {
            "organizations/\(organization)/clusters\(clusterId)/queues"
        }

        public init(
            organization: String,
            clusterId: UUID
        ) {
            self.organization = organization
            self.clusterId = clusterId
        }
    }

    /// Get a cluster.
    public struct Get: Resource, Equatable, Hashable, Sendable {
        public typealias Content = ClusterQueue
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID
        /// queue ID
        public var queueId: UUID

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)/queues/\(queueId)"
        }

        public init(
            organization: String,
            clusterId: UUID,
            queueId: UUID
        ) {
            self.organization = organization
            self.clusterId = clusterId
            self.queueId = queueId
        }
    }

    /// Create a cluster queue.
    public struct Create: Resource, Equatable, Hashable, Sendable {
        public typealias Content = ClusterQueue
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID

        public var body: Body

        public struct Body: Codable, Equatable, Hashable, Sendable {
            /// Key for the queue.
            public var key: String
            /// Description for the queue.
            public var description: String?

            public init(
                key: String,
                description: String? = nil
            ) {
                self.key = key
                self.description = description
            }
        }

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)/queues"
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

    /// Update a cluster queue.
    public struct Update: Resource, Equatable, Hashable, Sendable {
        public typealias Content = ClusterQueue
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID
        /// queue ID
        public var queueId: UUID

        public var body: Body

        public struct Body: Codable, Equatable, Hashable, Sendable {
            /// Description for the cluster.
            public var description: String

        }

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)/queues/\(queueId)"
        }

        public init(
            organization: String,
            clusterId: UUID,
            queueId: UUID,
            body: Body
        ) {
            self.organization = organization
            self.clusterId = clusterId
            self.queueId = queueId
            self.body = body
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "PUT"
        }
    }

    /// Delete a cluster queue.
    public struct Delete: Resource, Equatable, Hashable, Sendable {
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID
        /// queue ID
        public var queueId: UUID

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)/queues/\(queueId)"
        }

        public init(
            organization: String,
            clusterId: UUID,
            queueId: UUID
        ) {
            self.organization = organization
            self.clusterId = clusterId
            self.queueId = queueId
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "DELETE"
        }
    }

    /// Resume a paused cluster queue.
    public struct ResumeDispatch: Resource, Equatable, Hashable, Sendable {
        /// organization slug
        public var organization: String
        /// cluster ID
        public var clusterId: UUID
        /// queue ID
        public var queueId: UUID

        public var path: String {
            "organizations/\(organization)/clusters/\(clusterId)/queues/\(queueId)/resume_dispatch"
        }

        public init(
            organization: String,
            clusterId: UUID,
            queueId: UUID
        ) {
            self.organization = organization
            self.clusterId = clusterId
            self.queueId = queueId
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "POST"
        }
    }
}

extension Resource where Self == ClusterQueue.Resources.List {
    /// List cluster tokens
    ///
    /// Returns a paginated list of a cluster's tokens.
    public static func clusterQueues(in organization: String, clusterId: UUID) -> Self {
        Self(organization: organization, clusterId: clusterId)
    }
}

extension Resource where Self == ClusterQueue.Resources.Get {
    /// Get a cluster token.
    public static func clusterQueue(_ id: UUID, in organization: String, clusterId: UUID) -> Self {
        Self(organization: organization, clusterId: clusterId, queueId: id)
    }
}

extension Resource where Self == ClusterQueue.Resources.Create {
    /// Create a cluster token.
    public static func createClusterQueue(_ body: Self.Body, in organization: String, clusterId: UUID) -> Self {
        Self(organization: organization, clusterId: clusterId, body: body)
    }
}

extension Resource where Self == ClusterQueue.Resources.Update {
    /// Update a cluster token.
    public static func updateClusterQueue(
        _ id: UUID,
        in organization: String,
        clusterId: UUID,
        with description: String
    ) -> Self {
        Self(organization: organization, clusterId: clusterId, queueId: id, body: .init(description: description))
    }
}

extension Resource where Self == ClusterQueue.Resources.Delete {
    /// Delete a cluster token.
    public static func deleteClusterQueue(_ id: UUID, in organization: String, clusterId: UUID) -> Self {
        Self(organization: organization, clusterId: clusterId, queueId: id)
    }
}

extension Resource where Self == ClusterQueue.Resources.ResumeDispatch {
    /// Delete a cluster token.
    public static func resumeClusterQueueDispatch(_ id: UUID, in organization: String, clusterId: UUID) -> Self {
        Self(organization: organization, clusterId: clusterId, queueId: id)
    }
}
