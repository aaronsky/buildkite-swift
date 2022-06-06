//
//  UsersTests.swift
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

extension User {
    init() {
        self.init(
            id: UUID(),
            name: "Jeff",
            email: "jeff@buildkite.com",
            avatarUrl: URL(),
            createdAt: Date(timeIntervalSince1970: 1000)
        )
    }
}

class UsersTests: XCTestCase {
    func testUserMe() async throws {
        let expected = User()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.me)

        XCTAssertEqual(expected, response.content)
    }
}
