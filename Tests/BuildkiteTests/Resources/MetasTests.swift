//
//  MetasTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/29/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest

@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class MetasTests: XCTestCase {
    func testMetaGet() async throws {
        let expected = Meta(webhookIPRanges: ["1.1.1.1/32"])
        let context = try MockContext(content: expected)

        let response = try await context.client.send(.meta)

        XCTAssertEqual(expected, response.content)
    }
}
