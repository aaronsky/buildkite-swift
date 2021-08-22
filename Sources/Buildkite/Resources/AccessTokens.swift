//
//  AccessTokens.swift
//  Buildkite
//
//  Created by Aaron Sky on 4/21/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension AccessToken {
    public enum Resources {}
}

extension AccessToken.Resources {
    /// Get the current token
    ///
    /// Returns details about the API Access Token that was used to authenticate the request.
    public struct Get: Resource {
        public typealias Content = AccessToken
        public let path = "access-token"

        public init() {}
    }

    /// Revoke the current token
    ///
    /// Once revoked, the token can no longer be used for further requests.
    public struct Revoke: Resource {
        public let path = "access-token"

        public init() {}

        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "DELETE"
        }
    }
}

extension Resource where Self == AccessToken.Resources.Get {
    public static var getAccessToken: AccessToken.Resources.Get {
        .init()
    }
}

extension Resource where Self == AccessToken.Resources.Revoke {
    public static var revokeAccessToken: AccessToken.Resources.Revoke {
        .init()
    }
}
