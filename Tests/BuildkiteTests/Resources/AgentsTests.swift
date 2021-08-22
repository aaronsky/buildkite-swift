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
        let job = Job.script(Job.Command(id: UUID(),
                                         name: "📦",
                                         state: "passed",
                                         command: nil,
                                         stepKey: nil,
                                         buildUrl: URL(),
                                         webUrl: URL(),
                                         logUrl: URL(),
                                         rawLogUrl: URL(),
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
                                         parallelGroupTotal: nil))

        self.init(id: UUID(),
                  url: URL(),
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
                  metaData: [])
    }
}

class AgentsTests: XCTestCase {
    func testAgentsList() throws {
        let expected = [Agent(), Agent()]
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.agents(in: "buildkite")) { result in
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

    func testAgentsGet() throws {
        let expected = Agent()
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()
        context.client.send(.agent(UUID(), in: "buildkite")) { result in
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

    func testAgentsStop() throws {
        let context = MockContext()

        let expectation = XCTestExpectation()

        context.client.send(.stopAgent(UUID(), in: "buildkite", force: true)) { result in
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
