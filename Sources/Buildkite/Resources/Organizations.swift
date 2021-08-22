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
    public enum Resources { }
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

        public init(organization: String) {
            self.organization = organization
        }
    }
}

extension Resource where Self == Organization.Resources.List {
    public static var organizations: Organization.Resources.List {
        .init()
    }
}

extension Resource where Self == Organization.Resources.Get {
    public static func organization(_ organization: String) -> Organization.Resources.Get {
        .init(organization: organization)
    }
}
