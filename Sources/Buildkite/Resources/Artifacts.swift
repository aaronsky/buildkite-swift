//
//  Artifacts.swift
//  
//
//  Created by Aaron Sky on 4/21/20.
//

import Foundation

extension Artifact {
    enum Resources { }
}

extension Artifact.Resources {
    /// List artifacts for a build
    ///
    /// Returns a paginated list of a build’s artifacts across all of its jobs.
    struct ListByBuild: Resource, HasResponseBody {
        typealias Content = [Artifact]
        /// organization slug
        var organization: String
        /// pipeline slug
        var pipeline: String
        /// build number
        var build: Int

        var path: String {
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
    struct ListByJob: Resource, HasResponseBody {
        typealias Content = [Artifact]
        /// organization slug
        var organization: String
        /// pipeline slug
        var pipeline: String
        /// build number
        var build: Int
        /// job ID
        var jobId: UUID

        var path: String {
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
    struct Get: Resource, HasResponseBody {
        typealias Content = Artifact
        /// organization slug
        var organization: String
        /// pipeline slug
        var pipeline: String
        /// build number
        var build: Int
        /// job ID
        var jobId: UUID
        /// artifact ID
        var artifactId: UUID

        var path: String {
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
    struct Download: Resource {
        typealias Content = Artifact.URLs
        /// organization slug
        var organization: String
        /// pipeline slug
        var pipeline: String
        /// build number
        var build: Int
        /// job ID
        var jobId: UUID
        /// artifact ID
        var artifactId: UUID

        var path: String {
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
    struct Delete: Resource {
        typealias Content = Void
        /// organization slug
        var organization: String
        /// pipeline slug
        var pipeline: String
        /// build number
        var build: Int
        /// job ID
        var jobId: UUID
        /// artifact ID
        var artifactId: UUID

        var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/jobs/\(jobId)/artifacts/\(artifactId)"
        }

        func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "DELETE"
        }
        
        public init(organization: String, pipeline: String, build: Int, jobId: UUID, artifactId: UUID) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.jobId = jobId
            self.artifactId = artifactId
        }
    }
}
