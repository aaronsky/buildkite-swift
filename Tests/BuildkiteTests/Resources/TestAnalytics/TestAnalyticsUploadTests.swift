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
        let traces: [Trace] = [
            .init(id: .init(), history: .init(duration: 0)),
            .init(id: .init(), history: .init(duration: 0)),
            .init(id: .init(), history: .init(duration: 0))
        ]
        let environment: TestAnalytics.Resources.Upload.Body.Environment = .init(ci: "buildkite", key: "test")
        let expected = "dogs"
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.uploadTestAnalytics(traces, environment: environment))

        XCTAssertEqual(expected, response.content)
    }
}
