//
//  APIVersion.swift
//  
//
//  Created by Aaron Sky on 3/22/20.
//

import Foundation

public struct APIVersion {
    public static let v2: APIVersion = "v2"

    let id: String

    init(_ version: String) {
        id = version
    }
}

extension APIVersion: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}
