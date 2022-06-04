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

public struct Pipeline: Codable, Equatable, Identifiable {
    public var id: UUID
    public var url: Followable<Pipeline.Resources.Get>
    public var webUrl: URL
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
    public var buildsUrl: Followable<Build.Resources.ListForPipeline>
    public var badgeUrl: URL
    public var createdAt: Date
    public var scheduledBuildsCount: Int
    public var runningBuildsCount: Int
    public var scheduledJobsCount: Int
    public var runningJobsCount: Int
    public var waitingJobsCount: Int
    public var visibility: String
    public var steps: [Step]
    public var env: JSONValue?

    public struct Provider: Codable, Equatable {
        public var id: String
        public var webhookUrl: URL?
        public var settings: Settings
    }
}

extension Pipeline.Provider {
    public struct Settings: Codable, Equatable {
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
    }
}

extension Pipeline {
    public enum Step: Codable, Equatable {
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

        public struct Command: Codable, Equatable {
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
        }

        public struct Wait: Codable, Equatable {
            public var type = "waiter"
            public var label: String?
            public var continueAfterFailure: Bool?
        }

        public struct Block: Codable, Equatable {
            public var type = "manual"
            public var label: String?
        }

        public struct Trigger: Codable, Equatable {
            public var type = "trigger"
            public var triggerProjectSlug: String?
            public var label: String?
            public var triggerCommit: String?
            public var triggerBranch: String?
            public var triggerAsync: Bool?
        }
    }
}
