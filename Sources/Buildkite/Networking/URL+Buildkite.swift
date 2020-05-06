//
//  URL+Buildkite.swift
//  
//
//  Created by Aaron Sky on 5/5/20.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

extension Array where Element == URLQueryItem {
    mutating func appendIfNeeded<S: LosslessStringConvertible>(_ value: S?, forKey key: String) {
        guard let value = value else {
            return
        }
        append(URLQueryItem(name: key, value: String(value)))
    }
    
    enum ArrayFormat {
        case indices
        case brackets
        
        func format(for index: Int) -> String {
            switch self {
            case .indices:
                return "[\(index)]"
            case .brackets:
                return "[]"
            }
        }
    }
    
    mutating func append(_ items: [String], forKey key: String, arrayFormat: ArrayFormat = .brackets) {
        if items.isEmpty {
            return
        } else if items.count == 1 {
            appendIfNeeded(items.first, forKey: key)
        } else {
            append(contentsOf: items
                .enumerated()
                .map {
                    URLQueryItem(name: "\(key)\(arrayFormat.format(for: $0.offset))",
                        value: $0.element)
            })
        }
    }
    
    mutating func append(_ items: [String: String], forKey key: String) {
        append(contentsOf: items.map {
            URLQueryItem(name: "\(key)[\($0.key)]",
                value: $0.value)
        })
    }
}

extension Date: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let date = Formatters.dateIfPossible(fromISO8601: description) else {
            return nil
        }
        self = date
    }
}

extension UUID: LosslessStringConvertible {
    public init?(_ description: String) {
        guard let id = UUID(uuidString: description) else {
            return nil
        }
        self = id
    }
}
