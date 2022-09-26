//
//  User.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Information about the user account that owns the API token that is currently being used.
public struct User: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the user.
    public var id: UUID
    /// ID of the user to be used with the GraphQL API.
    public var graphqlId: String
    /// User's name.
    public var name: String
    /// User's email.
    public var email: String
    /// URL to the user's profile image.
    public var avatarURL: URL
    /// When the user was created.
    public var createdAt: Date

    public init(
        id: UUID,
        graphqlId: String,
        name: String,
        email: String,
        avatarURL: URL,
        createdAt: Date
    ) {
        self.id = id
        self.graphqlId = graphqlId
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case graphqlId = "graphql_id"
        case name
        case email
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
    }
}
