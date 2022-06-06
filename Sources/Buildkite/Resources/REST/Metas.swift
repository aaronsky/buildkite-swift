//
//  Metas.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/29/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Meta {
    /// Resources for requesting meta information about Buildkite.
    public enum Resources {}
}

extension Meta.Resources {
    /// Get an object with properties describing Buildkite
    ///
    /// Returns meta information about Buildkite.
    public struct Get: Resource {
        public typealias Content = Meta
        public let path = "meta"

        public init() {}
    }
}

extension Resource where Self == Meta.Resources.Get {
    /// Get an object with properties describing Buildkite
    ///
    /// Returns meta information about Buildkite.
    public static var meta: Self {
        Self()
    }
}
