//
//  AccessTokens.swift
//  
//
//  Created by Aaron Sky on 4/21/20.
//

import Foundation

extension AccessToken {
    public enum Resources {}
}

extension AccessToken.Resources {
    /// Get the current token
    ///
    /// Returns details about the API Access Token that was used to authenticate the request.
    public struct Get: Resource, HasResponseBody {
        public typealias Content = AccessToken
        public let path = "access-token"
        
        public init() {}
    }

    /// Revoke the current token
    ///
    /// Once revoked, the token can no longer be used for further requests.
    public struct Revoke: Resource {
        public typealias Content = Void
        public let path = "access-token"

        public init() {}
        
        public func transformRequest(_ request: inout URLRequest) {
            request.httpMethod = "DELETE"
        }
    }
}
