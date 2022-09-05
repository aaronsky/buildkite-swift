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

final class MockTransport {
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
        guard !responses.isEmpty else {
            throw MockTransport.Error.tooManyRequests
        }
        return responses.removeFirst()
    }
}
