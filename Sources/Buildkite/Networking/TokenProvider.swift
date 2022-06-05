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

public protocol TokenProvider {
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

extension String: TokenProvider {
    public func token(for version: APIVersion) -> String? {
        self
    }
}
