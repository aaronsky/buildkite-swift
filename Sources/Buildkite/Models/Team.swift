//
//  Team.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Team: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the team
    public var id: UUID
    public var graphqlId: String
    /// Name of the team
    public var name: String
    /// URL slug of the team
    public var slug: String
    /// Description of the team
    public var description: String?
    /// Privacy setting of the team
    public var privacy: Visibility
    /// Whether users join this team by default
    public var `default`: Bool
    /// Time of when the team was created
    public var createdAt: Date
    /// User who created the team
    public var createdBy: User?

    public enum Visibility: String, Codable, Equatable, Hashable, Sendable {
        case visible
        case secret
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case graphqlId = "graphql_id"
        case name
        case slug
        case description
        case privacy
        case `default`
        case createdAt = "created_at"
        case createdBy = "created_by"
    }
}
