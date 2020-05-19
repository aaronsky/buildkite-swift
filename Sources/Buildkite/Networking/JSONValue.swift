//
//  Formatters.swift
//  Buildkite
//
//  Adapted from Kombucha, an open source project by Wayfair
//  https://github.com/wayfair/kombucha/blob/master/LICENSE.md
//
//  Copyright © 2020 Aaron Sky. All rights reserved.
//


import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum JSONValue {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    indirect case array([JSONValue])
    indirect case object([String: JSONValue])
}

extension JSONValue: Equatable, Hashable { }

extension JSONValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
            case .null:
                try container.encodeNil()
        case .bool(let boolValue):
            try container.encode(boolValue)
        case .number(let doubleValue):
            try container.encode(doubleValue)
            case .string(let stringValue):
                try container.encode(stringValue)
            case .array(let arrayValue):
                try container.encode(arrayValue)
        case .object(let objectValue):
            try container.encode(objectValue)
        }
    }
}

extension JSONValue: Decodable {
    public init(from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        
        if singleValueContainer.decodeNil() {
            self = .null
            return
        }
        if let boolValue = try? singleValueContainer.decode(Bool.self) {
            self = .bool(boolValue)
            return
        }
        if let doubleValue = try? singleValueContainer.decode(Double.self) {
            self = .number(doubleValue)
            return
        }
        if let stringValue = try? singleValueContainer.decode(String.self) {
            self = .string(stringValue)
            return
        }
        if let arrayValue = try? singleValueContainer.decode([JSONValue].self) {
            self = .array(arrayValue)
            return
        }
        if let objectValue = try? singleValueContainer.decode([String: JSONValue].self) {
            self = .object(objectValue)
            return
        }

        throw DecodingError.dataCorruptedError(
            in: singleValueContainer,
            debugDescription: "invalid JSON structure or the input was not JSON")
    }
}

extension JSONValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

extension JSONValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self = .bool(value)
    }
}

extension JSONValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .number(Double(value))
    }
}

extension JSONValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .number(value)
    }
}

extension JSONValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension JSONValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONValue...) {
        self = .array(elements)
    }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSONValue)...) {
        self = .object(Dictionary(uniqueKeysWithValues: elements))
    }
}
