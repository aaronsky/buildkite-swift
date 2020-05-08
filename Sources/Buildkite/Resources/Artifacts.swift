//
//  Artifacts.swift
//  Buildkite
//
//  Created by Aaron Sky on 4/21/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Artifact {
    public enum Resources { }
}

extension Artifact.Resources {
    /// List artifacts for a build
    ///
    /// Returns a paginated list of a build’s artifacts across all of its jobs.
    public struct ListByBuild: Resource, HasResponseBody, Paginated {
        public typealias Content = [Artifact]
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int
                
        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/artifacts"
        }
        
        public init(organization: String, pipeline: String, build: Int) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
        }
    }

    /// List artifacts for a job
    ///
    /// Returns a paginated list of a job’s artifacts.
    public struct ListByJob: Resource, HasResponseBody, Paginated {
        public typealias Content = [Artifact]
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int
        /// job ID
        public var jobId: UUID
        
        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/jobs/\(jobId)/artifacts"
        }
        
        public init(organization: String, pipeline: String, build: Int, jobId: UUID) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.jobId = jobId
        }
    }

    /// Get an artifact
    public struct Get: Resource, HasResponseBody {
        public typealias Content = Artifact
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int
        /// job ID
        public var jobId: UUID
        /// artifact ID
        public var artifactId: UUID

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/jobs/\(jobId)/artifacts/\(artifactId)"
        }
        
        public init(organization: String, pipeline: String, build: Int, jobId: UUID, artifactId: UUID) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.jobId = jobId
            self.artifactId = artifactId
        }
    }

    /// Download an artifact
    ///
    ///
    public struct Download: Resource, HasResponseBody {
        public typealias Content = Artifact.URLs
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int
        /// job ID
        public var jobId: UUID
        /// artifact ID
        public var artifactId: UUID

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/jobs/\(jobId)/artifacts/\(artifactId)/download"
        }
        
        public init(organization: String, pipeline: String, build: Int, jobId: UUID, artifactId: UUID) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.jobId = jobId
            self.artifactId = artifactId
        }
    }

    /// Delete an artifact
    ///
    ///
    public struct Delete: Resource {
        public typealias Content = Void
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int
        /// job ID
        public var jobId: UUID
        /// artifact ID
        public var artifactId: UUID

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/jobs/\(jobId)/artifacts/\(artifactId)"
        }
        
        public init(organization: String, pipeline: String, build: Int, jobId: UUID, artifactId: UUID) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.jobId = jobId
            self.artifactId = artifactId
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "DELETE"
        }
    }
}
