//
//  BuildkiteClient+Middleware.swift
//  webhooks
//
//  Created by Aaron Sky on 9/5/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Buildkite
import Foundation
import Vapor

extension HTTPHeaders {
    fileprivate var buildkiteEvent: String? {
        self.first(name: WebhookEvent.HTTPHeaders.buildkiteEvent)
    }

    fileprivate var buildkiteToken: String? {
        self.first(name: WebhookEvent.HTTPHeaders.buildkiteToken)
    }

    fileprivate var buildkiteSignature: String? {
        self.first(name: WebhookEvent.HTTPHeaders.buildkiteSignature)
    }
}

@available(macOS 12.0, *)
extension BuildkiteClient: AsyncMiddleware {
    public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Vapor.Response {
        guard Environment.get("BUILDKITE_NO_VERIFY") == nil else {
            return try await next.respond(to: request)
        }

        guard
            let secretKey = Environment
                .get("BUILDKITE_WEBHOOK_SECRET")?
                .data(using: .utf8)
        else {
            throw Abort(
                .preconditionFailed,
                reason: "Server not configured with webhook authentication token"
            )
        }

        let replayLimit = Environment
            .get("BUILDKITE_WEBHOOK_REPLAY_LIMIT")
            .flatMap(TimeInterval.init)

        if
            let signature = request.headers.buildkiteSignature,
            let payload = request.body.data {
            try validateWebhookPayload(
                signatureHeader: signature,
                body: Data(buffer: payload),
                secretKey: secretKey,
                replayLimit: replayLimit
            )
        } else if let token = request.headers.buildkiteToken {
            try validateWebhookPayload(
                tokenHeader: token,
                secretKey: secretKey
            )
        } else {
            throw Abort(.unauthorized)
        }

        return try await next.respond(to: request)
    }
}
