//
//  ArtifactsTests.swift
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

        context.client.send(Artifact.Resources.ListByBuild(organization: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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

        context.client.send(Artifact.Resources.ListByJob(organization: "buildkite", pipeline: "my-pipeline", build: 1, jobId: UUID())) { result in
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

        context.client.send(Artifact.Resources.Get(organization: "buildkite", pipeline: "my-pipeline", build: 1, jobId: UUID(), artifactId: UUID())) { result in
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
        let context = MockContext()

        let expectation = XCTestExpectation()

        context.client.send(Artifact.Resources.Download(organization: "buildkite", pipeline: "my-pipeline", build: 1, jobId: UUID(), artifactId: UUID())) { result in
            do {
                _ = try result.get()
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

        context.client.send(Artifact.Resources.Delete(organization: "buildkite", pipeline: "my-pipeline", build: 1, jobId: UUID(), artifactId: UUID())) { result in
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
