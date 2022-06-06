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

public struct Trace: Codable, Equatable, Identifiable {
    /// a unique identifier for this test result
    public var id: UUID
    /// a group or topic for the test
    ///
    /// - `Student.isEnrolled()`
    public var scope: String?
    /// a name or description for the test
    ///
    /// - `Manager.isEnrolled()`
    /// - `returns_boolean`
    public var name: String?
    /// a unique identifier for the test. If your test runner supports it, use the identifier needed to rerun this test
    ///
    /// - `Manager.isEnrolled#returns_boolean`
    public var identifier: String?
    /// the file and line number where the test originates, separated by a colon (:)
    ///
    /// - `./tests/Manager/isEnrolled.js:32`
    public var location: String?
    /// the file where the test originates
    ///
    /// - `./tests/Manager/isEnrolled.js`
    public var fileName: String?
    /// the outcome of the test, e.g. `"passed"`, `"failed"`, `"skipped"`, or `"unknown"``
    public var result: String?
    /// if applicable, a short summary of why the test failed
    ///
    /// - `Expected Boolean, got Object`
    public var failureReason: String?
    /// History object
    public var history: History

    public struct History: Codable, Equatable {
        /// A monotonically increasing number
        public var startAt: Double?
        /// A monotonically increasing number
        public var endAt: Double?
        /// How long the test took to run
        public var duration: Double
        /// array of span objects
        public var children: [Span]? = []

        public struct Span: Codable, Equatable {
            /// A section category for this span, e.g. `"http"`, `"sql"`, `"sleep"`, or `"annotation"`
            public var section: String
            /// A monotonically increasing number
            public var startAt: Double?
            /// A monotonically increasing number
            public var endAt: Double?
            /// How long the span took to run
            public var duration: Double?
        }
    }
}
