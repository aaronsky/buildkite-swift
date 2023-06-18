//
//  FlakyTest.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/18/23.
//  Copyright © 2023 Aaron Sky. All rights reserved.
//

import Foundation

/// Information about a flaky test that has been identified in a Test Analytics test suite.
public struct FlakyTest: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the flaky test.
    public var id: UUID
    /// ID of the user to be used with the GraphQL API.
    public var graphqlId: String
    /// Human-readable URL of this agent in the Buildkite dashboard.
    public var webURL: URL
    /// Scope of the test in the source code.
    public var scope: String
    /// Name of the test.
    public var name: String
    /// Path and line number to the test file.
    public var location: String
    /// Path to the test file.
    public var fileName: String
    /// Number of instances the test has "flaked".
    public var instances: Int
    /// The latest occurrence of the flake.
    public var mostRecentInstanceAt: Date

    public init(
        id: UUID,
        graphqlId: String,
        webURL: URL,
        scope: String,
        name: String,
        location: String,
        fileName: String,
        instances: Int,
        mostRecentInstanceAt: Date
    ) {
        self.id = id
        self.graphqlId = graphqlId
        self.webURL = webURL
        self.scope = scope
        self.name = name
        self.location = location
        self.fileName = fileName
        self.instances = instances
        self.mostRecentInstanceAt = mostRecentInstanceAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case graphqlId = "graphql_id"
        case webURL = "web_url"
        case scope
        case name
        case location
        case fileName = "file_name"
        case instances
        case mostRecentInstanceAt = "most_recent_instance_at"
    }
}
