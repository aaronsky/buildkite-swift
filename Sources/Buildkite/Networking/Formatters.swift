//
//  Formatters.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/23/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum Formatters {
    static let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let iso8601WithoutFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    static func dateIfPossible(fromISO8601 string: String) -> Date? {
        if let date = iso8601WithFractionalSeconds.date(from: string) {
            return date
        } else if let date = iso8601WithoutFractionalSeconds.date(from: string) {
            return date
        }
        return nil
    }

    @Sendable
    static func encodeISO8601(date: Date, encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let dateString = iso8601WithoutFractionalSeconds.string(from: date)
        try container.encode(dateString)
    }

    @Sendable
    static func decodeISO8601(decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        guard let date = dateIfPossible(fromISO8601: dateString) else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Expected date string to be ISO8601-formatted."
                )
            )
        }
        return date
    }
}
