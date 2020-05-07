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

private extension Team {
    init() {
        self.init(id: UUID(),
                  name: "",
                  slug: "",
                  description: "",
                  privacy: .visible,
                  default: true,
                  createdAt: Date(timeIntervalSince1970: 1000),
                  createdBy: User())
    }
}

class TeamsTests: XCTestCase {
    func testTeamsList() throws {
        let expected = [Team(), Team()]
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(Team.Resources.List(organization: "buildkite", userId: UUID(), pageOptions: PageOptions(page: 1, perPage: 30))) { result in
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
}
