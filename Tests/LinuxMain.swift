import XCTest

import BuildkiteTests

var tests = [XCTestCaseEntry]()
tests += BuildkiteTests.__allTests()

XCTMain(tests)
