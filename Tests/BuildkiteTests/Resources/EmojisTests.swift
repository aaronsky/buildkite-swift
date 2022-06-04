//
//  EmojisTests.swift
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

extension Emoji {
    init() {
        self.init(
            name: "jeff",
            url: URL()
        )
    }
}

class EmojisTests: XCTestCase {
    func testEmojisList() async throws {
        let expected = [Emoji(), Emoji()]
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.emojis(in: "buildkite"))

        XCTAssertEqual(expected, response.content)
    }
}
