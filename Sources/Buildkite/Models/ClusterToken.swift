//
//  ClusterToken.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/18/23.
//  Copyright © 2023 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A cluster token is used to connect agents to a cluster.
public struct ClusterToken: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the cluster token.
    public var id: UUID
    /// ID of the token to be used with the GraphQL API.
    public var graphqlId: String
    /// Description of the token.
    public var description: String
    /// Followable URL to fetch this specific cluster token..
    public var url: Followable<ClusterToken.Resources.Get>
    /// Followable URL to the cluster the token belongs to..
    public var clusterURL: Followable<Cluster.Resources.Get>
    /// When the token was created.
    public var createdAt: Date
    /// User who created the token.
    public var createdBy: User?
    /// The token.
    ///
    /// To ensure the security of tokens, the value is only included in the response for the request to create the token.
    /// Subsequent responses do not contain the token value.
    public var token: String?

    public init(
        id: UUID,
        graphqlId: String,
        description: String,
        url: Followable<ClusterToken.Resources.Get>,
        clusterURL: Followable<Cluster.Resources.Get>,
        createdAt: Date,
        createdBy: User? = nil,
        token: String? = nil
    ) {
        self.id = id
        self.graphqlId = graphqlId
        self.description = description
        self.url = url
        self.clusterURL = clusterURL
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.token = token
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case graphqlId = "graphql_id"
        case description
        case url
        case clusterURL = "cluster_url"
        case createdAt = "created_at"
        case createdBy = "created_by"
        case token
    }
}
