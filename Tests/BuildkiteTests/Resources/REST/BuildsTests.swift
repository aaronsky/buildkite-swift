//
//  BuildsTests.swift
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

extension Build {
    init() {
        self.init(
            id: UUID(),
            url: Followable(),
            webUrl: URL(),
            number: 1,
            state: .passed,
            blocked: false,
            message: "a commit",
            commit: "HEAD",
            branch: "master",
            env: [:],
            source: "webhook",
            creator: User(),
            jobs: [],
            createdAt: Date(timeIntervalSince1970: 1000),
            scheduledAt: Date(timeIntervalSince1970: 1000),
            startedAt: Date(timeIntervalSince1970: 1000),
            finishedAt: Date(timeIntervalSince1970: 1001),
            metaData: [:],
            pullRequest: [:],
            pipeline: Pipeline()
        )
    }
}

class BuildsTests: XCTestCase {
    func testBuildsListAllDefaultQuery() async throws {
        let expected = [Build(), Build()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.builds())

        XCTAssertEqual(expected, response.content)
    }

    func testBuildsListAllSpecializedQuery() async throws {
        let expected = [Build(), Build()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .builds(
                options: .init(
                    branches: ["master"],
                    commit: "HEAD",
                    createdFrom: Date(timeIntervalSince1970: 1000),
                    createdTo: Date(timeIntervalSince1970: 1000),
                    creator: UUID(),
                    finishedFrom: Date(timeIntervalSince1970: 1000),
                    includeRetriedJobs: true,
                    metadata: ["buildkite": "is cool"],
                    state: [.passed, .blocked, .failed]
                )
            )
        )

        XCTAssertEqual(expected, response.content)
    }

    func testBuildsListForOrganization() async throws {
        let expected = [Build(), Build()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.builds(inOrganization: "buildkite", options: .init()))

        XCTAssertEqual(expected, response.content)
    }

    func testBuildsListForPipeline() async throws {
        let expected = [Build(), Build()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .builds(forPipeline: "my-pipeline", in: "buildkite", options: .init())
        )

        XCTAssertEqual(expected, response.content)
    }

    func testBuildsGet() async throws {
        let expected = Build()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.build(1, in: "buildkite", pipeline: "my-pipeline"))

        XCTAssertEqual(expected, response.content)
    }

    func testBuildsCreate() async throws {
        let expected = Build()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .createBuild(
                in: "buildkite",
                pipeline: "my-pipeline",
                with: .init(
                    commit: "HEAD",
                    branch: "master",
                    author: Build.Resources.Create.Body.Author(name: "", email: ""),
                    cleanCheckout: nil,
                    env: nil,
                    ignorePipelineBranchFilters: nil,
                    message: nil,
                    metaData: nil,
                    pullRequestBaseBranch: nil,
                    pullRequestId: nil,
                    pullRequestRepository: nil
                )
            )
        )

        XCTAssertEqual(expected, response.content)
    }

    func testBuildsCancel() async throws {
        let expected = Build()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.cancelBuild(1, in: "buildkite", pipeline: "my-pipeline"))

        XCTAssertEqual(expected, response.content)
    }

    func testBuildsRebuild() async throws {
        let expected = Build()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.rebuild(1, in: "buildkite", pipeline: "my-pipeline"))

        XCTAssertEqual(expected, response.content)
    }
}
