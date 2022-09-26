//
//  Meta.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/29/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Meta information about Buildkite as a platform.
public struct Meta: Codable, Equatable, Hashable, Sendable {
    /// A list of IP addresses in CIDR notation that Buildkite uses to
    /// send outbound traffic such as webhooks and commit statuses.
    /// These are subject to change from time to time.
    ///
    /// Buildkite recommends checking for new addresses daily, and
    /// will try to advertise new addresses for at least 7 days
    /// before they are used.
    public var webhookIPRanges: [String]

    public init(webhookIPRanges: [String]) {
        self.webhookIPRanges = webhookIPRanges
    }

    private enum CodingKeys: String, CodingKey {
        case webhookIPRanges = "webhook_ips"
    }
}
