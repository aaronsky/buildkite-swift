//
//  Transport.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(Combine)
import Combine
#endif

public enum TransportError: Error {
    case noResponse
}

public protocol Transport {
    typealias Output = (data: Data, response: URLResponse)
    typealias Completion = (Result<Output, Error>) -> Void

    func send(request: URLRequest, completion: @escaping Completion)

    #if canImport(Combine)
    @available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
    func sendPublisher(request: URLRequest) -> AnyPublisher<Output, Error>
    #endif

    #if compiler(>=5.5.2) && canImport(_Concurrency)
    @available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
    func send(request: URLRequest) async throws -> Output
    #endif
}

extension URLSession: Transport {
    public func send(request: URLRequest, completion: @escaping Completion) {
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data, let response = response else {
                completion(.failure(TransportError.noResponse))
                return
            }
            completion(.success((data: data, response: response)))
        }
        task.resume()
    }

    #if canImport(Combine)
    @available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
    public func sendPublisher(request: URLRequest) -> AnyPublisher<Output, Error> {
        dataTaskPublisher(for: request)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    #endif

    #if compiler(>=5.5.2) && canImport(_Concurrency)
    @available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
    public func send(request: URLRequest) async throws -> Output {
        guard #available(iOS 15, macOS 12, tvOS 15, watchOS 8, *) else {
            return try await withCheckedThrowingContinuation { continuation in
                let task = dataTask(with: request) { data, response, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }

                    guard let data = data,
                        let response = response
                    else {
                        continuation.resume(throwing: TransportError.noResponse)
                        return
                    }

                    continuation.resume(returning: (data, response))
                }
                task.resume()
            }
        }
        return try await data(for: request)
    }
    #endif
}
