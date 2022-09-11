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

public struct User: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var graphqlId: String
    public var name: String
    public var email: String
    public var avatarURL: URL
    public var createdAt: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case graphqlId = "graphql_id"
        case name
        case email
        case avatarURL = "avatar_url"
        case createdAt = "created_at"
    }
}
