//
//  Pipeline.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Pipeline: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var graphqlId: String
    public var url: Followable<Pipeline.Resources.Get>
    public var webURL: URL
    public var name: String
    public var slug: String
    public var repository: String
    public var branchConfiguration: String?
    public var defaultBranch: String?
    public var provider: Provider
    public var skipQueuedBranchBuilds: Bool
    public var skipQueuedBranchBuildsFilter: String?
    public var cancelRunningBranchBuilds: Bool
    public var cancelRunningBranchBuildsFilter: String?
    public var buildsURL: Followable<Build.Resources.ListForPipeline>
    public var badgeURL: URL
    public var createdAt: Date
    public var scheduledBuildsCount: Int
    public var runningBuildsCount: Int
    public var scheduledJobsCount: Int
    public var runningJobsCount: Int
    public var waitingJobsCount: Int
    public var visibility: String
    public var steps: [Step]
    public var env: JSONValue?

    public struct Provider: Codable, Equatable, Hashable, Identifiable, Sendable {
        public var id: String
        public var webhookURL: URL?
        public var settings: Settings

        private enum CodingKeys: String, CodingKey {
            case id
            case webhookURL = "webhook_url"
            case settings
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case graphqlId = "graphql_id"
        case url
        case webURL = "web_url"
        case name
        case slug
        case repository
        case branchConfiguration = "branch_configuration"
        case defaultBranch = "default_branch"
        case provider
        case skipQueuedBranchBuilds = "skip_queued_branch_builds"
        case skipQueuedBranchBuildsFilter = "skip_queued_branch_builds_filter"
        case cancelRunningBranchBuilds = "cancel_running_branch_builds"
        case cancelRunningBranchBuildsFilter = "cancel_running_branch_builds_filter"
        case buildsURL = "builds_url"
        case badgeURL = "badge_url"
        case createdAt = "created_at"
        case scheduledBuildsCount = "scheduled_builds_count"
        case runningBuildsCount = "running_builds_count"
        case scheduledJobsCount = "scheduled_jobs_count"
        case runningJobsCount = "running_jobs_count"
        case waitingJobsCount = "waiting_jobs_count"
        case visibility
        case steps
        case env
    }
}

extension Pipeline.Provider {
    public struct Settings: Codable, Equatable, Hashable, Sendable {
        public var repository: String?
        /// Whether to create builds for commits that are part of a Pull Request.
        public var buildPullRequests: Bool?
        /// Whether to limit the creation of builds to specific branches or patterns.
        public var pullRequestBranchFilterEnabled: Bool?
        /// The branch filtering pattern. Only pull requests on branches matching this pattern will cause builds to be created.
        public var pullRequestBranchFilterConfiguration: String?
        /// Whether to skip creating a new build for a pull request if an existing build for the commit and branch already exists.
        public var skipPullRequestBuildsForExistingCommits: Bool?
        /// Whether to create builds when tags are pushed.
        public var buildTags: Bool?
        /// Whether to update the status of commits in Bitbucket or GitHub.
        public var publishCommitStatus: Bool?
        /// Whether to create a separate status for each job in a build, allowing you to see the status of each job directly in Bitbucket or GitHub.
        public var publishCommitStatusPerStep: Bool?
        /// What type of event to trigger builds on. Code will create builds when code is pushed to GitHub. Deployment will create builds when a deployment is created with the GitHub Deployments API. Fork will create builds when the GitHub repository is forked. None will not create any builds based on GitHub activity.
        public var triggerMode: String?
        /// Whether filter conditions are being used for this step.
        public var filterEnabled: Bool?
        /// The conditions under which this step will run. See the Using Conditionals guide for more information.
        public var filterCondition: String?
        /// Whether to create builds for pull requests from third-party forks.
        public var buildPullRequestForks: Bool?
        /// Prefix branch names for third-party fork builds to ensure they don't trigger branch conditions. For example, the master branch from some-user will become some-user:master.
        public var prefixPullRequestForkBranchNames: Bool?
        /// Whether to create a separate status for pull request builds, allowing you to require a passing pull request build in your required status checks in GitHub.
        public var separatePullRequestStatuses: Bool?
        /// The status to use for blocked builds. Pending can be used with required status checks to prevent merging pull requests with blocked builds.
        public var publishBlockedAsPending: Bool?

