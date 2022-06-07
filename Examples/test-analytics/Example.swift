//
//  Example.swift
//  test-analytics
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

        let result =
            try await client.send(
                .uploadTestAnalytics(
                    [
                        .init(id: UUID(), history: .init(section: "http")),
                        .init(id: UUID(), history: .init(section: "http")),
                        .init(id: UUID(), history: .init(section: "http")),
                    ],
                    environment: .init(ci: "buildkite", key: UUID().uuidString)
                )
            )
            .content

        print(result.runUrl)
    }
}
