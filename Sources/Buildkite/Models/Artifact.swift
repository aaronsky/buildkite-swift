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

/// An artifact is a file uploaded by your agent during the execution of a build's job. The
/// contents of the artifact can be retrieved using the ``downloadURL`` and the [artifact download]() API.
/// Artifacts are created using ``Pipeline/Step/Command/artifactPaths`` on a pipeline, or the
/// [buildkite-agent artifact command](https://buildkite.com/docs/agent/v3/cli-artifact) from within a job.
public struct Artifact: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the artifact
    public var id: UUID
    /// ID of the job the artifact was uploaded from.
    public var jobId: UUID
    /// Followable URL to this specific artifact's information.
    public var url: Followable<Artifact.Resources.Get>
    /// Followable URL to this artifact's download information.
    public var downloadURL: Followable<Artifact.Resources.Download>
    /// The upload state of the artifact.
    public var state: State
    /// The full path of the artifact.
    public var path: String
    /// The directory the artifact file was stored in.
    public var dirname: String
    /// The basename of the artifact file.
    public var filename: String
    /// The MIME type of the artifact file
    public var mimeType: String
    /// The size in bytes of the artifact file
    public var fileSize: Int
    /// The artifact's checksum
    public var sha1sum: String

    public enum State: String, Codable, Equatable, Hashable, Sendable {
        case new
        case error
        case finished
        case deleted
    }

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
