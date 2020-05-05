//
//  Extensions.swift
//  
//
//  Created by Aaron Sky on 3/24/20.
//

import Foundation
import XCTest

enum Constants {
    fileprivate static let asyncTestTimeout = 1.0
}

extension XCTestCase {
    func wait(for expectations: [XCTestExpectation]) {
        wait(for: expectations, timeout: Constants.asyncTestTimeout)
    }
}
