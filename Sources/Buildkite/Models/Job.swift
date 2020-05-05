//
//  Job.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Fangamer. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Job: Codable, Equatable {
    public struct Agent: Codable, Equatable {
        public var id: UUID
        public var url: URL
        public var name: String
    }

    public var id: UUID
    public var type: String
    public var name: String?
    public var stepKey: String?
    public var agentQueryRules: [String]
    public var state: String?
    public var buildUrl: URL?
    public var webUrl: URL?
    public var logUrl: URL?
    public var rawLogUrl: URL?
    public var artifactsUrl: URL?
    public var command: String?
    public var softFailed: Bool
    public var exitStatus: Int?
    public var artifactPaths: String?
    public var agent: Agent?
    public var createdAt: Date
    public var scheduledAt: Date
    public var runnableAt: Date?
    public var startedAt: Date?
    public var finishedAt: Date?
    public var retried: Bool
    public var retriedInJobId: UUID?
    public var retriesCount: Int?
    public var parallelGroupIndex: Int?
    public var parallelGroupTotal: Int?

    public struct Unblocked: Codable, Equatable {
        public var id: UUID
        public var type: String
        public var label: String
        public var state: String
        public var webUrl: URL?
        public var unblockedBy: User
        public var unblockedAt: Date
        public var unblockable: Bool
        public var unblockUrl: URL
    }

    public struct LogOutput: Codable {
        public var url: URL
        public var content: String
        public var size: Int
        public var headerTimes: [Int]
    }

    public struct EnvironmentVariables: Codable, Equatable {
        public var env: [String: String]
    }
}
