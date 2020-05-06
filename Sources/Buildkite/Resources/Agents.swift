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

        /// Filters the results by the given agent name
        public var name: String?
        /// Filters the results by the given hostname
        public var hostname: String?
        /// Filters the results by the given exact version number
        public var version: String?
        
        public var pageOptions: PageOptions?
        
        public var path: String {
            "organizations/\(organization)/agents"
        }
        
        public init(organization: String) {
            self.organization = organization
        }
        
        public func transformRequest(_ request: inout URLRequest) {
            guard let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return
            }
            var queryItems: [URLQueryItem] = []
            queryItems.appendIfNeeded(name, forKey: "name")
            queryItems.appendIfNeeded(hostname, forKey: "hostname")
            queryItems.appendIfNeeded(version, forKey: "version")
            if let options = pageOptions {
                queryItems.append(contentsOf: [URLQueryItem](pageOptions: options))
            }
            components.queryItems = queryItems
            request.url = components.url
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
    public struct Stop: Resource, HasRequestBody {
        public typealias Content = Void
        /// organization slug
        public var organization: String
        /// agent ID
        public var agentId: UUID
        /// body of the request
        public var body: Body
        
        public struct Body: Codable {
            /// If the agent is currently processing a job, the job and the build will be canceled.
            public var force: Bool?
        }

        public var path: String {
            "organizations/\(organization)/agents/\(agentId)/stop"
        }
        
        public init(organization: String, agentId: UUID, body: Agent.Resources.Stop.Body) {
            self.organization = organization
            self.agentId = agentId
            self.body = body
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "PUT"
        }
    }
}
