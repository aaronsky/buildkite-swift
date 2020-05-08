//
//  Jobs.swift
//  Buildkite
//
//  Created by Aaron Sky on 4/21/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Job {
    public enum Resources { }
}

extension Job.Resources {
    /// Retry a job
    ///
    /// Retries a `failed` or `timed_out` job.
    public struct Retry: Resource, HasResponseBody {
        public typealias Content = Job
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int
        /// job ID
        public var job: UUID

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/jobs/\(job)/retry"
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "PUT"
        }

        public init(organization: String, pipeline: String, build: Int, job: UUID) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.job = job
        }
    }

    /// Unblock a job
    ///
    /// Unblocks a build’s "Block pipeline" job. The job’s `unblockable` property indicates whether it is able to be unblocked, and the `unblock_url` property points to this endpoint.
    public struct Unblock: Resource, HasRequestBody, HasResponseBody {
        public typealias Content = Job
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int
        /// job ID
        public var job: UUID
        /// body of the request
        public var body: Body

        public struct Body: Codable {
            public var unblocker: UUID?
            public var fields: [String: String]

            public init(unblocker: UUID? = nil, fields: [String: String] = [:]) {
                self.unblocker = unblocker
                self.fields = fields
            }
        }

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/jobs/\(job)/unblock"
        }

        public init(organization: String, pipeline: String, build: Int, job: UUID, body: Job.Resources.Unblock.Body) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.job = job
            self.body = body
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "PUT"
        }
    }

    /// Get a job’s log output
    public struct LogOutput: Resource, HasResponseBody {
        public typealias Content = Job.LogOutput
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int
        /// job ID
        public var job: UUID

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/jobs/\(job)/log"
        }

        public init(organization: String, pipeline: String, build: Int, job: UUID) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.job = job
        }
    }

    /// Delete a job’s log output
    public struct DeleteLogOutput: Resource {
        public typealias Content = Void
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int
        /// job ID
        public var job: UUID

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/jobs/\(job)/log"
        }

        public init(organization: String, pipeline: String, build: Int, job: UUID) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.job = job
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "DELETE"
        }
    }

    /// Get a job's environment variables
    public struct EnvironmentVariables: Resource, HasResponseBody {
        public typealias Content = Job.EnvironmentVariables
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int
        /// job ID
        public var job: UUID

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/jobs/\(job)/env"
        }

        public init(organization: String, pipeline: String, build: Int, job: UUID) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.job = job
        }
    }
}

// JSONDecoder on Linux does not support decoding JSON fragments. Another
// method will need to be explored here in order to restore this functionality.
#if !os(Linux)
extension Job.Resources.LogOutput {
    public struct Alternative: Resource, HasResponseBody {
        public enum Format: String {
            case html
            case plainText = "txt"
        }

        public typealias Content = String
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int
        /// job ID
        public var job: UUID

        public var format: Format

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/jobs/\(job)/log.\(format)"
        }

        public init(organization: String, pipeline: String, build: Int, job: UUID, format: Format) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.job = job
            self.format = format
        }
    }
}
#endif
