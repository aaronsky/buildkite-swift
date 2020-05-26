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
    func testGraphQLSuccess() throws {
        let expected: JSONValue = ["jeff": [1, 2, 3], "horses": false]
        let content: JSONValue = ["data": expected]
        let context = try MockContext(content: content)

        let expectation = XCTestExpectation()

        context.client.send(GraphQL<JSONValue>(rawQuery: "query MyQuery{jeff,horses}", variables: [:])) { result in
            do {
                let response = try result.get()
                XCTAssertEqual(GraphQL.Content.data(expected), response.content)
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testGraphQLErrors() throws {
        let expectedErrors: [GraphQL<JSONValue>.Content.Error] = [
            .init(message: "Field 'id' doesn't exist on type 'Query'",
                  locations: [.init(line: 2, column: 3)],
                  path: ["query SimpleQuery", "id"],
                  extensions: [
                    "code": "undefinedField",
                    "typeName": "Query",
                    "fieldName": "id"
            ])
        ]
        let expected: GraphQL<JSONValue>.Content = .errors(expectedErrors, type: nil)
        let content: JSONValue = [
            "errors": .array(expectedErrors.map { error in
                let messageJSON: JSONValue = .string(error.message)
                let locationsJSON: JSONValue
                if let locations = error.locations {
                    locationsJSON = .array(locations.map { .object(["line": .number(Double($0.line)), "column": .number(Double($0.column))]) })
                } else {
                    locationsJSON = .null
                }
                let pathJSON: JSONValue
                if let path = error.path {
                    pathJSON = .array(path.map { .string($0) })
                } else {
                    pathJSON = .null
                }
                let extensionsJSON = error.extensions ?? .null

                return [
                    "message": messageJSON,
                    "locations": locationsJSON,
                    "path": pathJSON,
                    "extensions": extensionsJSON
                ]
            })
        ]
        let context = try MockContext(content: content)

        let expectation = XCTestExpectation()

        context.client.send(GraphQL<JSONValue>(rawQuery: "query MyQuery{jeff,horses}", variables: [:])) { result in
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

    func testGraphQLIncompatibleResponse() throws {
        let content: JSONValue = [:]
        let context = try MockContext(content: content)

        let expectation = XCTestExpectation()

        context.client.send(GraphQL<JSONValue>(rawQuery: "", variables: [:])) {
            try? XCTAssertThrowsError($0.get(), "Expected to have failed with an error, but closure fulfilled normally")
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
