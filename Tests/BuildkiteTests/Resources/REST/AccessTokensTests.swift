//
//  AccessTokensTests.swift
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

class AccessTokensTests: XCTestCase {
    func testAccessTokenGet() async throws {
        let expected = AccessToken(uuid: UUID(), scopes: [])
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.getAccessToken)

        XCTAssertEqual(expected, response.content)
    }

    func testAccessTokenDelete() async throws {
        let context = MockContext()
        _ = try await context.client.send(.revokeAccessToken)
    }
}
