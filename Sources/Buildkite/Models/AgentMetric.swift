//
//  AgentMetrics.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/5/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct AgentMetrics: Codable, Equatable {
    public var agents: AgentTotals
    public var jobs: JobTotals
    public var organization: Organization

    public struct AgentTotals: Codable, Equatable {
        public var idle: Int
        public var busy: Int
        public var total: Int
        public var queues: [String: Int]
    }

    public struct JobTotals: Codable, Equatable {
        public var scheduled: Int
        public var running: Int
        public var waiting: Int
        public var total: Int
        public var queues: [String: Int]
    }

    public struct Organization: Codable, Equatable {
        public var slug: String
    }
}
