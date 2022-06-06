//
//  Resource.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum ResourceError: Error {
    case incompatibleVersion(APIVersion)
}

public protocol Resource {
    associatedtype Body = Void
    associatedtype Content = Void

    var version: APIVersion { get }
    var path: String { get }
    var body: Body { get }
    func transformRequest(_ request: inout URLRequest)
}

extension Resource {
    public var version: APIVersion {
        APIVersion.REST.v2
    }

    public func transformRequest(_ request: inout URLRequest) {}
}

extension Resource where Body == Void {
    public var body: Body {
        ()
    }
}

public protocol PaginatedResource: Resource where Content: Decodable {}

extension URLRequest {
    init<R: Resource>(
        _ resource: R,
        configuration: Configuration,
        tokens: TokenProvider?
    ) throws {
        let version = resource.version
        guard
            version == configuration.version
                || version == configuration.graphQLVersion
        else {
            throw ResourceError.incompatibleVersion(version)
        }

        let url = version.url(for: resource.path)
        var request = URLRequest(url: url)
        configuration.transformRequest(&request, tokens: tokens, version: version)
        resource.transformRequest(&request)

        self = request
    }

    init<R: Resource>(
        _ resource: R,
        configuration: Configuration,
        tokens: TokenProvider?,
        encoder: JSONEncoder
    ) throws where R.Body: Encodable {
        try self.init(resource, configuration: configuration, tokens: tokens)
        httpBody = try encoder.encode(resource.body)
    }

    init<R: Resource & PaginatedResource>(
        _ resource: R,
        configuration: Configuration,
        tokens: TokenProvider?,
        pageOptions: PageOptions? = nil
    ) throws {
        try self.init(resource, configuration: configuration, tokens: tokens)
        if let options = pageOptions {
            appendPageOptions(options)
        }
    }

    init<R: Resource & PaginatedResource>(
        _ resource: R,
        configuration: Configuration,
        tokens: TokenProvider?,
        encoder: JSONEncoder,
        pageOptions: PageOptions? = nil
    ) throws where R.Body: Encodable {
        try self.init(resource, configuration: configuration, tokens: tokens, encoder: encoder)
        if let options = pageOptions {
            appendPageOptions(options)
        }
    }
}
