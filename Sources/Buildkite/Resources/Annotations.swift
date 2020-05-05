//
//  Annotations.swift
//  
//
//  Created by Aaron Sky on 4/21/20.
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
    public struct List: Resource, HasResponseBody {
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
        
        public init(organization: String, pipeline: String, build: Int) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
        }
        
        public func transformRequest(_ request: inout URLRequest) {
            guard let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return
            }
            if let options = pageOptions {
                components.queryItems = [URLQueryItem](options: options)
            }
            request.url = components.url
        }
    }
}
