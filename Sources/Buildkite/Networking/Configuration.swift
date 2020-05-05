//
//  Configuration.swift
//  
//
//  Created by Aaron Sky on 3/22/20.
//

import Foundation

public struct Configuration {
    public let baseURL = URL(string: "https://api.buildkite.com")!
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

    func authorizeIfNeeded(_ request: inout URLRequest) {
        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

}
