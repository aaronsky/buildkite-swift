//
//  File.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/6/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Team {
    public enum Resources { }
}

extension Team.Resources {
    public struct List: Resource, HasResponseBody, Paginated {
        public typealias Content = [Team]
        /// organization slug
        public var organization: String
        /// Filters the results to teams that have the given user as a member.
        public var userId: UUID?

        public var path: String {
            "organizations/\(organization)/teams"
        }

        public init(organization: String, userId: UUID? = nil) {
            self.organization = organization
            self.userId = userId
        }

        public func transformRequest(_ request: inout URLRequest) {
            guard let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return
            }
            var queryItems: [URLQueryItem] = []
            queryItems.appendIfNeeded(userId, forKey: "user_id")
            components.queryItems = queryItems
            request.url = components.url
        }
    }
}
