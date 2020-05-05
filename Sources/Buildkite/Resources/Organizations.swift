//
//  Organizations.swift
//  
//
//  Created by Aaron Sky on 4/21/20.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Organization {
    public enum Resources { }
}

extension Organization.Resources {
    /// List organizations
    ///
    /// Returns a paginated list of the user’s organizations.
    public struct List: Resource, HasResponseBody {
        public typealias Content = [Organization]
        public let path = "organizations"
        
        public init() {}
    }

    /// Get an organization
    public struct Get: Resource, HasResponseBody {
        public typealias Content = Organization
        /// organization slug
        public var organization: String

        public var path: String {
            "organizations/\(organization)"
        }
        
        public init(organization: String) {
            self.organization = organization
        }
    }

}
