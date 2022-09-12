//
//  APIVersion.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// API base URL and version compatibility metadata used to connect to Buildkite.
public struct APIVersion: Equatable, Hashable, Sendable {
    public enum REST {
        private static let baseURL = URL(string: "https://api.buildkite.com")!
        public static let v2 = APIVersion(baseURL: baseURL, version: "v2")
    }

    public enum GraphQL {
        private static let baseURL = URL(string: "https://graphql.buildkite.com")!
        public static let v1 = APIVersion(baseURL: baseURL, version: "v1")
    }

    public enum Agent {
        private static let baseURL = URL(string: "https://agent.buildkite.com")!
        public static let v3 = APIVersion(baseURL: baseURL, version: "v3")
    }

    public enum TestAnalytics {
        private static let baseURL = URL(string: "https://analytics-api.buildkite.com")!
        public static let v1 = APIVersion(baseURL: baseURL, version: "v1")
    }

    public let baseURL: URL
    public let version: String

    func url(for path: String) -> URL {
        let url = baseURL.appendingPathComponent(version)
        if path.isEmpty {
            return url
        }
        return url.appendingPathComponent(path)
    }
}
