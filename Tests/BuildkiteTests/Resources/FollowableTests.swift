//
//  FollowableTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 8/28/21.
//  Copyright © 2021 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest
@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Followable {
    init() {
        self.init(url: URL())
    }
}

class FollowableTests: XCTestCase {
    func testFollowable() throws {
        let expected = Organization()
        let context = try MockContext(content: Organization(), expected)

        let expectation = XCTestExpectation()

        context.client.send(.organization("buildkite")) { result in
            do {
                let response = try result.get()
                context.client.send(response.content.url) { result in
                    do {
                        let response = try result.get()
                        XCTAssertEqual(expected, response.content)
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                    expectation.fulfill()
                }
            } catch {
                XCTFail(error.localizedDescription)
            }
        }

        wait(for: [expectation])
    }
}
