//
//  AccessTokensTests.swift
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

class AccessTokensTests: XCTestCase {
    func testAccessTokenGet() throws {
        let expected = AccessToken(uuid: UUID(), scopes: [])
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.getAccessToken) { result in
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

    func testAccessTokenDelete() throws {
        let context = MockContext()

        let expectation = XCTestExpectation()

        context.client.send(.revokeAccessToken) { result in
            do {
                _ = try result.get()
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}
