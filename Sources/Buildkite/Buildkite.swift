//
//  Buildkite.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class Buildkite {
    let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom(Formatters.encodeISO8601)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(Formatters.decodeISO8601)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    var configuration: Configuration
    var transport: Transport
    
    public var token: String? {
        get {
            configuration.token
        }
        set {
            configuration.token = newValue
        }
    }
    
    public init(configuration: Configuration = .default, transport: Transport = URLSession.shared) {
        self.configuration = configuration
        self.transport = transport
    }
    
    public func send<R: Resource & HasResponseBody>(_ resource: R, completion: @escaping (Result<Response<R.Content>, Error>) -> Void) {
        let request = URLRequest(resource, configuration: configuration)
        transport.send(request: request, completion: handleContentfulResponse(completion: completion))
    }
    
    public func send<R: Resource & HasResponseBody & Paginated>(_ resource: R, pageOptions: PageOptions? = nil, completion: @escaping (Result<Response<R.Content>, Error>) -> Void) {
        let request = URLRequest(resource, configuration: configuration, pageOptions: pageOptions)
        transport.send(request: request, completion: handleContentfulResponse(completion: completion))
    }
    
    public func send<R: Resource & HasRequestBody & HasResponseBody>(_ resource: R, completion: @escaping (Result<Response<R.Content>, Error>) -> Void) {
        let request: URLRequest
        do {
            request = try URLRequest(resource, configuration: configuration, encoder: encoder)
        } catch {
            completion(.failure(error))
            return
        }
        transport.send(request: request, completion: handleContentfulResponse(completion: completion))
    }
    
    public func send<R: Resource & HasRequestBody & HasResponseBody & Paginated>(_ resource: R, pageOptions: PageOptions? = nil, completion: @escaping (Result<Response<R.Content>, Error>) -> Void) {
        let request: URLRequest
        do {
            request = try URLRequest(resource, configuration: configuration, encoder: encoder, pageOptions: pageOptions)
        } catch {
            completion(.failure(error))
            return
        }
        transport.send(request: request, completion: handleContentfulResponse(completion: completion))
    }
    
    public func send<R: Resource>(_ resource: R, completion: @escaping (Result<Response<Void>, Error>) -> Void) {
        let request = URLRequest(resource, configuration: configuration)
        transport.send(request: request, completion: handleEmptyResponse(completion: completion))
    }
    
    public func send<R: Resource & HasRequestBody>(_ resource: R, completion: @escaping (Result<Response<Void>, Error>) -> Void) {
        let request: URLRequest
        do {
            request = try URLRequest(resource, configuration: configuration, encoder: encoder)
        } catch {
            completion(.failure(error))
            return
        }
        transport.send(request: request, completion: handleEmptyResponse(completion: completion))
    }
    
    public func send<R: Resource & HasRequestBody & Paginated>(_ resource: R, pageOptions: PageOptions? = nil, completion: @escaping (Result<Response<Void>, Error>) -> Void) {
        let request: URLRequest
        do {
            request = try URLRequest(resource, configuration: configuration, encoder: encoder, pageOptions: pageOptions)
        } catch {
            completion(.failure(error))
            return
        }
        transport.send(request: request, completion: handleEmptyResponse(completion: completion))
    }
    
    private func handleContentfulResponse<Content: Decodable>(completion: @escaping (Result<Response<Content>, Error>) -> Void) -> Transport.Completion {
        return { [weak self] result in
            guard let self = self else {
                return
            }
            let content: Content
            let response: URLResponse
            do {
                let data: Data
                (data, response) = try result.get()
                try self.checkResponseForIssues(response)
                content = try self.decoder.decode(Content.self, from: data)
            } catch {
                completion(.failure(error))
                return
            }
            completion(.success(Response(content: content, response: response)))
        }
    }
    
    private func handleEmptyResponse(completion: @escaping (Result<Response<Void>, Error>) -> Void) -> Transport.Completion {
        return { [weak self] result in
            guard let self = self else {
                return
            }
            var response: URLResponse
            do {
                (_, response) = try result.get()
                try self.checkResponseForIssues(response)
            } catch {
                completion(.failure(error))
                return
            }
            completion(.success(Response(content: (), response: response)))
        }
    }
    
    private func checkResponseForIssues(_ response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse,
            let statusCode = StatusCode(rawValue: response.statusCode) else {
                throw ResponseError.missingResponse
        }
        if !statusCode.isSuccess {
            throw statusCode
        }
    }
}

