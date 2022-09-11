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

public struct Annotation: Codable, Equatable, Hashable, Identifiable, Sendable {
    public enum Context: String, Codable, Hashable, Sendable {
        case success
        case info
        case warning
        case error
    }

    public var id: UUID
    public var context: String
    public var style: Context
    public var bodyHtml: String
    public var createdAt: Date
    public var updatedAt: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case context
        case style
        case bodyHtml = "body_html"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
