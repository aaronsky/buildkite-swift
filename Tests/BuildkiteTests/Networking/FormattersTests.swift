//
//  FormattersTests.swift
//  Buildkite
//
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest

@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class FormattersTests: XCTestCase {
    func testDecode() throws {
        // let expected = DateComponents(
        //     year: 2020, 
        //     month: 3, 
        //     day: 14, 
        //     hour: 20, 
        //     minute: 4, 
        //     second: 43
        // ).date!
        // let actual = try XCTUnwrap(
        //     Formatters.dateIfPossible(
        //         fromISO8601: "2020-03-14T20:04:43.567Z"
        //     )
        // )
        // XCTAssertEqual(actual, expected)
    }

    func testEncode() {

    }
}
