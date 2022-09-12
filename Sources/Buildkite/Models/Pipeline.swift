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

/// A pipeline is a template of the steps you want to run. There are many types of steps, some run scripts,
/// some define conditional logic, and others wait for user input. When you run a pipeline, a build is created.
/// Each of the steps in the pipeline end up as jobs in the build, which then get distributed to available agents.
public struct Pipeline: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the pipeline.
    public var id: UUID
    /// ID of the pipeline to be used with the GraphQL API.
    public var graphqlId: String
    /// Followable URL to fetch this specific pipeline.
    public var url: Followable<Pipeline.Resources.Get>
    /// Human-readable URL of this pipeline in the Buildkite dashboard.
    public var webURL: URL
    /// Name of the pipeline.
    public var name: String
    /// "Slug" identifier for the pipeline.
    public var slug: String
    /// The repository URL.
    public var repository: String
    /// A [branch filter pattern](https://buildkite.com/docs/pipelines/branch-configuration#pipeline-level-branch-filtering)
    /// that limits which pushed branches trigger builds on this pipeline.
    public var branchConfiguration: String?
    /// The name of the branch to prefill when new builds are created or triggered in Buildkite.
    /// It is also used to filter the builds and metrics shown on the Pipelines page.
    public var defaultBranch: String?
    /// Provider settings.
    public var provider: Provider
    /// Skip intermediate builds. When a new build is created on a branch, any previous builds that
    /// haven't yet started on the same branch will be automatically marked as skipped.
    public var skipQueuedBranchBuilds: Bool
    /// A [branch filter pattern](https://buildkite.com/docs/pipelines/branch-configuration#pipeline-level-branch-filtering)
    /// to limit which branches intermediate build skipping applies to.
    public var skipQueuedBranchBuildsFilter: String?
    /// Cancel intermediate builds. When a new build is created on a branch, any previous builds
    /// that are running on the same branch will be automatically canceled.
    public var cancelRunningBranchBuilds: Bool
    /// A [branch filter pattern](https://buildkite.com/docs/pipelines/branch-configuration#pipeline-level-branch-filtering)
    /// to limit which branches intermediate build cancelling applies to.
    public var cancelRunningBranchBuildsFilter: String?
    /// Followable URL to fetch the latest builds for this pipeline.
    public var buildsURL: Followable<Build.Resources.ListForPipeline>
    /// Human-readable URL to the build status badge for this pipeline.
    public var badgeURL: URL
    /// When the pipeline was created.
    public var createdAt: Date
    /// Number of builds currently scheduled.
    public var scheduledBuildsCount: Int
    /// Number of builds currently running.
    public var runningBuildsCount: Int
    /// Number of jobs currently scheduled.
    public var scheduledJobsCount: Int
    /// Number of jobs currently running.
    public var runningJobsCount: Int
    /// Number of jobs currently waiting.
    public var waitingJobsCount: Int
    /// Whether the pipeline is visible to everyone, including users outside this organization.
    public var visibility: String
    /// Pipeline steps configured in the Buildkite dashbaord.
    public var steps: [Step]
    /// Environment configuration for builds run on this pipeline.
    public var env: JSONValue?

    /// Information about how the pipeline is triggered based on source code provider events.
    public struct Provider: Codable, Equatable, Hashable, Identifiable, Sendable {
        /// ID of the source code provider.
        public var id: String
        /// URL to the source code provider that webhook events are sent to.
        public var webhookURL: URL?
        /// Provider settings.
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
    /// Source code provider settings.
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
    /// A pipeline step.
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

        /// Command step.
        public struct Command: Codable, Equatable, Hashable, Sendable {
            public var type = "script"
            /// Name of the step.
            public var name: String?
            /// The shell command/s to run during this step.
            public var command: String?
            /// The label that will be displayed in the pipeline visualisation in Buildkite. Supports emoji.
            public var label: String?
            /// The [glob path](https://buildkite.com/docs/agent/v3/cli-artifact#uploading-artifacts)
            /// or paths of [artifacts](https://buildkite.com/docs/agent/v3/cli-artifact) to upload
            /// from this step.
            public var artifactPaths: String?
            /// The [branch pattern](https://buildkite.com/docs/pipelines/branch-configuration#branch-pattern-examples)
            /// defining which branches will include this step in their builds.
            public var branchConfiguration: String?
            /// A map of [environment variables](https://buildkite.com/docs/pipelines/environment-variables) for this step.
            public var env: JSONValue
            /// The maximum number of minutes a job created from this step is allowed to run. If the
            /// job exceeds this time limit, or if it finishes with a non-zero exit status, the job is
            /// automatically canceled and the build fails. Jobs that time out with an exit status
            /// of 0 are marked as "passed".
            ///
            /// Note that command steps on the Buildkite [Free plan](https://buildkite.com/pricing) have a maximum job timeout of 240 minutes.
            ///
            /// You can also set
            /// [default and maximum timeouts](https://buildkite.com/docs/pipelines/command-step#command-step-attributes-build-timeouts)
            /// in the Buildkite UI.
            public var timeoutInMinutes: Int?
            /// A map of [agent tag](https://buildkite.com/docs/agent/v3/cli-start#setting-tags)
            /// keys to values to [target specific agents](https://buildkite.com/docs/agent/v3/cli-start#agent-targeting)
            /// for this step.
            public var agentQueryRules: [String]
            /// If set to `true` the step will immediately continue, regardless of the success of
            /// the triggered build. If set to `false` the step will wait for the triggered build to
            /// complete and continue only if the triggered build passed.
            public var async: Bool?
            /// The [maximum number of jobs](https://buildkite.com/docs/pipelines/controlling-concurrency#concurrency-limits)
            /// created from this step that are allowed to run at the same time.
            public var concurrency: Int?
            /// The number of [parallel jobs](https://buildkite.com/docs/tutorials/parallel-builds#parallel-jobs)
            /// that will be created based on this step.
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

        /// Wait step.
        public struct Wait: Codable, Equatable, Hashable, Sendable {
            public var type = "waiter"
            /// Human-readable label.
            public var label: String?
            /// Whether to continue the build if previous steps have failed.
            public var continueAfterFailure: Bool?

            private enum CodingKeys: String, CodingKey {
                case type
                case label
                case continueAfterFailure = "continue_after_failure"
            }
        }

        /// Block step.
        public struct Block: Codable, Equatable, Hashable, Sendable {
            public var type = "manual"
            /// Human-readable label.
            public var label: String?
        }

        /// Trigger step.
        public struct Trigger: Codable, Equatable, Hashable, Sendable {
            public var type = "trigger"
            /// Pipeline slug to trigger a build on.
            public var triggerProjectSlug: String?
            /// Human-readable label.
            public var label: String?
            /// Repository commit to trigger the build for.
            public var triggerCommit: String?
            /// Repository branch to trigger the build for.
            public var triggerBranch: String?
            /// If set to `true` the step will immediately continue, regardless of the success of
            /// the triggered build. If set to `false` the step will wait for the triggered build to
            /// complete and continue only if the triggered build passed.
            ///
            /// Note that when ``triggerAsync`` is set to `true`, as long as the triggered
            /// build starts, the original pipeline will show that as successful. The original pipeline
            /// does not get updated after subsequent steps or after the triggered build completes.
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
