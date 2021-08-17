//
//  MockTransport.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class MockTransport {
    enum Error: Swift.Error {
        case tooManyRequests
    }

    var history: [URLRequest] = []
    var responses: [Transport.Output]

    init(responses: [Transport.Output]) {
        self.responses = responses
    }
}

extension MockTransport: Transport {
    func send(request: URLRequest, completion: @escaping (Result<Output, Swift.Error>) -> Void) {
        history.append(request)
        guard !responses.isEmpty else {
            completion(.failure(MockTransport.Error.tooManyRequests))
            return
        }
        completion(.success(responses.removeFirst()))
    }
}


#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension MockTransport: CombineTransport{
    func sendPublisher(request: URLRequest) -> AnyPublisher<Output, Swift.Error> {
        history.append(request)
        return Future { [weak self] promise in
            guard let self = self else {
                return
            }
            guard !self.responses.isEmpty else {
                promise(.failure(MockTransport.Error.tooManyRequests))
                return
            }
            promise(.success(self.responses.removeFirst()))
        }.eraseToAnyPublisher()
    }
}
#endif

#if swift(>=5.5)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension MockTransport: AsyncTransport {
    func send(request: URLRequest) async throws -> Output {
        history.append(request)
        guard !responses.isEmpty else {
            throw MockTransport.Error.tooManyRequests
        }
        return responses.removeFirst()
    }
}
#endif
