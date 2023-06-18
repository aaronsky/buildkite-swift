//
//  TokenProvider.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/5/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Interface for a type that can provide different tokens depending on which API is used.
///
/// It isn't necessary to implement this yourself unless you want to use the same ``BuildkiteClient``
/// for different APIs and want to continue restricting scopes or the tokens are inherently incompatible. For example,
/// you cannot use a Test Analytics API with any other API, including the REST or GraphQL APIs. GraphQL API
/// tokens also require scopes that more responsibly-configured REST API tokens do not, and may be undesirable to
/// leverage in all cases.
///
/// In addition, implementing this protocol allows you to fine-tune the storage mechanism for your tokens. For example,
/// if you need to read your token dynamically from the keychain, it may be more adventageous to do that as part of a
/// ``TokenProvider`` implementation rather than tightly-coupling keychain raw string access directly to your
/// client instantiation.
public protocol TokenProvider: Sendable {
    /// Returns a token string for the given ``APIVersion``. This will usually be a fixed constant such as ``APIVersion/REST/v2`` or ``APIVersion/GraphQL/v1``, so you can switch on the values of one of these.
    func token(for version: APIVersion) async -> String?
}

extension TokenProvider {
    func authorizationHeader(for version: APIVersion) async -> String? {
        guard let token = await token(for: version) else { return nil }

        switch version {
        case .GraphQL.v1, .REST.v2:
            return "Bearer \(token)"
        case .Agent.v3:
            return "Token \(token)"
        case .TestAnalytics.v1:
            return "Token token=\(token)"
        default:
            return nil
        }
    }
}

/// Wrapper for a raw representable token provider
struct RawTokenProvider: RawRepresentable, TokenProvider, Sendable {
    let rawValue: String

    func token(for version: APIVersion) async -> String? {
        rawValue
    }
}
