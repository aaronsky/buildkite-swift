//
//  Example.swift
//  graphql
//
//  Created by Aaron Sky on 5/5/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Buildkite
import Foundation

@main struct Example {
    static func main() async throws {
        let client = BuildkiteClient(token: "...")

        let query = """
            query MyPipelines($first: Int!) {
                organization(slug: "buildkite") {
                    pipelines(first: $first) {
                        edges {
                            node {
                                name
                                uuid
                            }
                        }
                    }
                }
            }
            """

        let pipelines = try await client.sendQuery(
            GraphQL<MyPipeline>(
                rawQuery: query,
                variables: ["first": 30]
            )
        )
        print(pipelines)
    }
}

struct MyPipeline: Codable {
    var organization: Organization?

    struct Organization: Codable {
        var pipelines: Pipelines

        struct Pipelines: Codable {
            var edges: [PipelineEdge]

            struct PipelineEdge: Codable {
                var node: Pipeline

                struct Pipeline: Codable {
                    var name: String
                    var uuid: UUID
                }
            }
        }
    }
}
