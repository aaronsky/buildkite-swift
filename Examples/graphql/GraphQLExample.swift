//
//  main.swift
//  graphql
//
//  Created by Aaron Sky on 5/5/20.
//

#if compiler(>=5.5.2) && canImport(_Concurrency)

import Foundation
import Combine
import Buildkite

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

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
@main struct GraphQLExample {
    static func main() async {
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

        do {
            let pipelines = try await client.sendQuery(GraphQL<MyPipeline>(
                rawQuery: query,
                variables: ["first": 30]
            ))
            print(pipelines)
        } catch {
            print(error)
            exit(1)
        }
    }
}

#endif
