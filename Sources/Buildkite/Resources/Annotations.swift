//
//  Annotations.swift
//  Buildkite
//
//  Created by Aaron Sky on 4/21/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Annotation {
    public enum Resources { }
}

extension Annotation.Resources {
    /// List annotations for a build
    ///
    /// Returns a paginated list of a build’s annotations.
    public struct List: Resource, HasResponseBody, Paginated {
        public typealias Content = [Annotation]
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int
        
        public var pageOptions: PageOptions?
        
        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/annotations"
        }
        
        public init(organization: String, pipeline: String, build: Int, pageOptions: PageOptions? = nil) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
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
}
