//
//  Organizations.swift
//  Buildkite
//
//  Created by Aaron Sky on 4/21/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Organization {
    public enum Resources { }
}

extension Organization.Resources {
    /// List organizations
    ///
    /// Returns a paginated list of the user’s organizations.
    public struct List: Resource, HasResponseBody, Paginated {
        public typealias Content = [Organization]
        public let path = "organizations"
        
        public var pageOptions: PageOptions?
        
        public init(pageOptions: PageOptions? = nil) {
            self.pageOptions = pageOptions
        }
        
        public func transformRequest(_ request: inout URLRequest) {
            guard let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return
            }
            var queryItems: [URLQueryItem] = []
            if let options = pageOptions {
                queryItems.append(pageOptions: options)
            }
            components.queryItems = queryItems
            request.url = components.url
        }
    }

    /// Get an organization
    public struct Get: Resource, HasResponseBody {
        public typealias Content = Organization
        /// organization slug
        public var organization: String

        public var path: String {
            "organizations/\(organization)"
        }
        
        public init(organization: String) {
            self.organization = organization
        }
    }

}
