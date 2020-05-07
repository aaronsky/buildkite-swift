//
//  MockData.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct MockResources {
    struct HasContent: Resource, HasResponseBody {
        struct Content: Codable, Equatable {
            var name: String
            var age: Int
        }
        let path = "mock"
    }

    var contentResource = HasContent()
    var content = HasContent.Content(name: "Jeff", age: 35)

    struct NoContent: Resource {
        typealias Content = Void
        let path = "mock"
    }

    var noContentResource = NoContent()
}

enum MockData {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
}

extension MockData {
    static func mockingSuccess<Content: Codable>(with content: Content, url: URL) throws -> (Data, URLResponse) {
        let data = try encoder.encode(content)
        return (data, urlResponse(for: url, status: .ok))
    }

    static func mockingSuccessNoContent(url: URL) -> (Data, URLResponse) {
        return (Data(), urlResponse(for: url, status: .ok))
    }

    static func mockingIncompatibleResponse(for url: URL) -> (Data, URLResponse) {
        return (Data(), urlResponse(for: url, rawStatus: -128))
    }

    static func mockingUnsuccessfulResponse(for url: URL) -> (Data, URLResponse) {
        return (Data(), urlResponse(for: url, status: .notFound))
    }

    static func mockingSuccessNoContent(for request: URLRequest) throws -> (Data, URLResponse) {
        mockingSuccessNoContent(url: request.url!)
    }

    static func mockingError(for request: URLRequest) throws -> (Data, URLResponse) {
        throw URLError(.notConnectedToInternet)
    }

    private static func urlResponse(for url: URL, status: StatusCode) -> URLResponse {
        urlResponse(for: url, rawStatus: status.rawValue)
    }

    private static func urlResponse(for url: URL, rawStatus status: Int) -> URLResponse {
        HTTPURLResponse(url: url,
                        statusCode: status,
                        httpVersion: "HTTP/1.1",
                        headerFields: [:])!
    }
}

// MARK: Response Mocks

extension MockData {

}
