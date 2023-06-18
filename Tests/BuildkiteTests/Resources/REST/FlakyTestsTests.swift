//
//  PipelinesTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/4/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest

@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension FlakyTest {
    init() {
        self.init(
            id: UUID(),
            graphqlId: "",
            webURL: URL(),
            scope: "Test#failure",
            name: "failure",
            location: "./file:30",
            fileName: "./file",
            instances: 10,
            mostRecentInstanceAt: Date(timeIntervalSince1970: 1000)
        )
    }
}

class FlakyTestsTests: XCTestCase {
    func testFlakyTestsList() async throws {
        let expected = [FlakyTest(), FlakyTest()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.flakyTests(in: "buildkite", suite: "my-suite"))

        XCTAssertEqual(expected, response.content)
    }
}
