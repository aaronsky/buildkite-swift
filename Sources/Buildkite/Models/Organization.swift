//
//  Organization.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Organization: Codable, Equatable, Hashable, Identifiable, Sendable {
    public var id: UUID
    public var url: Followable<Organization.Resources.Get>
    public var webUrl: URL
    public var name: String
    public var slug: String
    public var pipelinesUrl: Followable<Pipeline.Resources.List>
    public var agentsUrl: Followable<Agent.Resources.List>
    public var emojisUrl: Followable<Emoji.Resources.List>
    public var createdAt: Date
}
