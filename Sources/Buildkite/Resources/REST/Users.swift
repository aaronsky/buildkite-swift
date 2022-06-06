//
//  Users.swift
//  Buildkite
//
//  Created by Aaron Sky on 4/21/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension User {
    /// Resources for performing operations on the currently-authenticated user.
    public enum Resources {}
}

extension User.Resources {
    /// Get the current user
    ///
    /// Returns details about the currently-authenticated user.
    public struct Me: Resource {
        public typealias Content = User
        public let path = "user"

        public init() {}
    }
}

extension Resource where Self == User.Resources.Me {
    /// Get the current user
    ///
    /// Returns details about the currently-authenticated user.
    public static var me: Self {
        Self()
    }
}
