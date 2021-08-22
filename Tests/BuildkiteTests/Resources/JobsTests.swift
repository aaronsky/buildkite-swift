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
    func testJobsRetryWaiter() throws {
        let expected: Job = .waiter(Job.Wait(id: UUID()))
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.retryJob(UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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

    func testJobsRetryTrigger() throws {
        let expected: Job = .trigger(Job.Trigger(name: nil,
                                                 state: nil,
                                                 buildUrl: URL(),
                                                 webUrl: URL(),
                                                 createdAt: Date(timeIntervalSince1970: 1000),
                                                 scheduledAt: nil,
                                                 finishedAt: nil,
                                                 runnableAt: nil,
                                                 triggeredBuild: Job.Trigger.TriggeredBuild(id: UUID(),
                                                                                            number: 0,
                                                                                            url: URL(),
                                                                                            webUrl: URL())))
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.retryJob(UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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

    func testJobsUnblock() throws {
        let expected: Job = .manual(Job.Block(id: UUID(),
                                              label: "",
                                              state: "",
                                              webUrl: nil,
                                              unblockedBy: User(),
                                              unblockedAt: Date(timeIntervalSince1970: 1000),
                                              unblockable: true,
                                              unblockUrl: URL()))
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.unblockJob(UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1, with: .init())) { result in
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

    func testJobsLogOutput() throws {
        let expected = Job.LogOutput()
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.logOutput(for: UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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

    #if !os(Linux)
    func testJobsLogOutputAlternativePlainText() throws {
        let expected = "hello friends"
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.logOutput(.plainText, for: UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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

    func testJobsLogOutputAlternativeHTML() throws {
        let expected = "hello friends"
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.logOutput(.html, for: UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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
    #endif

    func testJobsDeleteLogOutput() throws {
        let context = MockContext()

        let expectation = XCTestExpectation()

        context.client.send(.deleteLogOutput(for: UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
            do {
                _ = try result.get()
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testJobsEnvironmentVariables() throws {
        let expected = Job.EnvironmentVariables(env: [:])
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.environmentVariables(for: UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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

extension Job.LogOutput {
    init() {
        self.init(url: URL(),
                  content: "hello friends",
                  size: 13,
                  headerTimes: [])
    }
}
