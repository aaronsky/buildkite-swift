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

extension BuildkiteClient: ContentDecoder {
    public nonisolated func decode<D>(_ decodable: D.Type, from body: ByteBuffer, headers: HTTPHeaders) throws -> D where D : Decodable {
        // FIXME: force cast
        try decodeWebhook(from: Data(buffer: body)) as! D
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

        if
            let signature = request.headers.buildkiteSignature,
            let payload = request.body.data {
            try self.validateWebhookPayload(
                signatureHeader: signature,
                body: Data(buffer: payload),
                secretKey: secretKey
            )
        } else if let token = request.headers.buildkiteToken {
            try self.validateWebhookPayload(tokenHeader: token, secretKey: secretKey)
        } else {
            throw Abort(.unauthorized)
        }

        return try await next.respond(to: request)
    }
}

extension BuildkiteClient: Middleware {
    public nonisolated func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Vapor.Response> {
        guard Environment.get("BUILDKITE_NO_VERIFY") == nil else {
            return next.respond(to: request)
        }

        guard
            let secretKey = Environment
                .get("BUILDKITE_WEBHOOK_SECRET")?
                .data(using: .utf8)
        else {
            return request.eventLoop.future(
                error: Abort(
                    .preconditionFailed,
                    reason: "Server not configured with webhook authentication token"
                )
            )
        }

        if
            let signature = request.headers.buildkiteSignature,
            let payload = request.body.data {
            return request.eventLoop.tryFuture {
                try self.validateWebhookPayload(
                    signatureHeader: signature,
                    body: Data(buffer: payload),
                    secretKey: secretKey
                )
            }.flatMap {
                next.respond(to: request)
            }
        } else if let token = request.headers.buildkiteToken {
            return request.eventLoop.tryFuture {
                try self.validateWebhookPayload(
                    tokenHeader: token,
                    secretKey: secretKey
                )
            }.flatMap {
                next.respond(to: request)
            }
        } else {
            return request.eventLoop.future(
                error: Abort(.unauthorized)
            )
        }
    }
}
