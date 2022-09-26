//
//  AccessToken.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Information about an access token registered with Buildkite.
public struct AccessToken: Codable, Equatable, Hashable, Sendable {
    /// ID of the access token, but not the token itself.
    public var uuid: UUID
    /// [API scopes](https://buildkite.com/docs/apis/managing-api-tokens#token-scopes) the token has access to.
    public var scopes: [String]

    public init(uuid: UUID, scopes: [String]) {
        self.uuid = uuid
        self.scopes = scopes
    }
}
