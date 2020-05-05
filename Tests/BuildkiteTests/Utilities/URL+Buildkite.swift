//
//  URL+Buildkite.swift
//  
//
//  Created by Aaron Sky on 5/5/20.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension URL {
    init() {
        self.init(string: "https://www.buildkite.com")!
    }
}
