//
//  Pagination.swift
//  
//
//  Created by Aaron Sky on 5/5/20.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public struct Page {
    var nextPage: Int?
    var previousPage: Int?
    var firstPage: Int?
    var lastPage: Int?
    
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

extension Array where Element == URLQueryItem {
    init(options: PageOptions) {
        self.init()
        append(URLQueryItem(name: "page", value: String(options.page)))
        append(URLQueryItem(name: "per_page", value: String(options.perPage)))
    }
}

