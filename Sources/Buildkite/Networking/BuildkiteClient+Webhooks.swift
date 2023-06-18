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

/// Errors returned during webhook authentication validation.
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
    /// Decode a webhook event out of the given data.
    ///
    /// - Parameter body: Data, presumably from a request body, to decode into a ``WebhookEvent``.
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
        guard let prefix = "\(timestamp).".data(using: .utf8) else {
            throw WebhookValidationError.payloadCorrupted
        }
        let payload = prefix + body

        try checkMAC(
            message: payload,
            signature: signature,
            secretKey: secretKey
        )

        if let replayLimit = replayLimit {
            guard let timestamp = TimeInterval(timestamp) else {
                throw WebhookValidationError.timestampRefused
            }
            try checkReplayLimit(timestamp: timestamp, replayLimit: replayLimit)
        }
    }

    private nonisolated func getTimestampAndSignature(_ header: String) throws -> (timestamp: String, signature: Data) {
        let parts: [String: String] = Dictionary(
            uniqueKeysWithValues:
                header
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

        guard let timestamp = parts["timestamp"] else {
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
        guard
            HMAC<SHA256>
                .isValidAuthenticationCode(
                    signature,
                    authenticating: message,
                    using: key
                )
        else {
            throw WebhookValidationError.signatureRefused
        }
    }

    private nonisolated func checkReplayLimit(
        timestamp: TimeInterval,
        replayLimit: TimeInterval
    ) throws {
        let time = Date(timeIntervalSince1970: timestamp)
        // All times must be in the past, and must be smaller than replayLimit
        guard time.timeIntervalSinceNow < 0 && abs(time.timeIntervalSinceNow) <= replayLimit else {
            throw WebhookValidationError.timestampRefused
        }
    }
}

// MARK: - Hex string decoding
// Adapted from swift-crypto
// https://github.com/apple/swift-crypto/blob/main/Sources/Crypto/Util/PrettyBytes.swift

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

extension Data {
    fileprivate init(
        hexString: String
    ) throws {
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
