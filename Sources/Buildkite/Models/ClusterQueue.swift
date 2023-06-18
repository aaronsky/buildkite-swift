//
//  ClusterQueue.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/18/23.
//  Copyright © 2023 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Cluster queues are discrete groups of agents within a cluster. Pipelines in that cluster can target cluster queues to run jobs on agents assigned to those queues.
public struct ClusterQueue: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the cluster.
    public var id: UUID
    /// ID of the cluster to be used with the GraphQL API.
    public var graphqlId: String
    /// The queue key.
    public var key: String
    /// Description of the queue.
    public var description: String
    /// Followable URL to fetch this specific queue.
    public var url: Followable<ClusterQueue.Resources.Get>
    /// Human-readable URL of this queue in the Buildkite dashboard.
    public var webURL: URL
    /// Followable URL to fetch the cluster the queue belongs to.
    public var clusterURL: Followable<Cluster.Resources.Get>
    /// Indicates whether the queue has paused dispatching jobs to associated agents.
    public var dispatchPaused: Bool
    /// User who paused the queue.
    public var dispatchPausedBy: User?
    /// When the queue was paused.
    public var dispatchPausedAt: Date?
    /// The note left when the queue was paused.
    public var dispatchPausedNote: String?
    /// When the queue was created.
    public var createdAt: Date
    /// User who created the queue.
    public var createdBy: User?

    public init(
        id: UUID,
        graphqlId: String,
        key: String,
        description: String,
        url: Followable<ClusterQueue.Resources.Get>,
        webURL: URL,
        clusterURL: Followable<Cluster.Resources.Get>,
        dispatchPaused: Bool,
        dispatchPausedBy: User? = nil,
        dispatchPausedAt: Date? = nil,
        dispatchPausedNote: String? = nil,
        createdAt: Date,
        createdBy: User? = nil
    ) {
        self.id = id
        self.graphqlId = graphqlId
        self.key = key
        self.description = description
        self.url = url
        self.webURL = webURL
        self.clusterURL = clusterURL
        self.dispatchPaused = dispatchPaused
        self.dispatchPausedBy = dispatchPausedBy
        self.dispatchPausedAt = dispatchPausedAt
        self.dispatchPausedNote = dispatchPausedNote
        self.createdAt = createdAt
        self.createdBy = createdBy
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case graphqlId = "graphql_id"
        case key
        case description
        case url
        case webURL = "web_url"
        case clusterURL = "cluster_url"
        case dispatchPaused = "dispatch_paused"
        case dispatchPausedBy = "dispatch_paused_by"
        case dispatchPausedAt = "dispatch_paused_at"
        case dispatchPausedNote = "dispatch_paused_note"
        case createdAt = "created_at"
        case createdBy = "created_by"
    }
}
