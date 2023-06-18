//
//  ClustersTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/18/23.
//  Copyright © 2023 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest

@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Cluster {
    init() {
        self.init(
            id: UUID(),
            graphqlId: "",
            defaultQueueId: UUID(),
            name: "",
            description: "",
            emoji: "",
            color: "",
            url: .init(),
            webURL: URL(),
            queuesURL: .init(),
            defaultQueueURL: .init(),
            createdAt: Date(timeIntervalSince1970: 1000),
            createdBy: nil
        )
    }
}

class ClustersTests: XCTestCase {
    func testClustersList() async throws {
        let expected = [Cluster(), Cluster()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.clusters(in: "buildkite"))

        XCTAssertEqual(expected, response.content)
    }

    func testClustersGet() async throws {
        let expected = Cluster()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.cluster(UUID(), in: "organization"))

        XCTAssertEqual(expected, response.content)
    }

    func testClustersCreate() async throws {
        let expected = Cluster()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .createCluster(.init(name: "", description: nil, emoji: nil, color: nil), in: "organization")
        )

        XCTAssertEqual(expected, response.content)
    }

    func testClustersUpdate() async throws {
        let expected = Cluster()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .updateCluster(
                UUID(),
                in: "organization",
                with: .init(name: "", description: "", emoji: "", color: "", defaultQueueId: UUID())
            )
        )

        XCTAssertEqual(expected, response.content)
    }

    func testClustersDelete() async throws {
        let context = MockContext()

        _ = try await context.client.send(.deleteCluster(UUID(), in: "organization"))
    }
}
