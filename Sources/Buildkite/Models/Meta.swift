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

public struct Meta: Codable, Equatable {
    /// A list of IP addresses in CIDR notation that Buildkite uses to
    /// send outbound traffic such as webhooks and commit statuses.
    /// These are subject to change from time to time.
    ///
    /// Buildkite recommends checking for new addresses daily, and
    /// will try to advertise new addresses for at least 7 days
    /// before they are used.
    public var webhookIPRanges: [String]

    private enum CodingKeys: String, CodingKey {
        // This corresponds to the key "webhook_ips" from the Buildkite payload.
        case webhookIPRanges = "webhookIps"
    }
}
