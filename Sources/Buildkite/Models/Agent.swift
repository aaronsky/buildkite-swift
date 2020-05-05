//
//  Agent.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Fangamer. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Agent: Codable, Equatable {
    public var id: UUID
    public var url: URL
    public var webUrl: URL
    public var name: String
    public var connectionState: String
    public var hostname: String
    public var ipAddress: String
    public var userAgent: String
    public var version: String
    public var creator: User?
    public var createdAt: Date
    public var job: Job?
    public var lastJobFinishedAt: Date?
    public var priority: Int?
    public var metaData: [String]
}
