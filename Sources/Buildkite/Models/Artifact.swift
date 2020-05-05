//
//  Artifact.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Fangamer. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Artifact: Codable, Equatable {
    public enum State: String, Codable, Equatable {
        case new
        case error
        case finished
        case deleted
    }

    public var id: UUID
    public var jobId: UUID
    public var url: URL
    public var downloadUrl: URL
    public var state: State
    public var path: String
    public var dirname: String
    public var filename: String
    public var mimeType: String
    public var fileSize: Int
    public var sha1sum: String

    public struct URLs: Codable, Equatable {
        public var url: URL
    }
}
