//
//  User.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Fangamer. All rights reserved.
//

import Foundation

public struct User: Codable, Equatable {
    public var id: UUID
    public var name: String
    public var email: String
    public var avatarUrl: URL
    public var createdAt: Date
}
