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

public protocol Resource {
    associatedtype Content
    var path: String { get }
    func transformRequest(_ request: inout URLRequest)
}

extension Resource {
    public func transformRequest(_ request: inout URLRequest) {}
}

public protocol HasRequestBody {
    associatedtype Body: Encodable
    var body: Body { get }
}

public protocol HasResponseBody {
    associatedtype Content: Decodable
}

public protocol Paginated: HasResponseBody {}

extension URLRequest {
    init<R: Resource>(_ resource: R, configuration: Configuration) {
        let url = configuration.url(for: resource.path)
        var request = URLRequest(url: url)
        configuration.transformRequest(&request)
        resource.transformRequest(&request)
        self = request
    }

    init<R: Resource & HasRequestBody>(_ resource: R, configuration: Configuration, encoder: JSONEncoder) throws {
        self.init(resource, configuration: configuration)
        httpBody = try encoder.encode(resource.body)
    }

    init<R: Resource & Paginated>(_ resource: R, configuration: Configuration, pageOptions: PageOptions? = nil) {
        self.init(resource, configuration: configuration)
        if let options = pageOptions {
            appendPageOptions(options)
        }
    }

    init<R: Resource & HasRequestBody & Paginated>(_ resource: R, configuration: Configuration, encoder: JSONEncoder, pageOptions: PageOptions? = nil) throws {
        try self.init(resource, configuration: configuration, encoder: encoder)
        if let options = pageOptions {
            appendPageOptions(options)
        }
    }
}
