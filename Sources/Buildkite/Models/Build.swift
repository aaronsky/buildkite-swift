//
//  Build.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Fangamer. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Build: Codable, Equatable {
    public var id: UUID
    public var url: URL
    public var webUrl: URL
    public var number: Int
    public var state: String
    public var blocked: Bool
    public var message: String?
    public var commit: String
    public var branch: String
    public var env: [String: String]?
    public var source: String
    public var creator: User?
    public var jobs: [Job]
    public var createdAt: Date
    public var scheduledAt: Date
    public var startedAt: Date?
    public var finishedAt: Date?
    public var metaData: [String: String]
    public var pullRequest: [String: String?]?
    public var pipeline: Pipeline
}
