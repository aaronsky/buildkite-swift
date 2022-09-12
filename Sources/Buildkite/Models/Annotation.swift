//
//  Annotation.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// An annotation is a snippet of Markdown uploaded by your agent during the execution of a build's job.
/// Annotations are created using the [buildkite-agent annotate command](https://buildkite.com/docs/agent/v3/cli-annotate) from within a job.
public struct Annotation: Codable, Equatable, Hashable, Identifiable, Sendable {
    /// ID of the annotation.
    public var id: UUID
    /// The "context" specified when annotating the build. Only one annotation per build may have any given context value.
    public var context: String
    /// The style of the annotation.
    public var style: Style
    /// Rendered HTML of the annotation's body.
    public var bodyHtml: String
    /// When the annotation was first created.
    public var createdAt: Date
    /// When the annotation was last added to or replaced.
    public var updatedAt: Date

    public enum Style: String, Codable, Hashable, Sendable {
        case success
        case info
        case warning
        case error
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case context
        case style
        case bodyHtml = "body_html"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
