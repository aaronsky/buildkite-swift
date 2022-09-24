//
//  Example.swift
//  advanced-authorization
//
//  Created by Aaron Sky on 6/6/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Buildkite
import Foundation

@main struct Example {
    static func main() async throws {
        let client = BuildkiteClient(tokens: MyTokenProvider())

        let restUser = try await client.send(.me).content
        let gqlUser = try await client.sendQuery(GraphQL<Query>(rawQuery: "{ viewer { user { name } } }")).viewer.user
        if restUser.name == gqlUser.name {
            print("Hello, \(restUser.name)! 👋🏼")
        } else {
            print("Hello, \(restUser.name), and also to \(gqlUser.name)! 👋🏼")
        }
    }
}

struct MyTokenProvider: TokenProvider {
    func token(for version: APIVersion) async -> String? {
        switch version {
        case .GraphQL.v1:
            return "..."
        case .REST.v2:
            return "..."
        default:
            return nil
        }
    }
}

struct Query: Decodable, Equatable {
    var viewer: Viewer

    struct Viewer: Decodable, Equatable {
        var user: User

        struct User: Decodable, Equatable {
            var name: String
        }
    }
}
