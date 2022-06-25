//
//  Agents.swift
//  Buildkite
//
//  Created by Aaron Sky on 4/21/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Agent {
    /// Resources for performing operations to the active Buildkite agents.
    public enum Resources {}
}

extension Agent.Resources {
    /// List agents in the organization
    ///
    /// Returns a paginated list of an organization’s agents.
    public struct List: PaginatedResource, Equatable, Hashable, Sendable {
        public typealias Content = [Agent]
        /// organization slug
        public var organization: String

        /// Filters the results by the given agent name
        public var name: String?
        /// Filters the results by the given hostname
        public var hostname: String?
        /// Filters the results by the given exact version number
        public var version: String?

        public var path: String {
            "organizations/\(organization)/agents"
        }

        public init(
            organization: String
        ) {
            self.organization = organization
        }

        public func transformRequest(_ request: inout URLRequest) {
            guard let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else {
                return
            }
            var queryItems: [URLQueryItem] = []
            queryItems.appendIfNeeded(name, forKey: "name")
            queryItems.appendIfNeeded(hostname, forKey: "hostname")
            queryItems.appendIfNeeded(version, forKey: "version")
            components.queryItems = queryItems
            request.url = components.url
        }
    }

    /// Get an agent by ID
    public struct Get: Resource, Equatable, Hashable, Sendable {
        public typealias Content = Agent
        /// organization slug
        public var organization: String
        /// agent ID
        public var agentId: UUID

        public var path: String {
            "organizations/\(organization)/agents/\(agentId)"
        }

        public init(
            organization: String,
            agentId: UUID
        ) {
            self.organization = organization
            self.agentId = agentId
        }
    }

    /// Stop an agent by ID
    ///
    /// Instruct an agent to stop accepting new build jobs and shut itself down.
    public struct Stop: Resource, Equatable, Hashable, Sendable {
        /// organization slug
        public var organization: String
        /// agent ID
        public var agentId: UUID
        /// body of the request
        public var body: Body

        public struct Body: Codable, Equatable, Hashable, Sendable {
            /// If the agent is currently processing a job, the job and the build will be canceled.
            public var force: Bool?

            public init(
                force: Bool? = nil
            ) {
                self.force = force
            }
        }

        public var path: String {
            "organizations/\(organization)/agents/\(agentId)/stop"
        }

        public init(
            organization: String,
            agentId: UUID,
            force: Bool? = nil
        ) {
            self.organization = organization
            self.agentId = agentId
            self.body = Body(force: force)
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "PUT"
        }
    }
}

extension Resource where Self == Agent.Resources.List {
    /// List agents in the organization
    ///
    /// Returns a paginated list of an organization’s agents.
    public static func agents(in organization: String) -> Self {
        Self(organization: organization)
    }
}

extension Resource where Self == Agent.Resources.Get {
    /// Get an agent by ID
    public static func agent(_ agentId: UUID, in organization: String) -> Self {
        Self(organization: organization, agentId: agentId)
    }
}

extension Resource where Self == Agent.Resources.Stop {
    /// Stop an agent by ID
    ///
    /// Instruct an agent to stop accepting new build jobs and shut itself down.
    public static func stopAgent(_ agentId: UUID, in organization: String, force: Bool? = nil) -> Self {
        Self(organization: organization, agentId: agentId, force: force)
    }
}
