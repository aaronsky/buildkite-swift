//
//  EmojisTests.swift
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
extension Emoji {
    init() {
        self.init(name: "jeff",
                  url: URL())
    }
}

class EmojisTests: XCTestCase {
    func testEmojisList() throws {
        let expected = [Emoji(), Emoji()]
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(Emoji.Resources.List(organization: "buildkite")) { result in
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
