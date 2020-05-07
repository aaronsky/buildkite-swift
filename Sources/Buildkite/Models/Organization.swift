//
//  Organization.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Organization: Codable, Equatable {
    public var id: UUID
    public var url: URL
    public var webUrl: URL
    public var name: String
    public var slug: String
    public var pipelinesUrl: URL
    public var agentsUrl: URL
    public var emojisUrl: URL
    public var createdAt: URL
}
