//
//  MockTransport.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Buildkite
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

actor MockTransport {
    enum Error: Swift.Error {
        case tooManyRequests
    }

    var history: [URLRequest] = []
    var responses: [Transport.Output]

    init(
        responses: [Transport.Output]
    ) {
        self.responses = responses
    }
}

extension MockTransport: Transport {
    func send(request: URLRequest) async throws -> Output {
        history.append(request)

        if responses.isEmpty {
            throw MockTransport.Error.tooManyRequests
        }

        return responses.removeFirst()
    }
}