#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension Buildkite {
    public func sendPublisher<R: Resource & HasResponseBody>(_ resource: R) -> AnyPublisher<Response<R.Content>, Error> {
        transport.sendPublisher(request: URLRequest(resource, configuration: configuration))
            .tryMap {
                try self.checkResponseForIssues($0.response)
                let content = try self.decoder.decode(R.Content.self, from: $0.data)
                return Response(content: content, response: $0.response)
        }
        .eraseToAnyPublisher()
    }
    
    public func sendPublisher<R: Resource & HasResponseBody & Paginated>(_ resource: R, pageOptions: PageOptions? = nil) -> AnyPublisher<Response<R.Content>, Error> {
        transport.sendPublisher(request: URLRequest(resource, configuration: configuration, pageOptions: pageOptions))
            .tryMap {
                try self.checkResponseForIssues($0.response)
                let content = try self.decoder.decode(R.Content.self, from: $0.data)
                return Response(content: content, response: $0.response)
        }
        .eraseToAnyPublisher()
    }
    
    public func sendPublisher<R: Resource & HasRequestBody & HasResponseBody>(_ resource: R) -> AnyPublisher<Response<R.Content>, Error> {
        Result { try URLRequest(resource, configuration: configuration, encoder: encoder) }
            .publisher
            .flatMap(transport.sendPublisher)
            .tryMap {
                try self.checkResponseForIssues($0.response)
                let content = try self.decoder.decode(R.Content.self, from: $0.data)
                return Response(content: content, response: $0.response)
        }
        .eraseToAnyPublisher()
    }
    
    public func sendPublisher<R: Resource & HasRequestBody & HasResponseBody & Paginated>(_ resource: R, pageOptions: PageOptions? = nil) -> AnyPublisher<Response<R.Content>, Error> {
        Result { try URLRequest(resource, configuration: configuration, encoder: encoder, pageOptions: pageOptions) }
            .publisher
            .flatMap(transport.sendPublisher)
            .tryMap {
                try self.checkResponseForIssues($0.response)
                let content = try self.decoder.decode(R.Content.self, from: $0.data)
                return Response(content: content, response: $0.response)
        }
        .eraseToAnyPublisher()
    }
    
    public func sendPublisher<R: Resource>(_ resource: R) -> AnyPublisher<Response<Void>, Error> {
        transport.sendPublisher(request: URLRequest(resource, configuration: configuration))
            .tryMap {
                try self.checkResponseForIssues($0.response)
                return Response(content: (), response: $0.response)
        }
        .eraseToAnyPublisher()
    }
    
    func sendPublisher<R: Resource & HasRequestBody>(_ resource: R) -> AnyPublisher<Response<Void>, Error> {
        Result { try URLRequest(resource, configuration: configuration, encoder: encoder) }
            .publisher
            .flatMap(transport.sendPublisher)
            .tryMap {
                try self.checkResponseForIssues($0.response)
                return Response(content: (), response: $0.response)
        }
        .eraseToAnyPublisher()
    }
    
    func sendPublisher<R: Resource & HasRequestBody & Paginated>(_ resource: R, pageOptions: PageOptions? = nil) -> AnyPublisher<Response<Void>, Error> {
        Result { try URLRequest(resource, configuration: configuration, encoder: encoder, pageOptions: pageOptions) }
            .publisher
            .flatMap(transport.sendPublisher)
            .tryMap {
                try self.checkResponseForIssues($0.response)
                return Response(content: (), response: $0.response)
        }
        .eraseToAnyPublisher()
    }
}
#endif
