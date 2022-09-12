//
//  StatusCode.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Status code from a completed ``Transport`` operation.
public enum StatusCode: Int, Error, Codable, Equatable, Hashable, Sendable {
    /// The request was successfully processed by Buildkite.
    case ok = 200

    /// The request has been fulfilled and a new resource has been created.
    case created = 201

    /// The request has been accepted, but not yet processed.
    case accepted = 202

    /// The request has been successfully processed, and is not returning any content
    case noContent = 204

    /// The request was found
    case found = 302

    /// The server cannot or will not process the request due to an apparent client error
    case badRequest = 400

    /// The necessary authentication credentials are not present in the request or are incorrect.
    case unauthorized = 401

    /// The server is refusing to respond to the request. This is generally because you have not requested the appropriate scope for this action.
    case forbidden = 403

    /// The requested resource was not found but could be available again in the future.
    case notFound = 404

    /// The request body was well-formed but contains semantic errors. The response body will provide more details in the errors or error parameters.
    case unprocessableEntity = 422

    /// The request was not accepted because the application has exceeded the rate limit
    case tooManyRequests = 429

    /// An internal error occurred in Buildkite.
    case internalServerError = 500

    /// The server was acting as a gateway or proxy and received an invalid response from the upstream server.
    case badGateway = 502

    /// The server is currently unavailable. Check the status page for reported service outages.
    case serviceUnavailable = 503

    /// The server was acting as a gateway or proxy and did not receive a timely response from the upstream server.
    case gatewayTimeout = 504

    /// Whether or not the status code constitutes a success.
    var isSuccess: Bool {
        self == .ok
            || self == .created
            || self == .accepted
            || self == .noContent
            || self == .found
    }
}
