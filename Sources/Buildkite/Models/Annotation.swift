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

public struct Annotation: Codable, Equatable, Identifiable {
    public enum Context: String, Codable {
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
}
