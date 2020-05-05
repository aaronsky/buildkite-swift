//
//  Resource.swift
//  
//
//  Created by Aaron Sky on 3/22/20.
//

import Foundation

public protocol HasRequestBody {
    associatedtype Body: Encodable
    var body: Body { get }
}

public protocol HasResponseBody {
    associatedtype Content: Decodable
}

public protocol Resource {
    var path: String { get }
    func transformRequest(_ request: inout URLRequest)
}

extension Resource {
    public func transformRequest(_ request: inout URLRequest) {

    }
}

extension URLRequest {
    init<R: Resource & HasRequestBody>(_ resource: R, configuration: Configuration, encoder: JSONEncoder) throws {
        self.init(resource, configuration: configuration)
        httpBody = try encoder.encode(resource.body)
    }

    init<R: Resource>(_ resource: R, configuration: Configuration) {
        let url = configuration.url(for: resource.path)
        var request = URLRequest(url: url)
        configuration.authorizeIfNeeded(&request)
        resource.transformRequest(&request)
        self = request
    }
}
