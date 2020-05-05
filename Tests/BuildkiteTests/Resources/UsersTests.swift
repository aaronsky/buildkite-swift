//
//  UsersTests.swift
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

extension User {
    init() {
        self.init(id: UUID(),
                  name: "Jeff",
                  email: "jeff@buildkite.com",
                  avatarUrl: URL(),
                  createdAt: Date(timeIntervalSince1970: 1000))
    }
}

class UsersTests: XCTestCase {
    func testUserMe() throws {
        let expected = User()
        let context = try MockContext(content: expected)

        let expectation = XCTestExpectation()

        context.client.send(User.Resources.Me()) { result in
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
