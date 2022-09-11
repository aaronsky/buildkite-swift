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
        self.init(
            id: UUID(),
            jobId: UUID(),
            url: Followable(),
            downloadURL: Followable(),
            state: .new,
            path: "",
            dirname: "",
            filename: "",
            mimeType: "",
            fileSize: 0,
            sha1sum: ""
        )
    }
}

class ArtifactsTests: XCTestCase {
    func testArtifactsListByBuild() async throws {
        let expected = [Artifact(), Artifact()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.artifacts(byBuild: 1, in: "buildkite", pipeline: "my-pipeline"))

        XCTAssertEqual(expected, response.content)
    }

    func testArtifactsListByJob() async throws {
        let expected = [Artifact(), Artifact()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .artifacts(byJob: UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1)
        )

        XCTAssertEqual(expected, response.content)
    }

    func testArtifactsGet() async throws {
        let expected = Artifact()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .artifact(UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1, job: UUID())
        )

        XCTAssertEqual(expected, response.content)
    }

    func testArtifactsDownload() async throws {
        let expected = Artifact.URLs(url: URL())
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .downloadArtifact(UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1, job: UUID())
        )

        XCTAssertEqual(expected, response.content)
    }

    func testArtifactsDelete() async throws {
        let context = MockContext()

        _ = try await context.client.send(
            .deleteArtifact(UUID(), in: "buildkite", pipeline: "my-pipeline", build: 1, job: UUID())
        )
    }
}
