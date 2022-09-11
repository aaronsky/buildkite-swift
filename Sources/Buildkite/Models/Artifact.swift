//
//  Artifact.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Artifact: Codable, Equatable, Hashable, Identifiable, Sendable {
    public enum State: String, Codable, Equatable, Hashable, Sendable {
        case new
        case error
        case finished
        case deleted
    }

    public var id: UUID
    public var jobId: UUID
    public var url: Followable<Artifact.Resources.Get>
    public var downloadURL: Followable<Artifact.Resources.Download>
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

    private enum CodingKeys: String, CodingKey {
        case id
        case jobId = "job_id"
        case url
        case downloadURL = "download_url"
        case state
        case path
        case dirname
        case filename
        case mimeType = "mime_type"
        case fileSize = "file_size"
        case sha1sum
    }
}
