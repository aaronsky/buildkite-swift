//
//  Configuration.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let libraryVersion = "0.0.1"

public struct Configuration {
    public let baseURL = URL(string: "https://api.buildkite.com")!
    public let userAgent = "buildkite-swift/\(libraryVersion)"
    public var version: APIVersion

    public static var `default`: Configuration {
        .init(version: .v2)
    }

    public init(version: APIVersion) {
        self.version = version
    }

    func url(for path: String) -> URL {
        baseURL
            .appendingPathComponent(version.id)
            .appendingPathComponent(path)
    }

    var token: String?

    func transformRequest(_ request: inout URLRequest) {
        request.addValue(userAgent, forHTTPHeaderField: "User-Agent")
        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

}
