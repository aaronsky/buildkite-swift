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
    struct NoContentNoBody: Resource {
        typealias Content = Void
        let path = "mock"
    }

    var noContentNoBodyResource = NoContentNoBody()

    struct HasContent: Resource, HasResponseBody {
        struct Content: Codable, Equatable {
            var name: String
            var age: Int
        }
        let path = "mock"
    }

    var contentResource = HasContent()
    var content = HasContent.Content(name: "Jeff", age: 35)

    struct HasPaginatedContent: Resource, Paginated {
        struct Content: Codable, Equatable {
            var name: String
            var age: Int
        }

        let path = "mock"
    }

    var paginatedContentResource = HasPaginatedContent()
    var paginatedContent = HasPaginatedContent.Content(name: "Jeff", age: 35)

    struct HasBody: Resource, HasRequestBody {
        typealias Content = Void

        struct Body: Codable, Equatable {
            var name: String
            var age: Int
        }

        var body: Body

        let path = "mock"
    }

    var bodyResource = HasBody(body: HasBody.Body(name: "Jeff", age: 35))

    struct HasBodyAndPaginated: Resource, HasRequestBody, Paginated {
        struct Body: Codable, Equatable {
            var name: String
            var age: Int
        }

        struct Content: Codable, Equatable {
            var name: String
            var age: Int
        }

        var body: Body

        let path = "mock"
    }

    var bodyAndPaginatedResource = HasBodyAndPaginated(body: HasBodyAndPaginated.Body(name: "Jeff", age: 35))
    var bodyAndPaginatedContent = HasBodyAndPaginated.Content(name: "Jeff", age: 35)
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
        return (#"{"message":"not found","errors": ["go away"]}"#.data(using: .utf8)!, urlResponse(for: url, status: .notFound))
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
                        headerFields: ["Link": #"<https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds?api_key=f8582f070276d764ce3dd4c6d57be92574dccf86&page=3>; rel="prev",<https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds?api_key=f8582f070276d764ce3dd4c6d57be92574dccf86&page=5>; rel="next",<https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds?api_key=f8582f070276d764ce3dd4c6d57be92574dccf86&page=1>; rel="first", <https://api.buildkite.com/v2/organizations/my-great-org/pipelines/my-pipeline/builds?api_key=f8582f070276d764ce3dd4c6d57be92574dccf86&page=10>; rel="last""#])!
    }
}
