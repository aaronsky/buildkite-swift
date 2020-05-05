//
//  JobsTests.swift
//  
//
//  Created by Aaron Sky on 5/4/20.
//

import Foundation
import XCTest
@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Job {
    init() {
        self.init(id: UUID(),
                  type: "script",
                  name: "📦",
                  stepKey: "package",
                  agentQueryRules: [],
                  state: "finished",
                  buildUrl: URL(),
                  webUrl: URL(),
                  logUrl: URL(),
                  rawLogUrl: URL(),
                  artifactsUrl: URL(),
                  command: "echo 1",
                  softFailed: false,
                  exitStatus: 0,
                  artifactPaths: "",
                  agent: nil,
                  createdAt: Date(timeIntervalSince1970: 1000),
                  scheduledAt: Date(timeIntervalSince1970: 1000),
                  runnableAt: nil,
                  startedAt: nil,
                  finishedAt: nil,
                  retried: false,
                  retriedInJobId: UUID(),
                  retriesCount: 0,
                  parallelGroupIndex: nil,
                  parallelGroupTotal: nil)
    }
}

class JobsTests: XCTestCase {
    func testJobsRetry() throws {
        let expected = Job()
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(Job.Resources.Retry(organization: "buildkite", pipeline: "my-pipeline", build: 1, job: UUID())) { result in
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
        let expected = Job()
        let context = try MockContext(content: expected)

        let body = Job.Resources.Unblock.Body()
        let resource = Job.Resources.Unblock(organization: "buildkite", pipeline: "my-pipeline", build: 1, job: UUID(), body: body)

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

    func testJobsLogOutput() throws {
        let context = MockContext()

        let expectation = XCTestExpectation()

        context.client.send(Job.Resources.LogOutput(organization: "buildkite", pipeline: "my-pipeline", build: 1, job: UUID())) { result in
            do {
                _ = try result.get()
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testJobsDeleteLogOutput() throws {
        let context = MockContext()

        let expectation = XCTestExpectation()

        context.client.send(Job.Resources.DeleteLogOutput(organization: "buildkite", pipeline: "my-pipeline", build: 1, job: UUID())) { result in
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

        context.client.send(Job.Resources.EnvironmentVariables(organization: "buildkite", pipeline: "my-pipeline", build: 1, job: UUID())) { result in
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
