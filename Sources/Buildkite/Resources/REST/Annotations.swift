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
    public enum Resources {}
}

extension Annotation.Resources {
    /// List annotations for a build
    ///
    /// Returns a paginated list of a build’s annotations.
    public struct List: PaginatedResource, Equatable, Hashable, Sendable {
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

        public init(
            organization: String,
            pipeline: String,
            build: Int
        ) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
        }
    }
}

extension Resource where Self == Annotation.Resources.List {
    public static func annotations(in organization: String, pipeline: String, build: Int) -> Self {
        Self(organization: organization, pipeline: pipeline, build: build)
    }
}
