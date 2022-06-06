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
    func testGraphQLSuccess() async throws {
        let expected: JSONValue = ["jeff": [1, 2, 3], "horses": false]
        let content: JSONValue = ["data": expected]
        let context = try MockContext(content: content)

        let response = try await context.client.sendQuery(
            GraphQL<JSONValue>(rawQuery: "query MyQuery{jeff,horses}", variables: [:])
        )

        XCTAssertEqual(expected, response)
    }

    func testGraphQLErrors() async throws {
        let expected: GraphQL<JSONValue>.Errors = .init(
            errors: [
                .init(
                    message: "Field 'id' doesn't exist on type 'Query'",
                    locations: [.init(line: 2, column: 3)],
                    path: ["query SimpleQuery", "id"],
                    extensions: [
                        "code": "undefinedField",
                        "typeName": "Query",
                        "fieldName": "id",
                    ]
                )
            ],
            type: nil
        )

        let content: JSONValue = [
            "errors": .array(
                expected.errors.map { error in
                    let messageJSON: JSONValue = .string(error.message)
                    let locationsJSON: JSONValue
                    if let locations = error.locations {
                        locationsJSON = .array(
                            locations.map {
                                .object(["line": .number(Double($0.line)), "column": .number(Double($0.column))])
                            }
                        )
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
                        "extensions": extensionsJSON,
                    ]
                }
            )
        ]
        let context = try MockContext(content: content)

        do {
            _ = try await context.client.sendQuery(
                GraphQL<JSONValue>(rawQuery: "query MyQuery{jeff,horses}", variables: [:])
            )
            XCTFail("Expected to have failed with an error, but closure fulfilled normally")
        } catch let error as GraphQL<JSONValue>.Errors {
            XCTAssertEqual(expected, error)
        } catch {
            XCTFail("Expected to have failed with an error, but closure failed with unexpected error type")
        }
    }

    func testGraphQLIncompatibleResponse() async throws {
        let content: JSONValue = [:]
        let context = try MockContext(content: content)

        do {
            _ = try await context.client.sendQuery(GraphQL<JSONValue>(rawQuery: "", variables: [:]))
            XCTFail("Expected to have failed with an error, but closure fulfilled normally")
        } catch {}
    }

    func testGraphQLContentGet() throws {
        try XCTAssertNoThrow(GraphQL.Content.data("hello").get())
        try XCTAssertThrowsError(GraphQL<String>.Content.errors(.init(errors: [], type: nil)).get())
    }
}
