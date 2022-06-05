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

///
public protocol TokenProvider {
    /// Returns a token string for the given ``APIVersion``. This will usually be a fixed constant such as ``APIVersion/REST/v2`` or ``APIVersion/GraphQL/v1``, so you can switch on the values of one of these.
    func token(for version: APIVersion) -> String?
}

extension TokenProvider {
    func authorizationHeader(for version: APIVersion) -> String? {
        guard let token = token(for: version) else { return nil }

        switch version {
        case .GraphQL.v1, .REST.v2:
            return "Bearer \(token)"
        default:
            return nil
        }
    }
}

/// Wrapper for a raw representable token provider
struct RawTokenProvider: RawRepresentable, TokenProvider {
    let rawValue: String

    func token(for version: APIVersion) -> String? {
        rawValue
    }
}
