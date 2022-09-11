//
//  Example.swift
//  webhooks
//
//  Created by Aaron Sky on 6/6/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Buildkite
import Vapor

@available(macOS 12.0, *)
@main struct Example {
    static func main() throws {
        let app = try Application(.detect())
        defer { app.shutdown() }

        let buildkite = BuildkiteClient(/*transport: app.client*/)

        app.group(buildkite) {
            $0.post("buildkite_webhook") { req in
                guard let body = req.body.data else {
                    throw Abort(.noContent)
                }

                let event = try buildkite.decodeWebhook(from: Data(buffer: body))
                print(event)

                return HTTPStatus.ok
            }
        }

        app.get("buildkite_webhook") { req in
            "Hello world"
        }

        try app.run()
    }
}
