//
//  Build.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Build: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var graphqlId: String
    public var url: Followable<Build.Resources.Get>
    public var webURL: URL
    public var number: Int
    public var state: State
    public var blocked: Bool
    public var message: String?
    public var commit: String
    public var branch: String
    public var env: [String: String]?
    public var source: String
    public var creator: User?
    public var jobs: [Job]
    public var createdAt: Date
    public var scheduledAt: Date?
    public var startedAt: Date?
    public var finishedAt: Date?
    public var metaData: [String: String]
    public var pullRequest: [String: String?]?
    public var pipeline: Pipeline

    public enum State: String, Codable, Equatable, Hashable, Sendable {
        case running
        case scheduled
        case passed
        case failed
        case blocked
        case canceled
        case canceling
        case skipped
        case notRun = "not_run"
        case finished
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case graphqlId = "graphql_id"
        case url
        case webURL = "web_url"
        case number
        case state
        case blocked
        case message
        case commit
        case branch
        case env
        case source
        case creator
        case jobs
        case createdAt = "created_at"
        case scheduledAt = "scheduled_at"
        case startedAt = "started_at"
        case finishedAt = "finished_at"
        case metaData = "meta_data"
        case pullRequest = "pull_request"
        case pipeline
    }
}
