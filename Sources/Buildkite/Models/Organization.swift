//
//  Organization.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Information about an organization the authenticated user is a member of.
public struct Organization: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the organization.
    public var id: UUID
    /// ID of the organization to be used with the GraphQL API.
    public var graphqlId: String
    /// Followable URL to fetch this specific organization.
    public var url: Followable<Organization.Resources.Get>
    /// Human-readable URL of this organization in the Buildkite dashboard.
    public var webURL: URL
    /// Name of the organization.
    public var name: String
    /// Organization slug.
    public var slug: String
    /// Followable URL to fetch some of this organization's pipelines.
    public var pipelinesURL: Followable<Pipeline.Resources.List>
    /// Followable URL to fetch some of this organization's agents.
    public var agentsURL: Followable<Agent.Resources.List>
    /// Followable URL to fetch this organization's emojis.
    public var emojisURL: Followable<Emoji.Resources.List>
    /// When this organization was created.
    public var createdAt: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case graphqlId = "graphql_id"
        case url
        case webURL = "web_url"
        case name
        case slug
        case pipelinesURL = "pipelines_url"
        case agentsURL = "agents_url"
        case emojisURL = "emojis_url"
        case createdAt = "created_at"
    }
}
