//
//  Builds.swift
//  Buildkite
//
//  Created by Aaron Sky on 4/21/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Build {
    public enum Resources { }
}

extension Build.Resources {
    /// List all builds
    ///
    /// Returns a paginated list of all builds across all the user’s organizations and pipelines. If using token-based authentication
    /// the list of builds will be for the authorized organizations only. Builds are listed in the order they were created (newest first).
    public struct ListAll: PaginatedResource {
        public typealias Content = [Build]
        public let path = "builds"

        public var queryOptions: QueryOptions?

        public init(queryOptions: Build.Resources.QueryOptions? = nil) {
            self.queryOptions = queryOptions
        }

        public func transformRequest(_ request: inout URLRequest) {
            guard let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return
            }
            var queryItems: [URLQueryItem] = []
            if let options = queryOptions {
                queryItems.append(contentsOf: [URLQueryItem](queryOptions: options))
            }
            components.queryItems = queryItems
            request.url = components.url
        }
    }

    /// List builds for an organization
    ///
    /// Returns a paginated list of an organization’s builds across all of an organization’s pipelines. Builds are listed in the order
    /// they were created (newest first).
    public struct ListForOrganization: PaginatedResource {
        public typealias Content = [Build]
        /// organization slug
        public var organization: String

        public var queryOptions: QueryOptions?

        public var path: String {
            "organizations/\(organization)/builds"
        }

        public init(organization: String, queryOptions: Build.Resources.QueryOptions? = nil) {
            self.organization = organization
            self.queryOptions = queryOptions
        }

        public func transformRequest(_ request: inout URLRequest) {
            guard let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return
            }
            var queryItems: [URLQueryItem] = []
            if let options = queryOptions {
                queryItems.append(contentsOf: [URLQueryItem](queryOptions: options))
            }
            components.queryItems = queryItems
            request.url = components.url
        }
    }

    /// List builds for a pipeline
    ///
    /// Returns a paginated list of a pipeline’s builds. Builds are listed in the order they were created (newest first).
    public struct ListForPipeline: PaginatedResource {
        public typealias Content = [Build]
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String

        public var queryOptions: QueryOptions?

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds"
        }

        public init(organization: String, pipeline: String, queryOptions: Build.Resources.QueryOptions? = nil) {
            self.organization = organization
            self.pipeline = pipeline
            self.queryOptions = queryOptions
        }

        public func transformRequest(_ request: inout URLRequest) {
            guard let url = request.url,
                var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                    return
            }
            var queryItems: [URLQueryItem] = []
            if let options = queryOptions {
                queryItems.append(contentsOf: [URLQueryItem](queryOptions: options))
            }
            components.queryItems = queryItems
            request.url = components.url
        }
    }

    /// Get a build
    public struct Get: Resource {
        public typealias Content = Build
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)"
        }

        public init(organization: String, pipeline: String, build: Int) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
        }
    }

    /// Create a build
    public struct Create: Resource {
        public typealias Content = Build
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// body of the request
        public var body: Body

        public struct Body: Codable {
            public struct Author: Codable {
                public var name: String
                public var email: String

                public init(name: String, email: String) {
                    self.name = name
                    self.email = email
                }
            }

            /// Ref, SHA or tag to be built.
            public var commit: String
            /// Branch the commit belongs to. This allows you to take advantage of your pipeline and step-level branch filtering rules.
            public var branch: String

            /// A hash with a "name" and "email" key to show who created this build.
            public var author: Author?
            /// Force the agent to remove any existing build directory and perform a fresh checkout.
            public var cleanCheckout: Bool?
            /// Environment variables to be made available to the build.
            public var env: [String: String]?
            /// Run the build regardless of the pipeline’s branch filtering rules. Step branch filtering rules will still apply.
            public var ignorePipelineBranchFilters: Bool?
            /// Message for the build.
            public var message: String?
            /// A hash of meta-data to make available to the build.
            public var metaData: [String: String]?
            /// For a pull request build, the base branch of the pull request.
            public var pullRequestBaseBranch: String?
            /// For a pull request build, the pull request number.
            public var pullRequestId: Int?
            /// For a pull request build, the git repository of the pull request.
            public var pullRequestRepository: String?

            public init(commit: String, branch: String, author: Author? = nil, cleanCheckout: Bool? = nil, env: [String: String]? = nil, ignorePipelineBranchFilters: Bool? = nil, message: String? = nil, metaData: [String: String]? = nil, pullRequestBaseBranch: String? = nil, pullRequestId: Int? = nil, pullRequestRepository: String? = nil) {
                self.commit = commit
                self.branch = branch
                self.author = author
                self.cleanCheckout = cleanCheckout
                self.env = env
                self.ignorePipelineBranchFilters = ignorePipelineBranchFilters
                self.message = message
                self.metaData = metaData
                self.pullRequestBaseBranch = pullRequestBaseBranch
                self.pullRequestId = pullRequestId
                self.pullRequestRepository = pullRequestRepository
            }

        }

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds"
        }

        public init(organization: String, pipeline: String, body: Body) {
            self.organization = organization
            self.pipeline = pipeline
            self.body = body
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "POST"
        }
    }

    /// Cancel a build
    ///
    /// Cancels the build if it's state is either scheduled or running.
    public struct Cancel: Resource {
        public typealias Content = Build
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/cancel"
        }

        public init(organization: String, pipeline: String, build: Int) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "PUT"
        }
    }

    /// Rebuild a build
    ///
    /// Returns the newly created build.
    public struct Rebuild: Resource {
        public typealias Content = Build
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String
        /// build number
        public var build: Int

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)/builds/\(build)/rebuild"
        }

        public init(organization: String, pipeline: String, build: Int) {
            self.organization = organization
            self.pipeline = pipeline
            self.build = build
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "PUT"
        }
    }

    public struct QueryOptions {
        /// Filters the results by the given branch or branches.
        public var branches: [String] = []
        /// Filters the results by the commit (only works for full sha, not for shortened ones).
        public var commit: String?
        /// Filters the results by builds created on or after the given time (in ISO 8601 format)
        public var createdFrom: Date?
        /// Filters the results by builds created before the given time (in ISO 8601 format)
        public var createdTo: Date?
        /// Filters the results by the user who created the build
        public var creator: UUID?
        /// Filters the results by builds finished on or after the given time (in ISO 8601 format)
        public var finishedFrom: Date?
        /// Include all retried job executions in each build’s jobs list. Without this parameter, you'll see only the most recently run job for each step.
        public var includeRetriedJobs: Bool?
        /// Filters the results by the given meta_data.
        public var metadata: [String: String] = [:]
        /// Filters the results by the given build state. The finished state is a shortcut to automatically search for builds with passed, failed, blocked, canceled states.
        public var state: [Build.State]

        public init(branches: [String] = [], commit: String? = nil, createdFrom: Date? = nil, createdTo: Date? = nil, creator: UUID? = nil, finishedFrom: Date? = nil, includeRetriedJobs: Bool? = nil, metadata: [String: String] = [:], state: [Build.State] = []) {
            self.branches = branches
            self.commit = commit
            self.createdFrom = createdFrom
            self.createdTo = createdTo
            self.creator = creator
            self.finishedFrom = finishedFrom
            self.includeRetriedJobs = includeRetriedJobs
            self.metadata = metadata
            self.state = state
        }
    }
}

