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

extension AgentMetrics {
    /// Resources for requesting information about your organization's Buildkite agents.
    public enum Resources {}
}

extension AgentMetrics.Resources {
    /// Get metrics about agents active with the current organization.
    public struct Get: Resource {
        public typealias Content = AgentMetrics

        public var version: APIVersion {
            APIVersion.Agent.v3
        }

        public let path = "metrics"

        public init() {}
    }
}

extension Resource where Self == AgentMetrics.Resources.Get {
    /// Get an object with properties describing Buildkite
    ///
    /// Returns meta information about Buildkite.
    public static var agentMetrics: Self {
        Self()
    }
}
