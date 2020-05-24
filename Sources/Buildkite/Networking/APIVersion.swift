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

public struct APIVersion: Equatable {
    public enum REST {
        private static let baseURL = URL(string: "https://api.buildkite.com")!
        public static let v2 = APIVersion(baseURL: baseURL, version: "v2")
    }

    public enum GraphQL {
        private static let baseURL = URL(string: "https://graphql.buildkite.com")!
        public static let v1 = APIVersion(baseURL: baseURL, version: "v1")
    }

    public let baseURL: URL
    public let version: String

    init(baseURL: URL, version: String) {
        self.baseURL = baseURL
        self.version = version
    }

    func url(for path: String) -> URL {
        let url = baseURL.appendingPathComponent(version)
        guard !path.isEmpty else {
            return url
        }
        return url.appendingPathComponent(path)
    }
}
