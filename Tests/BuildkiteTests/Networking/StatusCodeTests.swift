//
//  StatusCodeTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/23/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest

@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class StatusCodeTests: XCTestCase {
    func testFlag() {
        XCTAssertTrue(StatusCode.ok.isSuccess)
        XCTAssertTrue(StatusCode.created.isSuccess)
        XCTAssertTrue(StatusCode.accepted.isSuccess)
        XCTAssertTrue(StatusCode.noContent.isSuccess)
        XCTAssertFalse(StatusCode.unauthorized.isSuccess)
        XCTAssertFalse(StatusCode.notFound.isSuccess)
        XCTAssertFalse(StatusCode.internalServerError.isSuccess)
    }
}