        private enum CodingKeys: String, CodingKey {
            case repository
            case buildPullRequests = "build_pull_requests"
            case pullRequestBranchFilterEnabled = "pull_request_branch_filter_enabled"
            case pullRequestBranchFilterConfiguration = "pull_request_branch_filter_configuration"
            case skipPullRequestBuildsForExistingCommits = "skip_pull_request_builds_for_existing_commits"
            case buildTags = "build_tags"
            case publishCommitStatus = "publish_commit_status"
            case publishCommitStatusPerStep = "publish_commit_status_per_step"
            case triggerMode = "trigger_mode"
            case filterEnabled = "filter_enabled"
            case filterCondition = "filter_condition"
            case buildPullRequestForks = "build_pull_request_forks"
            case prefixPullRequestForkBranchNames = "prefix_pull_request_fork_branch_names"
            case separatePullRequestStatuses = "separate_pull_request_statuses"
            case publishBlockedAsPending = "publish_blocked_as_pending"
        }
    }
}

extension Pipeline {
    public enum Step: Codable, Equatable, Hashable, Sendable {
        case script(Command)
        case waiter(Wait)
        case manual(Block)
        case trigger(Trigger)

        private enum Unassociated: String, Codable {
            case script
            case waiter
            case manual
            case trigger
        }

        public init(
            from decoder: Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(Unassociated.self, forKey: .type)
            switch type {
            case .script:
                self = .script(try Command(from: decoder))
            case .waiter:
                self = .waiter(try Wait(from: decoder))
            case .manual:
                self = .manual(try Block(from: decoder))
            case .trigger:
                self = .trigger(try Trigger(from: decoder))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .script(let step):
                try step.encode(to: encoder)
            case .waiter(let step):
                try step.encode(to: encoder)
            case .manual(let step):
                try step.encode(to: encoder)
            case .trigger(let step):
                try step.encode(to: encoder)
            }
        }

        private enum CodingKeys: String, CodingKey {
            case type
        }

        public struct Command: Codable, Equatable, Hashable, Sendable {
            public var type = "script"
            public var name: String?
            public var command: String?
            public var label: String?
            public var artifactPaths: String?
            public var branchConfiguration: String?
            public var env: JSONValue
            public var timeoutInMinutes: Int?
            public var agentQueryRules: [String]
            public var async: Bool?
            public var concurrency: Int?
            public var parallelism: Int?

            private enum CodingKeys: String, CodingKey {
                case type
                case name
                case command
                case label
                case artifactPaths = "artifact_paths"
                case branchConfiguration = "branch_configuration"
                case env
                case timeoutInMinutes = "timeout_in_minutes"
                case agentQueryRules = "agent_query_rules"
                case async
                case concurrency
                case parallelism
            }
        }

        public struct Wait: Codable, Equatable, Hashable, Sendable {
            public var type = "waiter"
            public var label: String?
            public var continueAfterFailure: Bool?

            private enum CodingKeys: String, CodingKey {
                case type
                case label
                case continueAfterFailure = "continue_after_failure"
            }
        }

        public struct Block: Codable, Equatable, Hashable, Sendable {
            public var type = "manual"
            public var label: String?
        }

        public struct Trigger: Codable, Equatable, Hashable, Sendable {
            public var type = "trigger"
            public var triggerProjectSlug: String?
            public var label: String?
            public var triggerCommit: String?
            public var triggerBranch: String?
            public var triggerAsync: Bool?

            private enum CodingKeys: String, CodingKey {
                case type
                case triggerProjectSlug = "trigger_project_slug"
                case label
                case triggerCommit = "trigger_commit"
                case triggerBranch = "trigger_branch"
                case triggerAsync = "trigger_async"
            }
        }
    }
}
