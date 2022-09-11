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

extension BuildkiteClient {
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
                .compactMap { kv in
                    let kvp = kv.split(separator: "=", maxSplits: 2)
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                    guard kvp.count == 2 else { return nil }
                    return (kvp[0], kvp[1])
                }
        )
        guard parts.count == 2 else {
            throw WebhookValidationError.signatureFormatInvalid
        }

        guard let timestamp = parts["timestamp"]
                .flatMap(TimeInterval.init)
                .flatMap(Date.init(timeIntervalSince1970:)) else {
            throw WebhookValidationError.signatureCorrupted
        }

        let signature: Data?
        do {
            signature = try parts["signature"]
                .flatMap(Data.init(hexString:))
        } catch is ByteHexEncodingError {
            throw WebhookValidationError.signatureCorrupted
        }
        guard let signature = signature else {
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

// MARK: - Hex string decoding
// Adapted from swift-crypto

private enum ByteHexEncodingError: Error {
    case incorrectHexValue
    case incorrectString
}

private let char_a = UInt8(UnicodeScalar("a").value)
private let char_A = UInt8(UnicodeScalar("A").value)
private let char_f = UInt8(UnicodeScalar("f").value)
private let char_F = UInt8(UnicodeScalar("F").value)
private let char_0 = UInt8(UnicodeScalar("0").value)
private let char_9 = UInt8(UnicodeScalar("9").value)

private func htoi(_ value: UInt8) throws -> UInt8 {
    switch value {
    case char_0...char_9:
        return value - char_0
    case char_a...char_f:
        return value - char_a + 10
    case char_A...char_F:
        return value - char_A + 10
    default:
        throw ByteHexEncodingError.incorrectHexValue
    }
}

private extension Data {
    init(hexString: String) throws {
        self.init()

        if hexString.isEmpty {
            return
        }

        guard hexString.count.isMultiple(of: 2) else {
            throw ByteHexEncodingError.incorrectString
        }
        guard let stringData = hexString.data(using: .utf8) else {
            throw ByteHexEncodingError.incorrectString
        }
        let stringBytes = Array(stringData)

        for i in 0...((hexString.count / 2) - 1) {
            let char1 = stringBytes[2 * i]
            let char2 = stringBytes[2 * i + 1]

            try self.append(htoi(char1) << 4 + htoi(char2))
        }
    }
}
