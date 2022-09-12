//
//  Agent.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Information about a Buildkite agent.
public struct Agent: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the agent.
    public var id: UUID
    /// ID of the agent to be used with the GraphQL API.
    public var graphqlId: String
    /// Followable URL to fetch this specific agent.
    public var url: Followable<Agent.Resources.Get>
    /// Human-readable URL of this agent in the Buildkite dashboard.
    public var webURL: URL
    /// Name of the agent.
    public var name: String
    /// Connection state of the agent.
    public var connectionState: String
    /// Hostname used by the agent.
    public var hostname: String
    /// IP address of the agent.
    public var ipAddress: String
    /// User agent of the agent.
    public var userAgent: String
    /// Version of the buildkite-agent the agent is running.
    public var version: String
    /// User who created the agent, if any, either by API or by an access token associated with them.
    public var creator: User?
    /// Date the agent was created.
    public var createdAt: Date
    /// Job the agent is currently running, if any.
    public var job: Job?
    /// When the agent last finished a job, if any.
    public var lastJobFinishedAt: Date?
    /// The priority Buildkite follows when assigning jobs to this agent.
    public var priority: Int?
    /// Additional meta-data registered by the agent. 
    public var metaData: [String]

    private enum CodingKeys: String, CodingKey {
        case id
        case graphqlId = "graphql_id"
        case url
        case webURL = "web_url"
        case name
        case connectionState = "connection_state"
        case hostname
        case ipAddress = "ip_address"
        case userAgent = "user_agent"
        case version
        case creator
        case createdAt = "created_at"
        case job
        case lastJobFinishedAt = "last_job_finished_at"
        case priority
        case metaData = "meta_data"
    }
}
