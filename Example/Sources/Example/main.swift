//
//  main.swift
//  
//
//  Created by Aaron Sky on 5/5/20.
//

import Foundation
import Combine
import Buildkite

let client = Buildkite()
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

var cancellables: Set<AnyCancellable> = []
client.sendPublisher(GraphQL<MyPipeline>(rawQuery: query, variables: ["first": 30]))
    .map(\.content)
    .sink(receiveCompletion: { result in
        if case let .failure(error) = result {
            print(error)
            exit(1)
        }
    }) { pipelines in
        print(pipelines)   
        exit(0)
}.store(in: &cancellables)

RunLoop.main.run()
