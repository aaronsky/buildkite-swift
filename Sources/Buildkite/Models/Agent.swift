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

public struct Agent: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var graphqlId: String
    public var url: Followable<Agent.Resources.Get>
    public var webURL: URL
    public var name: String
    public var connectionState: String
    public var hostname: String
    public var ipAddress: String
    public var userAgent: String
    public var version: String
    public var creator: User?
    public var createdAt: Date
    public var job: Job?
    public var lastJobFinishedAt: Date?
    public var priority: Int?
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
