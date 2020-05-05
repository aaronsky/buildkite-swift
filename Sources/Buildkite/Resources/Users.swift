//
//  Users.swift
//  
//
//  Created by Aaron Sky on 4/21/20.
//

import Foundation

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
