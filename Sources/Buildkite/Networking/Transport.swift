//
//  Transport.swift
//  
//
//  Created by Aaron Sky on 3/22/20.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

#if canImport(Combine)
import Combine
#endif

public protocol Transport {
    typealias Output = (data: Data, response: URLResponse)

    func send(request: URLRequest, completion: @escaping (Result<Output, Error>) -> Void)

    #if canImport(Combine)
    @available(iOS 13.0, macOS 10.15, *)
    func sendPublisher(request: URLRequest) -> AnyPublisher<Output, Error>
    #endif
}

extension URLSession: Transport {
    public func send(request: URLRequest, completion: @escaping (Result<Output, Error>) -> Void) {
        let task = dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data, let response = response else {
                completion(.failure(ResponseError.missingResponse))
                return
            }

            completion(.success((data: data, response: response)))
        }
        task.resume()
    }

    #if canImport(Combine)
    @available(iOS 13.0, macOS 10.15, *)
    public func sendPublisher(request: URLRequest) -> AnyPublisher<Output, Error> {
        dataTaskPublisher(for: request)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    #endif
}
