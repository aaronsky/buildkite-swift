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
    public enum Resources {}
}

extension Job.Resources {
    /// Retry a job
    ///
    /// Retries a `failed` or `timed_out` job.
    public struct Retry: Resource, Equatable, Hashable, Sendable {
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

        public init(
            organization: String,
            pipeline: String,
            build: Int,
            job: UUID
        ) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.job = job
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "PUT"
        }
    }

    /// Unblock a job
    ///
    /// Unblocks a build’s "Block pipeline" job. The job’s `unblockable` property indicates whether it is able to be unblocked, and the `unblock_url` property points to this endpoint.
    public struct Unblock: Resource, Equatable, Hashable, Sendable {
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

        public struct Body: Codable, Equatable, Hashable, Sendable {
            public var unblocker: UUID?
            public var fields: [String: String]

            public init(
                unblocker: UUID? = nil,
                fields: [String: String] = [:]
            ) {
                self.unblocker = unblocker
                self.fields = fields
            }
        }

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/jobs/\(job)/unblock"
        }

        public init(
            organization: String,
            pipeline: String,
            build: Int,
            job: UUID,
            body: Body
        ) {
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
    public struct LogOutput: Resource, Equatable, Hashable, Sendable {
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

        public init(
            organization: String,
            pipeline: String,
            build: Int,
            job: UUID
        ) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.job = job
        }
    }

    /// Delete a job’s log output
    public struct DeleteLogOutput: Resource, Equatable, Hashable, Sendable {
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

        public init(
            organization: String,
            pipeline: String,
            build: Int,
            job: UUID
        ) {
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
    public struct EnvironmentVariables: Resource, Equatable, Hashable, Sendable {
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

        public init(
            organization: String,
            pipeline: String,
            build: Int,
            job: UUID
        ) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.job = job
        }
    }
}

extension Job.Resources.LogOutput {
    /// Get a job’s log output in an alternative format.
    public struct Alternative: Resource, Equatable, Hashable, Sendable {
        public enum Format: String, Equatable, Hashable, Sendable {
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

        public init(
            organization: String,
            pipeline: String,
            build: Int,
            job: UUID,
            format: Format
        ) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
            self.job = job
            self.format = format
        }
    }
}

extension Resource where Self == Job.Resources.Retry {
    /// Retry a job
    ///
    /// Retries a `failed` or `timed_out` job.
    public static func retryJob(_ job: UUID, in organization: String, pipeline: String, build: Int) -> Self {
        Self(organization: organization, pipeline: pipeline, build: build, job: job)
    }
}

extension Resource where Self == Job.Resources.Unblock {
    /// Unblock a job
    ///
    /// Unblocks a build’s "Block pipeline" job. The job’s `unblockable` property indicates whether it is able to be unblocked, and the `unblock_url` property points to this endpoint.
    public static func unblockJob(
        _ job: UUID,
        in organization: String,
        pipeline: String,
        build: Int,
        with body: Self.Body
    ) -> Self {
        Self(organization: organization, pipeline: pipeline, build: build, job: job, body: body)
    }
}

extension Resource where Self == Job.Resources.LogOutput {
    /// Get a job’s log output
    public static func logOutput(for job: UUID, in organization: String, pipeline: String, build: Int) -> Self {
        Self(organization: organization, pipeline: pipeline, build: build, job: job)
    }
}

extension Resource where Self == Job.Resources.LogOutput.Alternative {
    /// Get a job’s log output in an alternative format.
    public static func logOutput(
        _ format: Job.Resources.LogOutput.Alternative.Format,
        for job: UUID,
        in organization: String,
        pipeline: String,
        build: Int
    ) -> Self {
        Self(organization: organization, pipeline: pipeline, build: build, job: job, format: format)
    }
}

extension Resource where Self == Job.Resources.DeleteLogOutput {
    /// Delete a job’s log output
    public static func deleteLogOutput(for job: UUID, in organization: String, pipeline: String, build: Int) -> Self {
        Self(organization: organization, pipeline: pipeline, build: build, job: job)
    }
}

extension Resource where Self == Job.Resources.EnvironmentVariables {
    /// Get a job's environment variables
    public static func environmentVariables(
        for job: UUID,
        in organization: String,
        pipeline: String,
        build: Int
    ) -> Self {
        Self(organization: organization, pipeline: pipeline, build: build, job: job)
    }
}
