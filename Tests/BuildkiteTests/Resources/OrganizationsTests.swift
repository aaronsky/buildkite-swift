//
//  OrganizationsTests.swift
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

extension Organization {
    init() {
        self.init(
            id: UUID(),
            url: Followable(),
            webUrl: URL(),
            name: "Buildkite",
            slug: "buildkite",
            pipelinesUrl: Followable(),
            agentsUrl: Followable(),
            emojisUrl: Followable(),
            createdAt: Date(timeIntervalSince1970: 1000)
        )
    }
}

class OrganizationsTests: XCTestCase {
    func testOrganizationsList() async throws {
        let expected = [Organization()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.organizations)

        XCTAssertEqual(expected, response.content)
    }

    func testOrganizationsGet() async throws {
        let expected = Organization()
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.organization("buildkite"))

        XCTAssertEqual(expected, response.content)
    }
}
