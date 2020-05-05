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
var cancellables: Set<AnyCancellable> = []
client.sendPublisher(Build.Resources.ListAll())
    .map(\.content)
    .sink(receiveCompletion: { result in
        if case let .failure(error) = result {
            print(error)
            exit(1)
        }
    }) { agents in
        print(agents)
        exit(0)
}.store(in: &cancellables)

RunLoop.main.run()
