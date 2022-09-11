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

public struct Organization: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var graphqlId: String
    public var url: Followable<Organization.Resources.Get>
    public var webURL: URL
    public var name: String
    public var slug: String
    public var pipelinesURL: Followable<Pipeline.Resources.List>
    public var agentsURL: Followable<Agent.Resources.List>
    public var emojisURL: Followable<Emoji.Resources.List>
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
