//
//  StatusCodeTests.swift
//  
//
//  Created by Aaron Sky on 3/23/20.
//

import Foundation
import XCTest
@testable import Buildkite

class StatusCodeTests: XCTestCase {
    func testFlag() {
        XCTAssertTrue(StatusCode.ok.isSuccess)
        XCTAssertTrue(StatusCode.created.isSuccess)
        XCTAssertTrue(StatusCode.accepted.isSuccess)
        XCTAssertFalse(StatusCode.paymentRequired.isSuccess)
        XCTAssertFalse(StatusCode.unauthorized.isSuccess)
        XCTAssertFalse(StatusCode.notFound.isSuccess)
    }
}
