//
//  URL+Buildkite.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/5/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
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
