//
//  Response.swift
//  
//
//  Created by Aaron Sky on 3/22/20.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum ResponseError: Error {
    case missingResponse
    case unexpectedlyNoContent
}

public struct Response<T> {
    public let content: T
    public let response: URLResponse
    public let page: Page?

    init(content: T, response: URLResponse) {
        self.content = content
        self.response = response
        if let response = response as? HTTPURLResponse, let link = response.allHeaderFields["Link"] as? String {
            page = Page(for: link)
        } else {
            page = nil
        }
    }
}
