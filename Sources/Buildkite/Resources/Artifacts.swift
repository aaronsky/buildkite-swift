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
    public struct ListByBuild: PaginatedResource {
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
    public struct ListByJob: PaginatedResource {
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
    public struct Get: Resource {
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
    public struct Download: Resource {
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

extension Resource where Self == Artifact.Resources.ListByBuild {
    public static func artifacts(byBuild build: Int, in organization: String, pipeline: String) -> Artifact.Resources.ListByBuild {
        .init(organization: organization, pipeline: pipeline, build: build)
    }
}

extension Resource where Self == Artifact.Resources.ListByJob {
    public static func artifacts(byJob job: UUID, in organization: String, pipeline: String, build: Int) -> Artifact.Resources.ListByJob {
        .init(organization: organization, pipeline: pipeline, build: build, jobId: job)
    }
}

extension Resource where Self == Artifact.Resources.Get {
    public static func artifact(_ id: UUID, in organization: String, pipeline: String, build: Int, job: UUID) -> Artifact.Resources.Get {
        .init(organization: organization, pipeline: pipeline, build: build, jobId: job, artifactId: id)
    }
}

extension Resource where Self == Artifact.Resources.Download {
    public static func downloadArtifact(_ id: UUID, in organization: String, pipeline: String, build: Int, job: UUID) -> Artifact.Resources.Download {
        .init(organization: organization, pipeline: pipeline, build: build, jobId: job, artifactId: id)
    }
}

extension Resource where Self == Artifact.Resources.Delete {
    public static func deleteArtifact(_ id: UUID, in organization: String, pipeline: String, build: Int, job: UUID) -> Artifact.Resources.Delete {
        .init(organization: organization, pipeline: pipeline, build: build, jobId: job, artifactId: id)
    }
}
