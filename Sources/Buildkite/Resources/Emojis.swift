//
//  Emojis.swift
//  Buildkite
//
//  Created by Aaron Sky on 4/21/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Emoji {
    public enum Resources { }
}

extension Emoji.Resources {
    /// List emojis
    ///
    /// Returns a list of all the emojis for a given organization, including custom emojis and aliases. This list is not paginated.
    public struct List: Resource, HasResponseBody {
        public typealias Content = [Emoji]
        /// organization slug
        public var organization: String

        public var path: String {
            "organizations/\(organization)/emojis"
        }
        
        public init(organization: String) {
            self.organization = organization
        }
    }
}
