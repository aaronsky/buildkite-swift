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
    public enum Resources { }
}

extension User.Resources {
    public struct Me: Resource, HasResponseBody {
        public typealias Content = User
        public let path = "user"
        
        public init() {}
    }
}
