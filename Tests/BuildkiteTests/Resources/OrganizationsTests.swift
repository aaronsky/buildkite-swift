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
        self.init(id: UUID(),
                  url: Followable(),
                  webUrl: URL(),
                  name: "Buildkite",
                  slug: "buildkite",
                  pipelinesUrl: Followable(),
                  agentsUrl: Followable(),
                  emojisUrl: Followable(),
                  createdAt: Date(timeIntervalSince1970: 1000))
    }
}

class OrganizationsTests: XCTestCase {
    func testOrganizationsList() throws {
        let expected = [Organization()]
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.organizations) { result in
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

    func testOrganizationsGet() throws {
        let expected = Organization()
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.organization("buildkite")) { result in
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
