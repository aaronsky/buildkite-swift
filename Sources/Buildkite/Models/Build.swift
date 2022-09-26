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

/// Information about a build created from a pipeline.
public struct Build: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the build.
    public var id: UUID
    /// ID of the build to be used with the GraphQL API.
    public var graphqlId: String
    /// Followable URL to fetch this specific build.
    public var url: Followable<Build.Resources.Get>
    /// Human-readable URL of this build in the Buildkite dashboard.
    public var webURL: URL
    /// Build number.
    public var number: Int
    /// Build state.
    public var state: State
    /// Whether or not the build is currently blocked.
    public var blocked: Bool
    /// Message text for the build.
    public var message: String?
    /// Commit hash associated with the build.
    public var commit: String
    /// Branch or symbolic reference associated with the build.
    public var branch: String
    /// Environment variables configured for the build.
    public var env: [String: String]?
    /// Method the build was created via.
    public var source: String
    /// User responsible for creating the build, if any.
    public var creator: User?
    /// Jobs that are part of the build.
    public var jobs: [Job]
    /// When the build was created.
    public var createdAt: Date
    /// When the build was scheduled.
    public var scheduledAt: Date?
    /// When the build started.
    public var startedAt: Date?
    /// When the build finished.
    public var finishedAt: Date?
    /// Meta-data assigned to the build. Meta-data is created using the [buildkite-agent meta-data command](https://buildkite.com/docs/agent/v3/cli-meta-data) from within a job.
    public var metaData: [String: String]
    /// Pull request associated with the build, if any.
    public var pullRequest: [String: String?]?
    /// Pipeline the build was created from.
    public var pipeline: Pipeline

    public init(
        id: UUID,
        graphqlId: String,
        url: Followable<Build.Resources.Get>,
        webURL: URL,
        number: Int,
        state: State,
        blocked: Bool,
        message: String? = nil,
        commit: String,
        branch: String,
        env: [String: String]? = nil,
        source: String,
        creator: User? = nil,
        jobs: [Job],
        createdAt: Date,
        scheduledAt: Date? = nil,
        startedAt: Date? = nil,
        finishedAt: Date? = nil,
        metaData: [String: String],
        pullRequest: [String: String?]? = nil,
        pipeline: Pipeline
    ) {
        self.id = id
        self.graphqlId = graphqlId
        self.url = url
        self.webURL = webURL
        self.number = number
        self.state = state
        self.blocked = blocked
        self.message = message
        self.commit = commit
        self.branch = branch
        self.env = env
        self.source = source
        self.creator = creator
        self.jobs = jobs
        self.createdAt = createdAt
        self.scheduledAt = scheduledAt
        self.startedAt = startedAt
        self.finishedAt = finishedAt
        self.metaData = metaData
        self.pullRequest = pullRequest
        self.pipeline = pipeline
    }

    /// The state of the build and its jobs.
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
