//
//  PaginationTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/7/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest
@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class PaginationTests: XCTestCase {
    func testPagination() throws {
        let expected = [Pipeline(), Pipeline()]
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(Pipeline.Resources.List(organization: "buildkite"), pageOptions: PageOptions(page: 1, perPage: 30)) { result in
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
