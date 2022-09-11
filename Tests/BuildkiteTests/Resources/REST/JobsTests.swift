//
//  JobsTests.swift
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

class JobsTests: XCTestCase {
    func testJobsRetryWaiter() async throws {
        let expected: Job = .waiter(Job.Wait(id: UUID(), graphqlId: ""))
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .retryJob(UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)
        )

        XCTAssertEqual(expected, response.content)
    }

    func testJobsRetryTrigger() async throws {
        let expected: Job = .trigger(
            Job.Trigger(
                name: nil,
                state: nil,
                buildURL: URL(),
                webURL: URL(),
                createdAt: Date(timeIntervalSince1970: 1000),
                scheduledAt: nil,
                finishedAt: nil,
                runnableAt: nil,
                triggeredBuild: Job.Trigger.TriggeredBuild(
                    id: UUID(),
                    number: 0,
                    url: URL(),
                    webURL: URL()
                )
            )
        )
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .retryJob(UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)
        )

        XCTAssertEqual(expected, response.content)
    }

    func testJobsUnblock() async throws {
        let expected: Job = .manual(
            Job.Block(
                id: UUID(),
                graphqlId: "",
                label: "",
                state: "",
                webURL: nil,
                unblockedBy: User(),
                unblockedAt: Date(timeIntervalSince1970: 1000),
                unblockable: true,
                unblockURL: URL()
            )
        )
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .unblockJob(UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1, with: .init())
        )

        XCTAssertEqual(expected, response.content)
    }

    func testJobsLogOutput() async throws {
        let expected = Job.LogOutput()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .logOutput(for: UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)
        )

        XCTAssertEqual(expected, response.content)
    }

    func testJobsLogOutputAlternativePlainText() async throws {
        let expected = "hello friends"
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .logOutput(.plainText, for: UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)
        )

        XCTAssertEqual(expected, response.content)
    }

    func testJobsLogOutputAlternativeHTML() async throws {
        let expected = "hello friends"
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .logOutput(.html, for: UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)
        )

        XCTAssertEqual(expected, response.content)
    }

    func testJobsDeleteLogOutput() async throws {
        let context = MockContext()

        _ = try await context.client.send(
            .deleteLogOutput(for: UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)
        )
    }

    func testJobsEnvironmentVariables() async throws {
        let expected = Job.EnvironmentVariables(env: [:])
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .environmentVariables(for: UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)
        )

        XCTAssertEqual(expected, response.content)
    }
}

extension Job.LogOutput {
    init() {
        self.init(
            url: Followable(),
            content: "hello friends",
            size: 13,
            headerTimes: []
        )
    }
}
