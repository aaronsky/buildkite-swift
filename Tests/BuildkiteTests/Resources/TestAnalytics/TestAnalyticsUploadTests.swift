//
//  TestAnalyticsUploadTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/6/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest

@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class TestAnalyticsUpload: XCTestCase {
    func testTestAnalyticsUpload() async throws {
        typealias Resource = TestAnalytics.Resources.Upload

        let traces: [Trace] = [
            .init(id: .init(), history: .init(section: "http")),
            .init(id: .init(), history: .init(section: "http")),
            .init(id: .init(), history: .init(section: "http")),
        ]
        let expected = Resource.Content(id: .init(), runId: .init(), queued: 0, skipped: 0, errors: [], runUrl: .init())
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .uploadTestAnalytics(traces, environment: .init(ci: "buildkite", key: "test"))
        )

        XCTAssertEqual(expected, response.content)
    }
}
