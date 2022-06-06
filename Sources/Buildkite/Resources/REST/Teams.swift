//
//  Teams.swift
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
    /// Resources for managing Buildkite teams.
    public enum Resources {}
}

extension Team.Resources {
    /// List all teams in the given organization
    public struct List: PaginatedResource {
        public typealias Content = [Team]
        /// organization slug
        public var organization: String
        /// Filters the results to teams that have the given user as a member.
        public var userId: UUID?

        public var path: String {
            "organizations/\(organization)/teams"
        }

        public init(
            organization: String,
            userId: UUID? = nil
        ) {
            self.organization = organization
            self.userId = userId
        }

        public func transformRequest(_ request: inout URLRequest) {
            guard let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
            else {
                return
            }
            var queryItems: [URLQueryItem] = []
            queryItems.appendIfNeeded(userId, forKey: "user_id")
            components.queryItems = queryItems
            request.url = components.url
        }
    }
}

extension Resource where Self == Team.Resources.List {
    /// List all teams in the given organization
    public static func teams(in organization: String, byUser userId: UUID? = nil) -> Self {
        Self(organization: organization, userId: userId)
    }
}
