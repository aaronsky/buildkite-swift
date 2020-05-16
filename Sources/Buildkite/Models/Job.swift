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

public enum Job: Codable, Equatable {
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

    public init(from decoder: Decoder) throws {
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

    public struct Command: Codable, Equatable, Identifiable {
        public struct AgentRef: Codable, Equatable {
            public var id: UUID
            public var name: String
            public var url: URL
        }
        public let type = "script"
        public var id: UUID
        public var name: String
        public var state: String
        public var command: String?
        public var stepKey: String?
        public var buildUrl: URL
        public var webUrl: URL
        public var logUrl: URL // Resource<Job.Resources.GetLogOutput>
        public var rawLogUrl: URL // Resource<Job.Resources.GetLogOutput>
        public var artifactsUrl: URL
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
    }

    public struct Wait: Codable, Equatable, Identifiable {
        public let type = "waiter"
        public var id: UUID
    }

    public struct Block: Codable, Equatable, Identifiable {
        public let type = "manual"
        public var id: UUID
        public var label: String
        public var state: String
        public var webUrl: URL?
        public var unblockedBy: User
        public var unblockedAt: Date
        public var unblockable: Bool
        public var unblockUrl: URL
    }

    public struct Trigger: Codable, Equatable {
        public let type = "trigger"
        public var name: String
        public var state: String
        public var buildUrl: URL
        public var webUrl: URL
        public var createdAt: Date
        public var scheduledAt: Date?
        public var finishedAt: Date?
        public var runnableAt: Date?
        public var triggeredBuild: TriggeredBuild

        public struct TriggeredBuild: Codable, Equatable, Identifiable {
            public var id: UUID
            public var number: Int
            public var url: URL
            public var webUrl: URL
        }
    }

    public struct LogOutput: Codable, Equatable {
        public var url: URL // Resource<Job.Resources.GetLogOutput>
        public var content: String
        public var size: Int
        public var headerTimes: [Int]
    }

    public struct EnvironmentVariables: Codable, Equatable {
        public var env: [String: String]
    }
}
