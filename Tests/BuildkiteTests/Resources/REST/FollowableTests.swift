//
//  FollowableTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 8/28/21.
//  Copyright © 2021 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest

@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Followable {
    init() {
        self.init(url: URL())
    }
}

class FollowableTests: XCTestCase {
    func testFollowable() async throws {
        let expected = Organization()
        let context = try MockContext(content: Organization(), expected)

        let organizationResponse = try await context.client.send(.organization("buildkite"))
        let followableResponse = try await context.client.send(organizationResponse.content.url)

        XCTAssertEqual(expected, followableResponse.content)
    }
}
