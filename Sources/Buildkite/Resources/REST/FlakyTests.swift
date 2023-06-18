//
//  FlakyTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/18/23.
//  Copyright © 2023 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension FlakyTest {
    /// Resources for performing operations on flaky tests.
    public enum Resources {}
}

extension FlakyTest.Resources {
    /// Provides information about tests detected as flaky in a test suite.
    ///
    /// Returns a paginated list of the flaky tests detected in a test suite.
    public struct List: PaginatedResource, Equatable, Hashable, Sendable {
        public typealias Content = [FlakyTest]
        /// organization slug
        public var organization: String
        /// test suite slug
        public var suite: String

        public var path: String {
            "analytics/organizations/\(organization)/suites/\(suite)/flaky-tests"
        }

        public init(
            organization: String,
            suite: String
        ) {
            self.organization = organization
            self.suite = suite
        }
    }
}

extension Resource where Self == FlakyTest.Resources.List {
    /// List flaky tests
    ///
    /// Returns a paginated list of a test suite's flaky tests.
    public static func flakyTests(in organization: String, suite: String) -> Self {
        Self(organization: organization, suite: suite)
    }
}
