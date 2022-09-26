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

/// Metrics concerning the agents connected and how much work is being done.
public struct AgentMetrics: Codable, Equatable, Hashable, Sendable {
    /// Agents connected to Buildkite.
    public var agents: AgentTotals
    /// Jobs running in the organization.
    public var jobs: JobTotals
    /// Organization slug.
    public var organization: Organization

    public init(
        agents: AgentTotals,
        jobs: JobTotals,
        organization: Organization
    ) {
        self.agents = agents
        self.jobs = jobs
        self.organization = organization
    }

    /// Agents connected to Buildkite.
    public struct AgentTotals: Codable, Equatable, Hashable, Sendable {
        /// Number of idle agents.
        public var idle: Int
        /// Number of busy agents.
        public var busy: Int
        /// Total number of agents.
        public var total: Int
        /// Breakdown of agent workloads by the special `queue` agent tag.
        public var queues: [String: AgentTotals] = [:]

        public init(
            idle: Int,
            busy: Int,
            total: Int,
            queues: [String: AgentTotals]
        ) {
            self.idle = idle
            self.busy = busy
            self.total = total
            self.queues = queues
        }
    }

    /// Jobs running in the organization.
    public struct JobTotals: Codable, Equatable, Hashable, Sendable {
        /// Number of scheduled jobs.
        public var scheduled: Int
        /// Number of running jobs.
        public var running: Int
        /// Number of waiting jobs.
        public var waiting: Int
        /// Total number of jobs.
        public var total: Int
        /// Breakdown of jobs in-flight by the special `queue` agent tag.
        public var queues: [String: JobTotals] = [:]

        public init(
            scheduled: Int,
            running: Int,
            waiting: Int,
            total: Int,
            queues: [String: JobTotals]
        ) {
            self.scheduled = scheduled
            self.running = running
            self.waiting = waiting
            self.total = total
            self.queues = queues
        }
    }

    /// Organization slug.
    public struct Organization: Codable, Equatable, Hashable, Sendable {
        /// Organization slug.
        public var slug: String

        public init(
            slug: String
        ) {
            self.slug = slug
        }
    }
}
