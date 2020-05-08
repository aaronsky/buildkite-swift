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

public struct Organization: Codable, Equatable, Identifiable {
    public var id: UUID
    public var url: URL // Resource<Organization.Resources.Get>
    public var webUrl: URL
    public var name: String
    public var slug: String
    public var pipelinesUrl: URL // Resource<Pipeline.Resources.List>
    public var agentsUrl: URL // Resource<Agent.Resources.List>
    public var emojisUrl: URL // Resource<Emoji.Resources.List>
    public var createdAt: URL
}
