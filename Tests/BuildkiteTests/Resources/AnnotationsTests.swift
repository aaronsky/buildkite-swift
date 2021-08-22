//
//  AnnotationsTests.swift
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

extension Annotation {
    init() {
        self.init(id: UUID(),
                  context: "message",
                  style: .info,
                  bodyHtml: "<div></div>",
                  createdAt: Date(timeIntervalSince1970: 1000),
                  updatedAt: Date(timeIntervalSince1970: 1001))
    }
}

class AnnotationsTests: XCTestCase {
    func testAnnotationsList() throws {
        let expected = [Annotation(), Annotation()]
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(.annotations(in: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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
