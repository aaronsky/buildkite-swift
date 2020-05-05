//
//  AnnotationsTests.swift
//  
//
//  Created by Aaron Sky on 5/4/20.
//

import XCTest
@testable import Buildkite

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

        context.client.send(Annotation.Resources.List(organization: "buildkite", pipeline: "my-pipeline", build: 1)) { result in
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
