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
    /// Resources for requesting information about your organization's Buildkite agents.
    public enum Resources {}
}

extension TestAnalytics.Resources {
    /// Get metrics about agents active with the current organization.
    public struct Upload: Resource {
        public struct Body: Encodable {
            public var format: String
            public var environment: Environment
            public var data: [Trace]

            public struct Environment: Encodable {
                public var ci: String
                public var key: String
                public var number: String?
                public var jobId: String?
                public var branch: String?
                public var commitSha: String?
                public var message: String?
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

        public struct Content: Codable, Equatable {
            public var id: UUID
            public var runId: UUID
            public var queued: Int
            public var skipped: Int
            public var errors: [String]
            public var runUrl: URL
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
    /// Get an object with properties describing Buildkite
    ///
    /// Returns meta information about Buildkite.
    public static func uploadTestAnalytics(_ data: [Trace], environment: Self.Body.Environment) -> Self {
        Self(body: .init(format: "json", environment: environment, data: data))
    }
}
