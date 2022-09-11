//
//  BuildkiteClient+Webhooks.swift
//  Buildkite
//
//  Created by Aaron Sky on 9/10/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Crypto
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension WebhookEvent {
    /// Header names present in every Buildkite webhook request.
    ///
    /// - SeeAlso: https://buildkite.com/docs/apis/webhooks#http-headers
    public enum HTTPHeaders {
        /// The type of event
        public static let buildkiteEvent = "X-Buildkite-Event"
        /// The webhook's token.
        public static let buildkiteToken = "X-Buildkite-Token"
        /// The signature created from your webhook payload, webhook token, and the SHA-256 hash function.
        public static let buildkiteSignature = "X-Buildkite-Signature"
    }
}

extension BuildkiteClient {
    public enum WebhookValidationError: Error {
        // Token
        case tokenRefused
        // Signature
        case signatureFormatInvalid
        case signatureCorrupted
        case payloadCorrupted
        case signatureRefused
        // Replay Protection
        case timestampRefused
    }

    public nonisolated func decodeWebhook(from body: Data) throws -> WebhookEvent {
        try decoder.decode(WebhookEvent.self, from: body)
    }

    /// Validate a webhook payload using the token strategy.
    ///
    /// - Warning: Buildkite passes the token in clear text. As a consequence, this strategy is less secure than the Buildkite Signature strategy, but easier for rapid testing and less computationally expensive.
    ///
    /// - Parameters:
    ///   - tokenHeader: Value for the header with the name at ``WebhookEvent/HTTPHeaders/buildkiteToken``
    ///   - secretKey: Token value provided by Buildkite
    public nonisolated func validateWebhookPayload(
        tokenHeader: String,
        secretKey: Data
    ) throws {
        guard secretKey == tokenHeader.data(using: .utf8) else {
            throw WebhookValidationError.tokenRefused
        }
    }

    /// Validate the webhook event using the signature strategy.
    ///
    /// - Parameters:
    ///   - signatureHeader: Value for the header with the name at ``WebhookEvent/HTTPHeaders/buildkiteSignature``
    ///   - body: The request body from Buildkite
    ///   - secretKey: Token value provided by Buildkite
    ///   - replayLimit: Limit in seconds the period of time a webhook event will be accepted. This is used to defend against replay attacks, but is optional.
    public nonisolated func validateWebhookPayload(
        signatureHeader: String,
        body: Data,
        secretKey: Data,
        replayLimit: TimeInterval? = nil
    ) throws {
        let (timestamp, signature) = try getTimestampAndSignature(signatureHeader)
        guard let macPayload = "\(timestamp).\(body)".data(using: .utf8) else {
            throw WebhookValidationError.payloadCorrupted
        }

        try checkMAC(
            message: macPayload,
            signature: signature,
            secretKey: secretKey
        )

        if let replayLimit = replayLimit {
            try checkReplayLimit(time: timestamp, replayLimit: replayLimit)
        }
    }

    private nonisolated func getTimestampAndSignature(_ header: String) throws -> (timestamp: Date, signature: Data) {
        let parts: [String: String] = Dictionary(
            uniqueKeysWithValues: header
                .split(separator: ",")
                .map { kv in
                    let kvp = kv.split(separator: "=", maxSplits: 2)
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                    return (kvp[0], kvp[1])
                }
        )
        guard parts.count == 2 else {
            throw WebhookValidationError.signatureFormatInvalid
        }

        guard
            let timestamp = parts["timestamp"]
                .flatMap(TimeInterval.init)
                .flatMap(Date.init(timeIntervalSince1970:)),
            // FIXME: Needs to be a hex-decoded
            let signature = parts["signature"]?
                .data(using: .utf8)
        else {
            throw WebhookValidationError.signatureCorrupted
        }

        return (timestamp, signature)
    }

    private nonisolated func checkMAC(message: Data, signature: Data, secretKey: Data) throws {
        let key = SymmetricKey(data: secretKey)
        let expectedMAC = HMAC<SHA256>.authenticationCode(
            for: message,
            using: key
        )
        guard
            HMAC.isValidAuthenticationCode(
                expectedMAC,
                authenticating: signature,
                using: key
            )
        else {
            throw WebhookValidationError.signatureRefused
        }
    }

    private nonisolated func checkReplayLimit(
        time: Date,
        replayLimit: TimeInterval
    ) throws {
        guard time.timeIntervalSinceNow <= replayLimit else {
            throw WebhookValidationError.timestampRefused
        }
    }
}
