//
//  Cluster.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/18/23.
//  Copyright © 2023 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A cluster is an isolated set of agents and pipelines within an organization.

public struct Cluster: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the cluster.
    public var id: UUID
    /// ID of the cluster to be used with the GraphQL API.
    public var graphqlId: String
    /// ID of the cluster's default queue. Agents that connect to the cluster without specifying a queue will accept jobs from this queue.
    public var defaultQueueId: UUID
    /// Name of the cluster.
    public var name: String
    /// Description of the cluster.
    public var description: String
    /// Emoji for the cluster using the emoji syntax.
    public var emoji: String
    /// Color hex code for the cluster.
    public var color: String
    /// Followable URL to fetch this specific cluster.
    public var url: Followable<Cluster.Resources.Get>
    /// Human-readable URL of this cluster in the Buildkite dashboard.
    public var webURL: URL
    /// Followable URL to fetch this cluster's queues.
    public var queuesURL: Followable<ClusterQueue.Resources.List>
    /// Followable URL to fetch this cluster's default queue.
    public var defaultQueueURL: Followable<ClusterQueue.Resources.Get>
    /// When the cluster was created.
    public var createdAt: Date
    /// User who created the cluster.
    public var createdBy: User?

    public init(
        id: UUID,
        graphqlId: String,
        defaultQueueId: UUID,
        name: String,
        description: String,
        emoji: String,
        color: String,
        url: Followable<Cluster.Resources.Get>,
        webURL: URL,
        queuesURL: Followable<ClusterQueue.Resources.List>,
        defaultQueueURL: Followable<ClusterQueue.Resources.Get>,
        createdAt: Date,
        createdBy: User? = nil
    ) {
        self.id = id
        self.graphqlId = graphqlId
        self.defaultQueueId = defaultQueueId
        self.name = name
        self.description = description
        self.emoji = emoji
        self.color = color
        self.url = url
        self.webURL = webURL
        self.queuesURL = queuesURL
        self.defaultQueueURL = defaultQueueURL
        self.createdAt = createdAt
        self.createdBy = createdBy
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case graphqlId = "graphql_id"
        case defaultQueueId = "default_queue_id"
        case name
        case description
        case emoji
        case color
        case url
        case webURL = "web_url"
        case queuesURL = "queues_url"
        case defaultQueueURL = "default_queue_url"
        case createdAt = "created_at"
        case createdBy = "created_by"
    }
}
