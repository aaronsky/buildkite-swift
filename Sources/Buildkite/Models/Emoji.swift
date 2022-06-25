//
//  Emoji.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Emoji: Codable, Equatable, Hashable, Sendable {
    public var name: String
    public var url: URL
    public var aliases: [String]? = []
}
