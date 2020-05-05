//
//  Pipelines.swift
//  
//
//  Created by Aaron Sky on 4/21/20.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Pipeline {
    public enum Resources { }
}

extension Pipeline.Resources {
    /// List pipelines
    ///
    /// Returns a paginated list of an organization’s pipelines.
    public struct List: Resource, HasResponseBody {
        public typealias Content = [Pipeline]
        /// organization slug
        public var organization: String

        public var path: String {
            "organizations/\(organization)/pipelines"
        }
        
        public init(organization: String) {
            self.organization = organization
        }
    }

    /// Get a pipeline
    public struct Get: Resource, HasResponseBody {
        public typealias Content = Pipeline
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)"
        }
        
        public init(organization: String, pipeline: String) {
            self.organization = organization
            self.pipeline = pipeline
        }
    }

    /// Create a pipeline
    public struct Create: Resource, HasRequestBody, HasResponseBody {
        public typealias Content = Pipeline
        /// organization slug
        public var organization: String

        public var body: Body

        public struct Body: Codable {
            /// The name of the pipeline.
            public var name: String
            /// The repository URL.
            public var repository: URL
            /// An array of the build pipeline steps.
            public var steps: [Pipeline.Step]

            /// A branch filter pattern to limit which pushed branches trigger builds on this pipeline.
            public var branchConfiguration: String?
            /// Cancel intermediate builds. When a new build is created on a branch, any previous builds that are running on the same branch will be automatically canceled.
            public var cancelRunningBranchBuilds: Bool?
            /// A branch filter pattern to limit which branches intermediate build cancelling applies to.
            public var cancelRunningBranchBuildsFilter: String?
            /// The name of the branch to prefill when new builds are created or triggered in Buildkite. It is also used to filter the builds and metrics shown on the Pipelines page.
            public var defaultBranch: String?
            /// The pipeline description.
            public var description: String?
            /// The pipeline environment variables.
            public var env: [String: String]?
            /// The source provider settings. See the Provider Settings section for accepted properties.
            public var providerSettings: Pipeline.Provider.Settings?
            /// Skip intermediate builds. When a new build is created on a branch, any previous builds that haven't yet started on the same branch will be automatically marked as skipped.
            public var skipQueuedBranchBuilds: Bool?
            /// A branch filter pattern to limit which branches intermediate build skipping applies to.
            public var skipQueuedBranchBuildsFilter: String?
            /// An array of team UUIDs to add this pipeline to. You can find your team’s UUID either via the GraphQL API, or on the settings page for a team. This property is only available if your organization has enabled Teams.
            public var teamUUIDs: [UUID]?
            
            public init(name: String, repository: URL, steps: [Pipeline.Step], branchConfiguration: String? = nil, cancelRunningBranchBuilds: Bool? = nil, cancelRunningBranchBuildsFilter: String? = nil, defaultBranch: String? = nil, description: String? = nil, env: [String : String]? = nil, providerSettings: Pipeline.Provider.Settings? = nil, skipQueuedBranchBuilds: Bool? = nil, skipQueuedBranchBuildsFilter: String? = nil, teamUUIDs: [UUID]? = nil) {
                self.name = name
                self.repository = repository
                self.steps = steps
                self.branchConfiguration = branchConfiguration
                self.cancelRunningBranchBuilds = cancelRunningBranchBuilds
                self.cancelRunningBranchBuildsFilter = cancelRunningBranchBuildsFilter
                self.defaultBranch = defaultBranch
                self.description = description
                self.env = env
                self.providerSettings = providerSettings
                self.skipQueuedBranchBuilds = skipQueuedBranchBuilds
                self.skipQueuedBranchBuildsFilter = skipQueuedBranchBuildsFilter
                self.teamUUIDs = teamUUIDs
            }
        }

        public var path: String {
            "organizations/\(organization)/pipelines"
        }
        
        public init(organization: String, body: Pipeline.Resources.Create.Body) {
            self.organization = organization
            self.body = body
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "POST"
        }
    }

    /// Update a pipeline
    ///
    /// Updates one or more properties of an existing pipeline
    public struct Update: Resource, HasRequestBody, HasResponseBody {
        public typealias Content = Pipeline
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String

        public var body: Body

        public struct Body: Codable {
            /// A branch filter pattern to limit which pushed branches trigger builds on this pipeline.
            public var branchConfiguration: String?
            /// Cancel intermediate builds. When a new build is created on a branch, any previous builds that are running on the same branch will be automatically canceled.
            public var cancelRunningBranchBuilds: Bool?
            /// A branch filter pattern to limit which branches intermediate build cancelling applies to.
            public var cancelRunningBranchBuildsFilter: String?
            /// The name of the branch to prefill when new builds are created or triggered in Buildkite.
            public var defaultBranch: String?
            /// The pipeline description.
            public var description: String?
            /// The pipeline environment variables.
            public var env: [String: String]?
            /// The name of the pipeline.
            public var name: String?
            /// The source provider settings. See the Provider Settings section for accepted properties.
            public var providerSettings: Pipeline.Provider.Settings?
            /// The repository URL.
            public var repository: URL?
            /// An array of the build pipeline steps.
            public var steps: [Pipeline.Step]?
            /// Skip intermediate builds. When a new build is created on a branch, any previous builds that haven't yet started on the same branch will be automatically marked as skipped.
            public var skipQueuedBranchBuilds: Bool?
            /// A branch filter pattern to limit which branches intermediate build skipping applies to.
            public var skipQueuedBranchBuildsFilter: String?
            /// Whether the pipeline is visible to everyone, including users outside this organization.
            public var visibility: String?
            
            public init(branchConfiguration: String? = nil, cancelRunningBranchBuilds: Bool? = nil, cancelRunningBranchBuildsFilter: String? = nil, defaultBranch: String? = nil, description: String? = nil, env: [String : String]? = nil, name: String? = nil, providerSettings: Pipeline.Provider.Settings? = nil, repository: URL? = nil, steps: [Pipeline.Step]? = nil, skipQueuedBranchBuilds: Bool? = nil, skipQueuedBranchBuildsFilter: String? = nil, visibility: String? = nil) {
                self.branchConfiguration = branchConfiguration
                self.cancelRunningBranchBuilds = cancelRunningBranchBuilds
                self.cancelRunningBranchBuildsFilter = cancelRunningBranchBuildsFilter
                self.defaultBranch = defaultBranch
                self.description = description
                self.env = env
                self.name = name
                self.providerSettings = providerSettings
                self.repository = repository
                self.steps = steps
                self.skipQueuedBranchBuilds = skipQueuedBranchBuilds
                self.skipQueuedBranchBuildsFilter = skipQueuedBranchBuildsFilter
                self.visibility = visibility
            }
        }

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)"
        }
        
        public init(organization: String, pipeline: String, body: Pipeline.Resources.Update.Body) {
            self.organization = organization
            self.pipeline = pipeline
            self.body = body
        }
    }

    /// Delete a pipeline
    public struct Delete: Resource {
        public typealias Content = Void
        /// organization slug
        public var organization: String
        /// pipeline slug
        public var pipeline: String

        public var path: String {
            "organizations/\(organization)/pipelines/\(pipeline)"
        }
    
        public init(organization: String, pipeline: String) {
            self.organization = organization
            self.pipeline = pipeline
        }
    }
}
