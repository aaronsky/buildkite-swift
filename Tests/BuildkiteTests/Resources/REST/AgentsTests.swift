//
//  AgentsTests.swift
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

extension Agent {
    init() {
        let job = Job.script(
            Job.Command(
                id: UUID(),
                name: "📦",
                state: "passed",
                command: nil,
                stepKey: nil,
                buildUrl: URL(),
                webUrl: URL(),
                logUrl: Followable(),
                rawLogUrl: Followable(),
                artifactsUrl: URL(),
                softFailed: false,
                exitStatus: 0,
                artifactPaths: nil,
                agentQueryRules: [],
                agent: nil,
                createdAt: Date(timeIntervalSince1970: 1000),
                scheduledAt: Date(timeIntervalSince1970: 1000),
                runnableAt: nil,
                startedAt: nil,
                finishedAt: nil,
                retried: false,
                retriedInJobId: nil,
                retriesCount: nil,
                parallelGroupIndex: nil,
                parallelGroupTotal: nil
            )
        )

        self.init(
            id: UUID(),
            url: Followable(),
            webUrl: URL(),
            name: "jeffrey",
            connectionState: "connected",
            hostname: "jeffrey",
            ipAddress: "192.168.1.1",
            userAgent: "buildkite/host",
            version: "3.20.0",
            creator: User(),
            createdAt: Date(timeIntervalSince1970: 1000),
            job: job,
            lastJobFinishedAt: nil,
            priority: nil,
            metaData: []
        )
    }
}

class AgentsTests: XCTestCase {
    func testAgentsList() async throws {
        let expected = [Agent(), Agent()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.agents(in: "buildkite"))

        XCTAssertEqual(expected, response.content)
    }

    func testAgentsGet() async throws {
        let expected = Agent()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.agent(UUID(), in: "buildkite"))
        XCTAssertEqual(expected, response.content)
    }

    func testAgentsStop() async throws {
        let context = MockContext()
        _ = try await context.client.send(.stopAgent(UUID(), in: "buildkite", force: true))
    }
}
