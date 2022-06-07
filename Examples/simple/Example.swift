//
//  Example.swift
//  simple
//
//  Created by Aaron Sky on 6/6/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Buildkite
import Foundation

@main struct Example {
    static func main() async throws {
        let token = ProcessInfo.processInfo.environment["TOKEN"] ?? "..."
        let client = BuildkiteClient(token: token)

        let me = try await client.send(.me).content
        print("Hello, \(me.name)! 👋🏼")
    }
}
