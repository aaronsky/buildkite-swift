//
//  Response.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum ResponseError: Error {
    case incompatibleVersion
    case missingResponse
    case unexpectedlyNoContent
}

public struct BuildkiteError: Error {
    public var statusCode: StatusCode
    public var message: String
    public var errors: [String]

    init(statusCode: StatusCode, intermediary: Intermediary) {
        self.statusCode = statusCode
        self.message = intermediary.message ?? ""
        self.errors = intermediary.errors ?? []
    }

    struct Intermediary: Codable {
        var message: String?
        var errors: [String]?
    }
}

public struct Response<T> {
    public let content: T
    public let response: URLResponse
    public let page: Page?

    init(content: T, response: URLResponse) {
        self.content = content
        self.response = response
        if let response = response as? HTTPURLResponse, let link = response.allHeaderFields["Link"] as? String {
            page = Page(for: link)
        } else {
            page = nil
        }
    }
}
