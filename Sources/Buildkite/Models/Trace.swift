//
//  Trace.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/5/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Analytics event used in reporting to ``TestAnalytics``
public struct Trace: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// Unique identifier for this test result
    public var id: UUID
    /// Group or topic for the test
    public var scope: String?
    /// Name or description for the test
    public var name: String?
    /// Unique identifier for the test. If your test runner supports it, use the identifier needed to rerun this test
    public var identifier: String?
    /// File and line number where the test originates, separated by a colon (:)
    public var location: String?
    /// File where the test originates
    public var fileName: String?
    /// Outcome of the test, e.g. `"passed"`, `"failed"`, `"skipped"`, or `"unknown"``
    public var result: String?
    /// Short summary of why the test failed, if applicable
    public var failureReason: String?
    /// History object
    public var history: Span

    public init(
        id: UUID,
        scope: String? = nil,
        name: String? = nil,
        identifier: String? = nil,
        location: String? = nil,
        fileName: String? = nil,
        result: String? = nil,
        failureReason: String? = nil,
        history: Trace.Span
    ) {
        self.id = id
        self.scope = scope
        self.name = name
        self.identifier = identifier
        self.location = location
        self.fileName = fileName
        self.result = result
        self.failureReason = failureReason
        self.history = history
    }

    /// A duration of some event or tree of events.
    public struct Span: Codable, Equatable, Hashable, Sendable {
        /// Section category for this span, e.g. `"http"`, `"sql"`, `"sleep"`, or `"annotation"`
        public var section: String
        /// Monotonically increasing number
        public var startAt: TimeInterval?
        /// Monotonically increasing number
        public var endAt: TimeInterval?
        /// How long the span took to run
        public var duration: TimeInterval?
        /// Information related to this span
        public var detail: [String: String] = [:]
        /// Array of span objects
        public var children: [Span] = []

        public init(
            section: String,
            startAt: TimeInterval? = nil,
            endAt: TimeInterval? = nil,
            duration: TimeInterval? = nil,
            detail: [String: String] = [:],
            children: [Trace.Span] = []
        ) {
            self.section = section
            self.startAt = startAt
            self.endAt = endAt
            self.duration = duration
            self.detail = detail
            self.children = children
        }

        private enum CodingKeys: String, CodingKey {
            case section
            case startAt = "start_at"
            case endAt = "end_at"
            case duration
            case detail
            case children
        }
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case scope
        case name
        case identifier
        case location
        case fileName = "file_name"
        case result
        case failureReason = "failure_reason"
        case history
    }
}
