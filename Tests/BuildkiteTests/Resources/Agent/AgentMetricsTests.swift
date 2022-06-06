//
//  AgentMetricsTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/5/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest

@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension AgentMetrics {
    init() {
        self.init(
            agents: .init(
                idle: 0,
                busy: 0,
                total: 0,
                queues: [:]
            ),
            jobs: .init(
                scheduled: 0,
                running: 0,
                waiting: 0,
                total: 0,
                queues: [:]
            ),
            organization: .init(
                slug: "buildkite"
            )
        )
    }
}

class AgentMetricsTests: XCTestCase {
    func testAgentMetricsGet() async throws {
        let expected = AgentMetrics()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.agentMetrics)

        XCTAssertEqual(expected, response.content)
    }
}
