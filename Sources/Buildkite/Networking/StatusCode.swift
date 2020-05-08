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

public enum StatusCode: Int, Error, Codable {
    /// The request was successfully processed by Buildkite.
    case ok = 200

    /// The request has been fulfilled and a new resource has been created.
    case created = 201

    /// The request has been accepted, but not yet processed.
    case accepted = 202

    /// The request was found
    case found = 302

    /// The response to the request can be found under a different URL in the Location header and can be retrieved using a GET method on that resource.
    case seeOther = 303

    /// The request was not understood by the server, generally due to bad syntax or because the Content-Type header was not correctly set to application/json.
    ///
    /// This status is also returned when the request provides an invalid code parameter during the OAuth token exchange process.
    case badRequest = 400

    /// The necessary authentication credentials are not present in the request or are incorrect.
    case unauthorized = 401

    /// The requested shop is currently frozen. The shop owner needs to log in to the shop's admin and pay the outstanding balance to unfreeze the shop.
    case paymentRequired = 402

    /// The server is refusing to respond to the request. This is generally because you have not requested the appropriate scope for this action.
    case forbidden = 403

    /// The requested resource was not found but could be available again in the future.
    case notFound = 404

    /// The requested resource is only capable of generating content not acceptable according to the Accept headers sent in the request.
    case notAcceptable = 406

    /// The request body was well-formed but contains semantic errors. The response body will provide more details in the errors or error parameters.
    case unprocessableEntity = 422

    /// The requested shop is currently locked. Shops are locked if they repeatedly exceed their API request limit, or if there is an issue with the account, such as a detected compromise or fraud risk.
    case locked = 423

    /// The request was not accepted because the application has exceeded the rate limit. See the API Call Limit documentation for a breakdown of Buildkite's rate-limiting mechanism.
    case tooManyRequests = 429

    /// An internal error occurred in Buildkite. Please post to the API & Technology forum so that Buildkite staff can investigate.
    case internalServerError = 500

    /// The requested endpoint is not available on that particular shop, e.g. requesting access to a Plus-specific API on a non-Plus shop. This response may also indicate that this endpoint is reserved for future use.
    case notImplemented = 501

    /// The server is currently unavailable. Check the status page for reported service outages.
    case serviceUnavailable = 503

    /// The request could not complete in time. Try breaking it down in multiple smaller requests.
    case gatewayTimeout = 504

    var isSuccess: Bool {
        self == .ok
            || self == .created
            || self == .accepted
            || self == .found
    }
}
