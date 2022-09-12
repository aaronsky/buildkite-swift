//
//  Job.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Information about a job created as part of a build.
public enum Job: Codable, Equatable, Hashable, Sendable {
    case script(Command)
    case waiter(Wait)
    case manual(Block)
    case trigger(Trigger)

    private enum Unassociated: String, Codable {
        case script
        case waiter
        case manual
        case trigger
    }

    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Unassociated.self, forKey: .type)
        switch type {
        case .script:
            self = .script(try Command(from: decoder))
        case .waiter:
            self = .waiter(try Wait(from: decoder))
        case .manual:
            self = .manual(try Block(from: decoder))
        case .trigger:
            self = .trigger(try Trigger(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .script(let step):
            try step.encode(to: encoder)
        case .waiter(let step):
            try step.encode(to: encoder)
        case .manual(let step):
            try step.encode(to: encoder)
        case .trigger(let step):
            try step.encode(to: encoder)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type
    }

    /// Command job.
    public struct Command: Codable, Equatable, Hashable, Identifiable, Sendable {
        /// Type of the job. Always `"script"`.
        public var type = "script"
        /// ID of the job.
        public var id: UUID
        /// ID of the job to be used with the GraphQL API.
        public var graphqlId: String
        /// Name of the job.
        public var name: String?
        /// Job state.
        public var state: String?
        /// Command(s) the job will run.
        public var command: String?
        /// A key to reference the job by using the [buildkite-agent step command](https://buildkite.com/docs/agent/v3/cli-step).
        public var stepKey: String?
        /// Build URL.
        public var buildURL: URL
        /// Human-readable URL of this job in the Buildkite dashboard.
        public var webURL: URL
        /// Followable URL to the job's log output.
        public var logURL: Followable<Job.Resources.LogOutput>
        /// Followable URL to the job's raw log output.
        public var rawLogURL: Followable<Job.Resources.LogOutput.Alternative>
        /// Artifacts URL.
        public var artifactsURL: URL
        /// Whether or not the job can "soft fail".
        public var softFailed: Bool
        /// The exit code the job's command concluded with.
        public var exitStatus: Int?
        /// Artifact paths to files that will be automatically uploaded as artifacts.
        public var artifactPaths: String?
        /// A list of [agent tag](https://buildkite.com/docs/agent/v3/cli-start#setting-tags)
        /// keys to values to [target specific agents](https://buildkite.com/docs/agent/v3/cli-start#agent-targeting)
        /// that this job was configured to target.
        public var agentQueryRules: [String]
        /// The agent this job has been assigned to, if any.
        public var agent: AgentRef?
        /// When the job was created.
        public var createdAt: Date
        /// When the job was scheduled.
        public var scheduledAt: Date?
        /// When the job became runnable.
        public var runnableAt: Date?
        /// When the job was started.
        public var startedAt: Date?
        /// When the job finished.
        public var finishedAt: Date?
        /// Whether or not the job has been retried.
        public var retried: Bool
        /// The ID of the job it was retried into, if any.
        public var retriedInJobId: UUID?
        /// The number of times this job has been retried.
        public var retriesCount: Int?
        /// The index out of parallel executions of this job.
        public var parallelGroupIndex: Int?
        /// Total number of parallel executions of this job.
        public var parallelGroupTotal: Int?

        /// Reference to an agent.
        public struct AgentRef: Codable, Equatable, Hashable, Sendable {
            /// ID of the agent.
            public var id: UUID
            /// Name of the agent.
            public var name: String
            /// Followable URL to the specific agent.
            public var url: Followable<Agent.Resources.Get>
        }

        private enum CodingKeys: String, CodingKey {
            case type
            case id
            case graphqlId = "graphql_id"
            case name
            case state
            case command
            case stepKey = "step_key"
            case buildURL = "build_url"
            case webURL = "web_url"
            case logURL = "log_url"
            case rawLogURL = "raw_log_url"
            case artifactsURL = "artifacts_url"
            case softFailed = "soft_failed"
            case exitStatus = "exit_status"
            case artifactPaths = "artifact_paths"
            case agentQueryRules = "agent_query_rules"
            case agent
            case createdAt = "created_at"
            case scheduledAt = "scheduled_at"
            case runnableAt = "runnable_at"
            case startedAt = "started_at"
            case finishedAt = "finished_at"
            case retried
            case retriedInJobId = "retried_in_job_id"
            case retriesCount = "retries_count"
            case parallelGroupIndex = "parallel_group_index"
            case parallelGroupTotal = "parallel_group_total"
        }
    }

    /// Wait job.
    public struct Wait: Codable, Equatable, Hashable, Identifiable, Sendable {
        /// Type of the job. Always `"waiter"`.
        public var type = "waiter"
        /// ID of the job.
        public var id: UUID
        /// ID of the job to be used with the GraphQL API.
        public var graphqlId: String

        private enum CodingKeys: String, CodingKey {
            case type
            case id
            case graphqlId = "graphql_id"
        }
    }

    /// Block job.
    public struct Block: Codable, Equatable, Hashable, Identifiable, Sendable {
        /// Type of the job. Always `"manual"`.
        public var type = "manual"
        /// ID of the job.
        public var id: UUID
        /// ID of the job to be used with the GraphQL API.
        public var graphqlId: String
        /// Label for the job.
        public var label: String
        /// Job state.
        public var state: String
        /// Human-readable URL of this job in the Buildkite dashboard.
        public var webURL: URL?
        /// User who unblocked this job, if any.
        public var unblockedBy: User?
        /// When this job was unblocked.
        public var unblockedAt: Date?
        /// Whether or not this job can be unblocked.
        public var unblockable: Bool
        /// Human-readable URL to unblock this job.
        public var unblockURL: URL

        private enum CodingKeys: String, CodingKey {
            case type
            case id
            case graphqlId = "graphql_id"
            case label
            case state
            case webURL = "web_url"
            case unblockedBy = "unblocked_by"
            case unblockedAt = "unblocked_at"
            case unblockable
            case unblockURL = "unblock_url"
        }
    }

    /// Trigger job.
    public struct Trigger: Codable, Equatable, Hashable, Sendable {
        /// Type of the job. Always `"trigger"`.
        public var type = "trigger"
        /// Name of the job.
        public var name: String?
        /// Job state.
        public var state: String?
        /// Build URL.
        public var buildURL: URL
        /// Human-readable URL of this job in the Buildkite dashboard.
        public var webURL: URL
        /// When the job was created.
        public var createdAt: Date
        /// When the job was scheduled.
        public var scheduledAt: Date?
        /// When the job finished.
        public var finishedAt: Date?
        /// When the build became runnable.
        public var runnableAt: Date?
        /// Build that was triggered by this job.
        public var triggeredBuild: TriggeredBuild?

        /// Build triggered by this job.
        public struct TriggeredBuild: Codable, Equatable, Hashable, Identifiable, Sendable {
            /// ID of the triggered build.
            public var id: UUID
            /// Build number.
            public var number: Int
            /// Build URL.
            public var url: URL
            /// Human-readable URL to this build in the Buildkite dashboard.
            public var webURL: URL

            private enum CodingKeys: String, CodingKey {
                case id
                case number
                case url
                case webURL = "web_url"
            }
        }

        private enum CodingKeys: String, CodingKey {
            case type
            case name
            case state
            case buildURL = "build_url"
            case webURL = "web_url"
            case createdAt = "created_at"
            case scheduledAt = "scheduled_at"
            case finishedAt = "finished_at"
            case runnableAt = "runnable_at"
            case triggeredBuild = "triggered_build"
        }
    }

    /// Log output from a job.
    public struct LogOutput: Codable, Equatable, Hashable, Sendable {
        /// Followable URL to this specific job's log output.
        public var url: Followable<Job.Resources.LogOutput>
        /// Log content.
        public var content: String
        /// Size of the logs in bytes.
        public var size: Int
        /// Header timestamps.
        public var headerTimes: [Int]

        private enum CodingKeys: String, CodingKey {
            case url
            case content
            case size
            case headerTimes = "header_times"
        }
    }

    /// Environment variables for a job.
    public struct EnvironmentVariables: Codable, Equatable, Hashable, Sendable {
        public var env: [String: String]
    }
}