private extension Array where Element == URLQueryItem {
    init(queryOptions: Build.Resources.QueryOptions) {
        self.init()
        append(queryOptions.branches, forKey: "branch")
        appendIfNeeded(queryOptions.commit, forKey: "commit")
        appendIfNeeded(queryOptions.createdFrom, forKey: "created_from")
        appendIfNeeded(queryOptions.createdTo, forKey: "created_to")
        appendIfNeeded(queryOptions.creator, forKey: "creator")
        appendIfNeeded(queryOptions.finishedFrom, forKey: "finished_from")
        appendIfNeeded(queryOptions.includeRetriedJobs, forKey: "include_retried_jobs")
        append(queryOptions.metadata, forKey: "meta_data")
        append(queryOptions.state.map(\.rawValue), forKey: "state")
    }
}

extension Resource where Self == Build.Resources.ListAll {
    public static func builds(options: Build.Resources.QueryOptions? = nil) -> Build.Resources.ListAll {
        .init(queryOptions: options)
    }
}

extension Resource where Self == Build.Resources.ListForOrganization {
    public static func builds(inOrganization organization: String, options: Build.Resources.QueryOptions? = nil) -> Build.Resources.ListForOrganization {
        .init(organization: organization, queryOptions: options)
    }
}

extension Resource where Self == Build.Resources.ListForPipeline {
    public static func builds(forPipeline pipeline: String, in organization: String, options: Build.Resources.QueryOptions? = nil) -> Build.Resources.ListForPipeline {
        .init(organization: organization, pipeline: pipeline, queryOptions: options)
    }
}

extension Resource where Self == Build.Resources.Get {
    public static func build(_ build: Int, in organization: String, pipeline: String) -> Build.Resources.Get {
        .init(organization: organization, pipeline: pipeline, build: build)
    }
}

extension Resource where Self == Build.Resources.Create {
    public static func createBuild(in organization: String, pipeline: String, with body: Build.Resources.Create.Body) -> Build.Resources.Create {
        .init(organization: organization, pipeline: pipeline, body: body)
    }
}

extension Resource where Self == Build.Resources.Cancel {
    public static func cancelBuild(_ build: Int, in organization: String, pipeline: String) -> Build.Resources.Cancel {
        .init(organization: organization, pipeline: pipeline, build: build)
    }
}

extension Resource where Self == Build.Resources.Rebuild {
    public static func rebuild(_ build: Int, in organization: String, pipeline: String) -> Build.Resources.Rebuild {
        .init(organization: organization, pipeline: pipeline, build: build)
    }
}
