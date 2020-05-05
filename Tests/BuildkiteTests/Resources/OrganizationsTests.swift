//
//  OrganizationsTests.swift
//  
//
//  Created by Aaron Sky on 5/4/20.
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
                  url: URL(),
                  webUrl: URL(),
                  name: "Buildkite",
                  slug: "buildkite",
                  pipelinesUrl: URL(),
                  agentsUrl: URL(),
                  emojisUrl: URL(),
                  createdAt: URL())
    }
}

class OrganizationsTests: XCTestCase {
    func testOrganizationsList() throws {
        let expected = [Organization()]
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(Organization.Resources.List()) { result in
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

        context.client.send(Organization.Resources.Get(organization: "buildkite")) { result in
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
