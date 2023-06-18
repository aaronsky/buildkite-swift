//
//  ClusterQueuesTests.swift
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

extension ClusterQueue {
    init() {
        self.init(
            id: UUID(),
            graphqlId: "",
            key: "",
            description: "",
            url: .init(),
            webURL: URL(),
            clusterURL: .init(),
            dispatchPaused: false,
            dispatchPausedBy: nil,
            dispatchPausedAt: nil,
            dispatchPausedNote: nil,
            createdAt: Date(timeIntervalSince1970: 1000),
            createdBy: nil
        )
    }
}

class ClusterQueuesTests: XCTestCase {
    func testClusterQueuesList() async throws {
        let expected = [ClusterQueue(), ClusterQueue()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.clusterQueues(in: "organization", clusterId: UUID()))

        XCTAssertEqual(expected, response.content)
    }

    func testClusterQueuesGet() async throws {
        let expected = ClusterQueue()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.clusterQueue(UUID(), in: "organization", clusterId: UUID()))

        XCTAssertEqual(expected, response.content)
    }

    func testClusterQueuesCreate() async throws {
        let expected = ClusterQueue()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .createClusterQueue(.init(key: "", description: ""), in: "organization", clusterId: UUID())
        )

        XCTAssertEqual(expected, response.content)
    }

    func testClusterQueuesUpdate() async throws {
        let expected = ClusterQueue()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .updateClusterQueue(UUID(), in: "organization", clusterId: UUID(), with: "")
        )

        XCTAssertEqual(expected, response.content)
    }

    func testClusterQueuesDelete() async throws {
        let context = MockContext()

        _ = try await context.client.send(.deleteClusterQueue(UUID(), in: "organization", clusterId: UUID()))
    }

    func testClusterQueuesResumeDispatch() async throws {
        let context = MockContext()

        _ = try await context.client.send(.resumeClusterQueueDispatch(UUID(), in: "organization", clusterId: UUID()))
    }
}
