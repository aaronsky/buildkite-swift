//
//  Constants.swift
//  
//
//  Created by Aaron Sky on 3/23/20.
//

import Foundation

enum Formatters {
    static let iso8601WithFractionalSeconds: ISO8601DateFormatter = {
        let formatter: ISO8601DateFormatter
        if #available(iOS 11.0, macOS 10.13, *) {
            formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        } else {
            formatter = Formatters.iso8601WithoutFractionalSeconds
        }
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
    
    static func encodeISO8601(date: Date, encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let dateString = iso8601WithoutFractionalSeconds.string(from: date)
        try container.encode(dateString)
    }
    
    static func decodeISO8601(decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        guard let date = dateIfPossible(fromISO8601: dateString) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: container.codingPath, debugDescription: "Expected date string to be ISO8601-formatted."))
        }
        return date
    }
}

class OptionalFractionalSecondsDateFormatter: DateFormatter {
    static let withoutSeconds: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXX"
        return formatter
    }()

    func setup() {
        calendar = Calendar(identifier: .iso8601)
        locale = Locale(identifier: "en_US_POSIX")
        timeZone = TimeZone(identifier: "UTC")
        dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXX" // handle up to 6 decimal places, although iOS currently only preserves 2 digits of precision
    }

    override init() {
        super.init()
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func date(from string: String) -> Date? {
        if let result = super.date(from: string) {
            return result
        }
        return OptionalFractionalSecondsDateFormatter.withoutSeconds.date(from: string)
    }
}
