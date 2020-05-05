//
//  Response.swift
//  
//
//  Created by Aaron Sky on 3/22/20.
//

import Foundation

enum ResponseError: Error {
    case missingResponse
    case unexpectedlyNoContent
}

public struct Response<T> {
    public let content: T
    public let response: URLResponse

    init(content: T, response: URLResponse) {
        self.content = content
        self.response = response
    }
}
