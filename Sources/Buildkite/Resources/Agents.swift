//
//  Agents.swift
//  
//
//  Created by Aaron Sky on 4/21/20.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Agent {
    public enum Resources { }
}

extension Agent.Resources {
    /// List agents
    ///
    /// Returns a paginated list of an organization’s agents.
    public struct List: Resource, HasResponseBody {
        public typealias Content = [Agent]
        /// organization slug
        public var organization: String

        public var path: String {
            "organizations/\(organization)/agents"
        }
        
        public init(organization: String) {
            self.organization = organization
        }
    }

    public struct Get: Resource, HasResponseBody {
        public typealias Content = Agent
        /// organization slug
        public var organization: String
        /// agent ID
        public var agentId: UUID

        public var path: String {
            "organizations/\(organization)/agents/\(agentId)"
        }
        
        public init(organization: String, agentId: UUID) {
            self.organization = organization
            self.agentId = agentId
        }
    }

    /// Stop an agent
    ///
    /// Instruct an agent to stop accepting new build jobs and shut itself down.
    public struct Stop: Resource {
        public typealias Content = Void
        /// organization slug
        public var organization: String
        /// agent ID
        public var agentId: UUID
        public var force: Bool?

        public var path: String {
            "organizations/\(organization)/agents/\(agentId)/stop"
        }
        
        public init(organization: String, agentId: UUID, force: Bool? = nil) {
            self.organization = organization
            self.agentId = agentId
            self.force = force
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "PUT"
            guard let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return
            }
            var queryItems: [URLQueryItem] = []
            queryItems.appendIfNeeded(force, forKey: "force")
            components.queryItems = queryItems
            request.url = components.url
        }
    }
}
