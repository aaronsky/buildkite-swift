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

        public var userId: UUID?
        
        public var pageOptions: PageOptions?
        
        public var path: String {
            "organizations/\(organization)/teams"
        }
        
        public init(organization: String, userId: UUID? = nil, pageOptions: PageOptions? = nil) {
            self.organization = organization
            self.userId = userId
            self.pageOptions = pageOptions
        }
        
        public func transformRequest(_ request: inout URLRequest) {
            guard let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return
            }
            var queryItems: [URLQueryItem] = []
            queryItems.appendIfNeeded(userId, forKey: "user_id")
            if let options = pageOptions {
                queryItems.append(pageOptions: options)
            }
            components.queryItems = queryItems
            request.url = components.url
        }
    }
}
