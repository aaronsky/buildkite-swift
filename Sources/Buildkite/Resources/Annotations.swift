//
//  Annotations.swift
//  
//
//  Created by Aaron Sky on 4/21/20.
//

import Foundation

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

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/annotations"
        }
        
        public init(organization: String, pipeline: String, build: Int) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
        }
    }
}
