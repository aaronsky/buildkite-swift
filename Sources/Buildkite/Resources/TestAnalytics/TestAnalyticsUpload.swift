//
//  TestAnalyticsUpload.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/5/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum TestAnalytics {
    /// Resources for requesting information from Test Analytics.
    public enum Resources {}
}

extension TestAnalytics.Resources {
    /// Upload a trace to Test Analytics.
    public struct Upload: Resource, Equatable, Hashable, Sendable {
        public struct Body: Encodable, Equatable, Hashable, Sendable {
            /// Format of the data. Should be `"json"`.
            public var format: String
            /// Environment the tests were run under.
            public var environment: Environment
            /// Test results as traces.
            public var data: [Trace]

            /// Environment the tests were run under.
            ///
            /// - SeeAlso: https://buildkite.com/docs/test-analytics/ci-environments
            public struct Environment: Encodable, Equatable, Hashable, Sendable {
                /// CI provider, e.g. `"buildkite"`, `"circleci"`, `"github_actions"`, etc.
                public var ci: String
                /// Unique key identifying the upload. See the link for your specific CI environment for guidance.
                public var key: String
                /// Build number.
                public var number: String?
                /// ID of the build in the CI environment.
                public var jobId: String?
                /// The branch or reference for the build.
                public var branch: String?
                /// Commit hash for the head of the branch.
                public var commitSha: String?
                /// Commit message for the head of the branch.
                public var message: String?
                /// URL for the build.
                public var url: String?

                public init(
                    ci: String,
                    key: String,
                    number: String? = nil,
                    jobId: String? = nil,
                    branch: String? = nil,
                    commitSha: String? = nil,
                    message: String? = nil,
                    url: String? = nil
                ) {
                    self.ci = ci
                    self.key = key
                    self.number = number
                    self.jobId = jobId
                    self.branch = branch
                    self.commitSha = commitSha
                    self.message = message
                    self.url = url
                }
            }

            private enum CodingKeys: String, CodingKey {
                case format
                case environment = "runEnv"
                case data
            }
        }

        public struct Content: Codable, Equatable, Hashable, Sendable {
            /// ID of the Test Analytics upload.
            public var id: UUID
            /// ID of the run in Test Analytics.
            public var runId: UUID
            /// Number of tests queued.
            public var queued: Int
            /// Number of tests skipped.
            public var skipped: Int
            /// Errors in tests.
            public var errors: [String]
            /// URL to the run in Test Analytics.
            public var runURL: URL

            private enum CodingKeys: String, CodingKey {
                case id
                case runId = "run_id"
                case queued
                case skipped
                case errors
                case runURL = "run_url"
            }
        }

        public var version: APIVersion {
            APIVersion.TestAnalytics.v1
        }

        public let path = "upload"

        /// body of the request
        public var body: Body

        public init(
            body: Body
        ) {
            self.body = body
        }

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "POST"
        }
    }
}

extension Resource where Self == TestAnalytics.Resources.Upload {
    /// Upload a trace to Test Analytics.
    public static func uploadTestAnalytics(_ data: [Trace], environment: Self.Body.Environment) -> Self {
        Self(body: .init(format: "json", environment: environment, data: data))
    }
}
