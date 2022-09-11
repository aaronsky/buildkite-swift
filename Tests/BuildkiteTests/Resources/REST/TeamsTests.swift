//
//  TeamsTests.swift
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

extension Team {
    fileprivate init() {
        self.init(
            id: UUID(),
            graphqlId: "",
            name: "",
            slug: "",
            description: "",
            privacy: .visible,
            default: true,
            createdAt: Date(timeIntervalSince1970: 1000),
            createdBy: User()
        )
    }
}

class TeamsTests: XCTestCase {
    func testTeamsList() async throws {
        let expected = [Team(), Team()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.teams(in: "buildkite", byUser: UUID()))

        XCTAssertEqual(expected, response.content)
    }
}
