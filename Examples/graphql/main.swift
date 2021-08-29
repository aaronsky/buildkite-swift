//
//  main.swift
//  graphql
//
//  Created by Aaron Sky on 5/5/20.
//

import Foundation
import Combine
import Buildkite

let client = BuildkiteClient()
client.token = "..."

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

client.sendQuery(GraphQL<MyPipeline>(rawQuery: query, variables: ["first": 30])) { result in
    do {
        let pipelines = try result.get()
        print(pipelines)
        exit(0)
    } catch {
        print(error)
        exit(1)
    }
}

RunLoop.main.run()
