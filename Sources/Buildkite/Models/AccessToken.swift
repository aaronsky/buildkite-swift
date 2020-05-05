//
//  AccessToken.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/3/20.
//  Copyright © 2020 Fangamer. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct AccessToken: Codable, Equatable {
    public var uuid: UUID
    public var scopes: [String]
}
