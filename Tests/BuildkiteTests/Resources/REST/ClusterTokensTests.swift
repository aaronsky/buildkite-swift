//
//  ClusterTokensTests.swift
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

extension ClusterToken {
    init() {
        self.init(
            id: UUID(),
            graphqlId: "",
            description: "",
            url: .init(),
            clusterURL: .init(),
            createdAt: Date(timeIntervalSince1970: 1000),
            createdBy: nil,
            token: nil
        )
    }
}

class ClusterTokensTests: XCTestCase {
    func testClusterTokensList() async throws {
        let expected = [ClusterToken(), ClusterToken()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.clusterTokens(in: "organization", clusterId: UUID()))

        XCTAssertEqual(expected, response.content)
    }

    func testClusterTokensGet() async throws {
        let expected = ClusterToken()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.clusterToken(UUID(), in: "organization", clusterId: UUID()))

        XCTAssertEqual(expected, response.content)
    }

    func testClusterTokensCreate() async throws {
        let expected = ClusterToken()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .createClusterToken(with: "", in: "organization", clusterId: UUID())
        )

        XCTAssertEqual(expected, response.content)
    }

    func testClusterTokensUpdate() async throws {
        let expected = ClusterToken()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(
            .updateClusterToken(UUID(), in: "organization", clusterId: UUID(), with: "")
        )

        XCTAssertEqual(expected, response.content)
    }

    func testClusterTokensDelete() async throws {
        let context = MockContext()

        _ = try await context.client.send(.deleteClusterToken(UUID(), in: "organization", clusterId: UUID()))
    }
}
