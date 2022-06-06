//
//  Organizations.swift
//  Buildkite
//
//  Created by Aaron Sky on 4/21/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Organization {
    /// Resources for performing operations on Buildkite organizations.
    public enum Resources {}
}

extension Organization.Resources {
    /// List organizations
    ///
    /// Returns a paginated list of the user’s organizations.
    public struct List: PaginatedResource {
        public typealias Content = [Organization]
        public let path = "organizations"

        public init() {}
    }

    /// Get an organization
    public struct Get: Resource {
        public typealias Content = Organization
        /// organization slug
        public var organization: String

        public var path: String {
            "organizations/\(organization)"
        }

        public init(
            organization: String
        ) {
            self.organization = organization
        }
    }
}

extension Resource where Self == Organization.Resources.List {
    /// List organizations
    ///
    /// Returns a paginated list of the user’s organizations.
    public static var organizations: Self {
        Self()
    }
}

extension Resource where Self == Organization.Resources.Get {
    /// Get an organization
    public static func organization(_ organization: String) -> Self {
        Self(organization: organization)
    }
}
