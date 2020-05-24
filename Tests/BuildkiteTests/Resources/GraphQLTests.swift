//
//  GraphQLTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/19/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest
@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class GraphQLTests: XCTestCase {
    func testGraphQL() throws {
        let expected: JSONValue = ["jeff": [1, 2, 3], "horses": false]
        let content: JSONValue = ["data": expected]
        let context = try MockContext(content: content)

        let expectation = XCTestExpectation()

        context.client.send(GraphQL<JSONValue>(rawQuery: "query MyQuery{jeff,horses}", variables: [:])) { result in
            do {
                let response = try result.get()
                XCTAssertEqual(expected, response.content.data)
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
