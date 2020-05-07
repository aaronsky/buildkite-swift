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
        self.init(id: UUID(),
                  url: URL(),
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
                  pipeline: Pipeline())
    }
}

class BuildsTests: XCTestCase {
    func testBuildsListAllDefaultQuery() throws {
        let expected = [Build(), Build()]
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(Build.Resources.ListAll()) { result in
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

    func testBuildsListAllSpecializedQuery() throws {
        let expected = [Build(), Build()]
        let context = try MockContext(content: expected)

        let resource = Build.Resources.ListAll(queryOptions: Build.Resources.QueryOptions(branches: ["master"],
                                                                                          commit: "HEAD",
                                                                                          createdFrom: Date(timeIntervalSince1970: 1000),
                                                                                          createdTo: Date(timeIntervalSince1970: 1000),
                                                                                          creator: UUID(),
                                                                                          finishedFrom: Date(timeIntervalSince1970: 1000),
                                                                                          includeRetriedJobs: true,
                                                                                          metadata: ["buildkite": "is cool"],
                                                                                          state: [.passed, .blocked, .failed]))

        let expectation = XCTestExpectation()

        context.client.send(resource) { result in
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

    func testBuildsListForOrganization() throws {
        let expected = [Build(), Build()]
        let context = try MockContext(content: expected)

        let resource = Build.Resources.ListForOrganization(organization: "buildkite", queryOptions: Build.Resources.QueryOptions())
        
        let expectation = XCTestExpectation()

        context.client.send(resource) { result in
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

    func testBuildsListForPipeline() throws {
        let expected = [Build(), Build()]
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(Build.Resources.ListForPipeline(organization: "buildkite", pipeline: "my-pipeline")) { result in
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

    func testBuildsGet() throws {
        let expected = Build()
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(Build.Resources.Get(organization: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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

    func testBuildsCreate() throws {
        let expected = Build()
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        let body = Build.Resources.Create.Body(commit: "HEAD",
                                               branch: "master",
                                               author: nil,
                                               cleanCheckout: nil,
                                               env: nil,
                                               ignorePipelineBranchFilters: nil,
                                               message: nil,
                                               metaData: nil,
                                               pullRequestBaseBranch: nil,
                                               pullRequestId: nil,
                                               pullRequestRepository: nil)

        context.client.send(Build.Resources.Create(organization: "buildkite", pipeline: "my-pipeline", body: body)) { result in
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

    func testBuildsCancel() throws {
        let expected = Build()
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(Build.Resources.Cancel(organization: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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

    func testBuildsRebuild() throws {
        let expected = Build()
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(Build.Resources.Rebuild(organization: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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
}
