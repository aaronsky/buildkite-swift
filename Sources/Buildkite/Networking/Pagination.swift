//
//  Pagination.swift
//  Buildkite
//
//  Created by Aaron Sky on 5/5/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Page {
    public var nextPage: Int?
    public var previousPage: Int?
    public var firstPage: Int?
    public var lastPage: Int?
    
    init?(for header: String) {
        guard !header.isEmpty else {
            return nil
        }
        
        for link in header.split(separator: ",") {
            let segments = link
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .split(separator: ";")
            guard
                segments.count <= 2,
                
                let urlString = segments.first,
                urlString.hasPrefix("<") && urlString.hasSuffix(">"),
                
                let url = URLComponents(string: String(urlString.dropFirst().dropLast())),
                
                let pageString = url.queryItems?.first(where: { $0.name == "page" })?.value,
                let page = Int(pageString) else {
                    continue
            }
            
            for segment in segments.dropFirst() {
                switch segment.trimmingCharacters(in: .whitespacesAndNewlines) {
                case "rel=\"next\"":
                    nextPage = page
                case "rel=\"prev\"":
                    previousPage = page
                case "rel=\"first\"":
                    firstPage = page
                case "rel=\"last\"":
                    lastPage = page
                default:
                    continue
                }
            }
        }
    }
}

public struct PageOptions {
    public var page: Int
    public var perPage: Int
    
    public init(page: Int, perPage: Int) {
        self.page = page
        self.perPage = perPage
    }
}

extension URLRequest {
    mutating func appendPageOptions(_ options: PageOptions) {
        guard let url = self.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
                return
        }
        var queryItems = components.queryItems ?? []
        queryItems.append(pageOptions: options)
        components.queryItems = queryItems
        self.url = components.url
    }
}

private extension Array where Element == URLQueryItem {
    mutating func append(pageOptions: PageOptions) {
        append(URLQueryItem(name: "page", value: String(pageOptions.page)))
        append(URLQueryItem(name: "per_page", value: String(pageOptions.perPage)))
    }
}

