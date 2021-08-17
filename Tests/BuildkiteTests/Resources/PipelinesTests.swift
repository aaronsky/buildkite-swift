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
    init(steps: [Step] = []) {
        self.init(id: UUID(),
                  url: URL(),
                  webUrl: URL(),
                  name: "My Pipeline",
                  slug: "my-pipeline",
                  repository: "git@github.com:buildkite/agent.git",
                  branchConfiguration: nil,
                  defaultBranch: "master",
                  provider: Provider(id: "github",
                                     webhookUrl: URL(),
                                     settings: Provider.Settings(repository: nil,
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
                                                                 publishBlockedAsPending: nil)),
                  skipQueuedBranchBuilds: false,
                  skipQueuedBranchBuildsFilter: nil,
                  cancelRunningBranchBuilds: false,
                  cancelRunningBranchBuildsFilter: nil,
                  buildsUrl: URL(),
                  badgeUrl: URL(),
                  createdAt: Date(timeIntervalSince1970: 1000),
                  scheduledBuildsCount: 0,
                  runningBuildsCount: 0,
                  scheduledJobsCount: 0,
                  runningJobsCount: 0,
                  waitingJobsCount: 0,
                  visibility: "private",
                  steps: steps,
                  env: [:])
    }
}

class PipelinesTests: XCTestCase {
    func testPipelinesList() throws {
        let expected = [Pipeline(), Pipeline()]
        let context = try MockContext(content: expected)
        
        let expectation = XCTestExpectation()
        
        context.client.send(Pipeline.Resources.List(organization: "buildkite")) { result in
            do {
                let response = try result.get()
                XCTAssertEqual(expected, response.content)
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
    
    func testPipelinesGet() throws {
        let expected = Pipeline()
        let context = try MockContext(content: expected)
        
        let expectation = XCTestExpectation()
        
        context.client.send(Pipeline.Resources.Get(organization: "buildkite", pipeline: "my-pipeline")) { result in
            do {
                let response = try result.get()
                XCTAssertEqual(expected, response.content)
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
    
    func testPipelinesCreate() throws {
        let steps: [Pipeline.Step] = [
            .script(Pipeline.Step.Command(name: "📦",
                                          command: "echo true",
                                          label: "📦",
                                          env: [:],
                                          agentQueryRules: []))
        ]
        
        let expected = Pipeline(steps: steps)
        let context = try MockContext(content: expected)
        
        let resource = Pipeline.Resources.Create(organization: "buildkite",
                                                 body: Pipeline.Resources.Create.Body(name: "My Pipeline",
                                                                                      repository: URL(),
                                                                                      configuration: "steps:\n\t- label: \"📦\"\n\t  command: \"echo true\""))
        
        let expectation = XCTestExpectation()
        context.client.send(resource) { result in
            do {
                _ = try result.get()
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
    
    func testPipelinesCreateVisualSteps() throws {
        let steps: [Pipeline.Step] = [
            .script(Pipeline.Step.Command(name: "📦",
                                          command: "echo true",
                                          label: "📦",
                                          artifactPaths: "*",
                                          branchConfiguration: nil,
                                          env: [:],
                                          timeoutInMinutes: nil,
                                          agentQueryRules: [],
                                          async: nil,
                                          concurrency: nil,
                                          parallelism: nil)),
            .waiter(Pipeline.Step.Wait(label: "wait",
                                       continueAfterFailure: true)),
            .manual(Pipeline.Step.Block(label: "manual")),
            .trigger(Pipeline.Step.Trigger(triggerProjectSlug: "my-other-pipeline",
                                           label: "trigger",
                                           triggerCommit: nil,
                                           triggerBranch: nil,
                                           triggerAsync: nil))
        ]
        let expected = Pipeline(steps: steps)
        let context = try MockContext(content: expected)
        
        let resource = Pipeline.Resources.CreateVisualSteps(organization: "buildkite",
                                                            body: Pipeline.Resources.CreateVisualSteps.Body(name: "My Pipeline",
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
                                                                                                            teamUUIDs: nil))
        
        let expectation = XCTestExpectation()
        context.client.send(resource) { result in
            do {
                _ = try result.get()
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
    
    func testPipelinesUpdate() throws {
        let expected = Pipeline()
        let context = try MockContext(content: expected)
        
        let resource = Pipeline.Resources.Update(organization: "buildkite",
                                                 pipeline: "my-pipeline",
                                                 body: Pipeline.Resources.Update.Body(branchConfiguration: nil,
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
                                                                                      visibility: nil))
        
        let expectation = XCTestExpectation()
        context.client.send(resource) { result in
            do {
                _ = try result.get()
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
    
    func testPipelinesDelete() throws {
        let context = MockContext()
        
        let expectation = XCTestExpectation()
        
        context.client.send(Pipeline.Resources.Delete(organization: "buildkite", pipeline: "my-pipeline")) { result in
            do {
                _ = try result.get()
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
