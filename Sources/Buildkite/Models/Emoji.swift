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

/// Buildkite supports emojis (using the :emoji: syntax) in build step names and build log header groups.
/// The Emoji API allows you to fetch the list of emojis for an organization so you can display emojis
/// correctly in your own integrations.
///
/// Emojis can be found in text using the pattern `/:([\w+-]+):/`.
public struct Emoji: Codable, Equatable, Hashable, Sendable {
    /// Name of the emoji.
    public var name: String
    /// URL of the emoji's image.
    public var url: URL
    /// Aliases configured with this emoji, if any.
    public var aliases: [String]? = []

    public init(name: String, url: URL, aliases: [String]? = nil) {
        self.name = name
        self.url = url
        self.aliases = aliases
    }
}
