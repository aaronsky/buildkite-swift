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

    public struct Command: Codable, Equatable, Hashable, Identifiable, Sendable {
        public struct AgentRef: Codable, Equatable, Hashable, Sendable {
            public var id: UUID
            public var name: String
            public var url: URL
        }

        public var type = "script"
        public var id: UUID
        public var graphqlId: String
        public var name: String?
        public var state: String?
        public var command: String?
        public var stepKey: String?
        public var buildURL: URL
        public var webURL: URL
        public var logURL: Followable<Job.Resources.LogOutput>
        public var rawLogURL: Followable<Job.Resources.LogOutput.Alternative>
        public var artifactsURL: URL
        public var softFailed: Bool
        public var exitStatus: Int?
        public var artifactPaths: String?
        public var agentQueryRules: [String]
        public var agent: AgentRef?
        public var createdAt: Date
        public var scheduledAt: Date?
        public var runnableAt: Date?
        public var startedAt: Date?
        public var finishedAt: Date?
        public var retried: Bool
        public var retriedInJobId: UUID?
        public var retriesCount: Int?
        public var parallelGroupIndex: Int?
        public var parallelGroupTotal: Int?

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

    public struct Wait: Codable, Equatable, Hashable, Identifiable, Sendable {
        public var type = "waiter"
        public var id: UUID
        public var graphqlId: String

        private enum CodingKeys: String, CodingKey {
            case type
            case id
            case graphqlId = "graphql_id"
        }
    }

    public struct Block: Codable, Equatable, Hashable, Identifiable, Sendable {
        public var type = "manual"
        public var id: UUID
        public var graphqlId: String
        public var label: String
        public var state: String
        public var webURL: URL?
        public var unblockedBy: User?
        public var unblockedAt: Date?
        public var unblockable: Bool
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

    public struct Trigger: Codable, Equatable, Hashable, Sendable {
        public struct TriggeredBuild: Codable, Equatable, Hashable, Identifiable, Sendable {
            public var id: UUID
            public var number: Int
            public var url: URL
            public var webURL: URL

            private enum CodingKeys: String, CodingKey {
                case id
                case number
                case url
                case webURL = "web_url"
            }
        }

        public var type = "trigger"
        public var name: String?
        public var state: String?
        public var buildURL: URL
        public var webURL: URL
        public var createdAt: Date
        public var scheduledAt: Date?
        public var finishedAt: Date?
        public var runnableAt: Date?
        public var triggeredBuild: TriggeredBuild?

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

    public struct LogOutput: Codable, Equatable, Hashable, Sendable {
        public var url: Followable<Job.Resources.LogOutput>
        public var content: String
        public var size: Int
        public var headerTimes: [Int]

        private enum CodingKeys: String, CodingKey {
            case url
            case content
            case size
            case headerTimes = "header_times"
        }
    }

    public struct EnvironmentVariables: Codable, Equatable, Hashable, Sendable {
        public var env: [String: String]
    }
}
