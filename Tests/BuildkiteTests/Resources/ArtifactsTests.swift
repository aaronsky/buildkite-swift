//
//  ArtifactsTests.swift
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

extension Artifact {
    init() {
        self.init(id: UUID(),
                  jobId: UUID(),
                  url: URL(),
                  downloadUrl: URL(),
                  state: .new,
                  path: "",
                  dirname: "",
                  filename: "",
                  mimeType: "",
                  fileSize: 0,
                  sha1sum: "")
    }
}

class ArtifactsTests: XCTestCase {
    func testArtifactsListByBuild() throws {
        let expected = [Artifact(), Artifact()]
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.artifacts(byBuild: 1, in: "buildkite", pipeline: "my-pipeline")) { result in
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

    func testArtifactsListByJob() throws {
        let expected = [Artifact(), Artifact()]
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.artifacts(byJob: UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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

    func testArtifactsGet() throws {
        let expected = Artifact()
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.artifact(UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1, job: UUID())) { result in
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

    func testArtifactsDownload() throws {
        let expected = Artifact.URLs(url: URL())
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.downloadArtifact(UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1, job: UUID())) { result in
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

    func testArtifactsDelete() throws {
        let context = MockContext()

        let expectation = XCTestExpectation()

        context.client.send(.deleteArtifact(UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1, job: UUID())) { result in
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
