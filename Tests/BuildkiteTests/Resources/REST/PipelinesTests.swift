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

extension Pipeline {
    init(
        steps: [Step] = []
    ) {
        self.init(
            id: UUID(),
            url: Followable(),
            webUrl: URL(),
            name: "My Pipeline",
            slug: "my-pipeline",
            repository: "git@github.com:buildkite/agent.git",
            branchConfiguration: nil,
            defaultBranch: "master",
            provider: Provider(
                id: "github",
                webhookUrl: URL(),
                settings: Provider.Settings(
                    repository: nil,
                    buildPullRequests: nil,
                    pullRequestBranchFilterEnabled: nil,
                    pullRequestBranchFilterConfiguration: nil,
                    skipPullRequestBuildsForExistingCommits: nil,
                    buildTags: nil,
                    publishCommitStatus: nil,
                    publishCommitStatusPerStep: nil,
                    triggerMode: nil,
                    filterEnabled: nil,
                    filterCondition: nil,
                    buildPullRequestForks: nil,
                    prefixPullRequestForkBranchNames: nil,
                    separatePullRequestStatuses: nil,
                    publishBlockedAsPending: nil
                )
            ),
            skipQueuedBranchBuilds: false,
            skipQueuedBranchBuildsFilter: nil,
            cancelRunningBranchBuilds: false,
            cancelRunningBranchBuildsFilter: nil,
            buildsUrl: Followable(),
            badgeUrl: URL(),
            createdAt: Date(timeIntervalSince1970: 1000),
            scheduledBuildsCount: 0,
            runningBuildsCount: 0,
            scheduledJobsCount: 0,
            runningJobsCount: 0,
            waitingJobsCount: 0,
            visibility: "private",
            steps: steps,
            env: [:]
        )
    }
}

class PipelinesTests: XCTestCase {
    func testPipelinesList() async throws {
        let expected = [Pipeline(), Pipeline()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.pipelines(in: "buildkite"))

        XCTAssertEqual(expected, response.content)
    }

    func testPipelinesGet() async throws {
        let expected = Pipeline()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.pipeline("buildkite", in: "organization"))

        XCTAssertEqual(expected, response.content)
    }

    func testPipelinesCreate() async throws {
        let steps: [Pipeline.Step] = [
            .script(
                Pipeline.Step.Command(
                    name: "📦",
                    command: "echo true",
                    label: "📦",
                    env: [:],
                    agentQueryRules: []
                )
            )
        ]

        let expected = Pipeline(steps: steps)
        let context = try MockContext(content: expected)

        _ = try await context.client.send(
            .createPipeline(
                .init(
                    name: "My Pipeline",
                    repository: URL(),
                    configuration: "steps:\n\t- label: \"📦\"\n\t  command: \"echo true\""
                ),
                in: "buildkite"
            )
        )
    }

    func testPipelinesCreateVisualSteps() async throws {
        let steps: [Pipeline.Step] = [
            .script(
                Pipeline.Step.Command(
                    name: "📦",
                    command: "echo true",
                    label: "📦",
                    artifactPaths: "*",
                    branchConfiguration: nil,
                    env: [:],
                    timeoutInMinutes: nil,
                    agentQueryRules: [],
                    async: nil,
                    concurrency: nil,
                    parallelism: nil
                )
            ),
            .waiter(
                Pipeline.Step.Wait(
                    label: "wait",
                    continueAfterFailure: true
                )
            ),
            .manual(Pipeline.Step.Block(label: "manual")),
            .trigger(
                Pipeline.Step.Trigger(
                    triggerProjectSlug: "my-other-pipeline",
                    label: "trigger",
                    triggerCommit: nil,
                    triggerBranch: nil,
                    triggerAsync: nil
                )
            ),
        ]
        let expected = Pipeline(steps: steps)
        let context = try MockContext(content: expected)

        _ = try await context.client.send(
            .createVisualStepsPipeline(
                .init(
                    name: "My Pipeline",
                    repository: URL(),
                    steps: steps,
                    branchConfiguration: nil,
                    cancelRunningBranchBuilds: nil,
                    cancelRunningBranchBuildsFilter: nil,
                    defaultBranch: nil,
                    description: nil,
                    env: nil,
                    providerSettings: nil,
                    skipQueuedBranchBuilds: nil,
                    skipQueuedBranchBuildsFilter: nil,
                    teamUUIDs: nil
                ),
                in: "buildkite"
            )
        )
    }

    func testPipelinesUpdate() async throws {
        let expected = Pipeline()
        let context = try MockContext(content: expected)

        _ = try await context.client.send(
            .updatePipeline(
                "my-pipeline",
                in: "buildkite",
                with: .init(
                    branchConfiguration: nil,
                    cancelRunningBranchBuilds: nil,
                    cancelRunningBranchBuildsFilter: nil,
                    defaultBranch: nil,
                    description: nil,
                    env: nil,
                    name: nil,
                    providerSettings: nil,
                    repository: nil,
                    steps: nil,
                    skipQueuedBranchBuilds: nil,
                    skipQueuedBranchBuildsFilter: nil,
                    visibility: nil
                )
            )
        )
    }

    func testPipelinesDelete() async throws {
        let context = MockContext()

        _ = try await context.client.send(.deletePipeline("my-pipeline", in: "buildkite"))
    }
}
