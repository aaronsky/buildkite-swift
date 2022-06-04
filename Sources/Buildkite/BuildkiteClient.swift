//
//  BuildkiteClient.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class BuildkiteClient {
    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom(Formatters.encodeISO8601)
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(Formatters.decodeISO8601)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }

    /// Configuration for general interaction with the Buildkite API, including access tokens and supported API versions.
    var configuration: Configuration

    /// The network (or whatever) transport layer. Implemented by URLSession by default.
    private var transport: Transport

    /// Convenience property for setting the access token used by the client.
    public var token: String? {
        get {
            configuration.token
        }
        set {
            configuration.token = newValue
        }
    }

    /// Creates a session with the specified configuration and transport layer.
    /// - Parameters:
    ///   - configuration: Configures supported API versions and the access token. Uses the latest supported API versions by default. See ``token`` for setting the client access token if using the default configuration.
    ///   - transport: Transport layer used for API communication. Uses the shared URLSession by default.
    public init(
        configuration: Configuration = .default,
        transport: Transport = URLSession.shared
    ) {
        self.configuration = configuration
        self.transport = transport
    }

    private func handleContentfulResponse<Content: Decodable>(
        completion: @escaping (Result<Response<Content>, Error>) -> Void
    ) -> Transport.Completion {
        return { [weak self] result in
            guard let self = self else {
                return
            }
            let content: Content
            let response: URLResponse
            do {
                let data: Data
                (data, response) = try result.get()
                try self.checkResponseForIssues(response, data: data)
                content = try self.decoder.decode(Content.self, from: data)
            } catch {
                completion(.failure(error))
                return
            }
            completion(.success(Response(content: content, response: response)))
        }
    }

    private func handleEmptyResponse(
        completion: @escaping (Result<Response<Void>, Error>) -> Void
    ) -> Transport.Completion {
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

    private func checkResponseForIssues(_ response: URLResponse, data: Data? = nil) throws {
        guard let httpResponse = response as? HTTPURLResponse,
            let statusCode = StatusCode(rawValue: httpResponse.statusCode)
        else {
            throw ResponseError.incompatibleResponse(response)
        }
        if !statusCode.isSuccess {
            guard let data = data,
                let errorIntermediary = try? decoder.decode(BuildkiteError.Intermediary.self, from: data)
            else {
                throw statusCode
            }
            throw BuildkiteError(statusCode: statusCode, intermediary: errorIntermediary)
        }
    }
}

// MARK: - Closure API

extension BuildkiteClient {
    /// Performs the given resource asynchronously, then calls a handler upon completion.
    /// - Parameters:
    ///    - resource:A resource.
    ///    - completion:The completion handler to call when the operation has completed. This handler is called on whatever queue the transport layer is implemented to use. You should generally assume this is happening on a global background queue, such as the case when using the shared URLSession.
    public func send<R>(_ resource: R, completion: @escaping (Result<Response<R.Content>, Error>) -> Void)
    where R: Resource, R.Content: Decodable {
        do {
            let request = try URLRequest(resource, configuration: configuration)
            transport.send(request: request, completion: handleContentfulResponse(completion: completion))
        } catch {
            completion(.failure(error))
        }
    }

    /// Performs the given resource asynchronously, then calls a handler upon completion.
    /// - Parameters:
    ///    - resource:A resource.
    ///    - pageOptions: Page options to perform pagination.
    ///    - completion:The completion handler to call when the operation has completed. This handler is called on whatever queue the transport layer is implemented to use. You should generally assume this is happening on a global background queue, such as the case when using the shared URLSession.
    public func send<R>(
        _ resource: R,
        pageOptions: PageOptions? = nil,
        completion: @escaping (Result<Response<R.Content>, Error>) -> Void
    ) where R: PaginatedResource {
        do {
            let request = try URLRequest(resource, configuration: configuration, pageOptions: pageOptions)
            transport.send(request: request, completion: handleContentfulResponse(completion: completion))
        } catch {
            completion(.failure(error))
        }
    }

    /// Performs the given resource asynchronously, then calls a handler upon completion.
    /// - Parameters:
    ///    - resource:A resource.
    ///    - completion:The completion handler to call when the operation has completed. This handler is called on whatever queue the transport layer is implemented to use. You should generally assume this is happening on a global background queue, such as the case when using the shared URLSession.
    public func send<R>(_ resource: R, completion: @escaping (Result<Response<R.Content>, Error>) -> Void)
    where R: Resource, R.Body: Encodable, R.Content: Decodable {
        do {
            let request = try URLRequest(resource, configuration: configuration, encoder: encoder)
            transport.send(request: request, completion: handleContentfulResponse(completion: completion))
        } catch {
            completion(.failure(error))
        }
    }

    /// Performs the given resource asynchronously, then calls a handler upon completion.
    /// - Parameters:
    ///    - resource:A resource.
    ///    - pageOptions: Page options to perform pagination.
    ///    - completion:The completion handler to call when the operation has completed. This handler is called on whatever queue the transport layer is implemented to use. You should generally assume this is happening on a global background queue, such as the case when using the shared URLSession.
    public func send<R>(
        _ resource: R,
        pageOptions: PageOptions? = nil,
        completion: @escaping (Result<Response<R.Content>, Error>) -> Void
    ) where R: PaginatedResource, R.Body: Encodable {
        do {
            let request = try URLRequest(
                resource,
                configuration: configuration,
                encoder: encoder,
                pageOptions: pageOptions
            )
            transport.send(request: request, completion: handleContentfulResponse(completion: completion))
        } catch {
            completion(.failure(error))
        }
    }

    /// Performs the given resource asynchronously, then calls a handler upon completion.
    /// - Parameters:
    ///    - resource:A resource.
    ///    - completion:The completion handler to call when the operation has completed. This handler is called on whatever queue the transport layer is implemented to use. You should generally assume this is happening on a global background queue, such as the case when using the shared URLSession.
    public func send<R>(_ resource: R, completion: @escaping (Result<Response<R.Content>, Error>) -> Void)
    where R: Resource, R.Content == Void {
        do {
            let request = try URLRequest(resource, configuration: configuration)
            transport.send(request: request, completion: handleEmptyResponse(completion: completion))
        } catch {
            completion(.failure(error))
        }
    }

    /// Performs the given resource asynchronously, then calls a handler upon completion.
    /// - Parameters:
    ///    - resource:A resource.
    ///    - completion:The completion handler to call when the operation has completed. This handler is called on whatever queue the transport layer is implemented to use. You should generally assume this is happening on a global background queue, such as the case when using the shared URLSession.
    public func send<R>(_ resource: R, completion: @escaping (Result<Response<R.Content>, Error>) -> Void)
    where R: Resource, R.Body: Encodable, R.Content == Void {
        do {
            let request = try URLRequest(resource, configuration: configuration, encoder: encoder)
            transport.send(request: request, completion: handleEmptyResponse(completion: completion))
        } catch {
            completion(.failure(error))
        }
    }

    /// Performs the given GraphQL query or mutation asynchronously, then calls a handler upon completion.
    /// - Parameters:
    ///    - resource:A resource.
    ///    - completion:The completion handler to call when the operation has completed. This handler is called on whatever queue the transport layer is implemented to use. You should generally assume this is happening on a global background queue, such as the case when using the shared URLSession.
    public func sendQuery<T>(_ resource: GraphQL<T>, completion: @escaping (Result<T, Error>) -> Void) {
        send(resource) { result in
            do {
                switch (try result.get()).content {
                case let .data(data):
                    completion(.success(data))
                case let .errors(errors):
                    completion(.failure(errors))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Combine API

#if canImport(Combine)
import Combine

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension BuildkiteClient {
    /// Performs the given resource and publishes the response asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: The publisher publishes the response when the operation completes, or terminates if the operation fails with an error.
    public func sendPublisher<R>(_ resource: R) -> AnyPublisher<Response<R.Content>, Error>
    where R: Resource, R.Content: Decodable {
        Result { try URLRequest(resource, configuration: configuration) }
            .publisher
            .flatMap(transport.sendPublisher)
            .tryMap {
                try self.checkResponseForIssues($0.response, data: $0.data)
                let content = try self.decoder.decode(R.Content.self, from: $0.data)
                return Response(content: content, response: $0.response)
            }
            .eraseToAnyPublisher()
    }

    /// Performs the given resource and publishes the response asynchronously.
    /// - Parameters:
    ///    - resource: A resource.
    ///    - pageOptions: Page options to perform pagination.
    /// - Returns: The publisher publishes the response when the operation completes, or terminates if the operation fails with an error.
    public func sendPublisher<R>(
        _ resource: R,
        pageOptions: PageOptions? = nil
    ) -> AnyPublisher<Response<R.Content>, Error> where R: PaginatedResource {
        Result { try URLRequest(resource, configuration: configuration, pageOptions: pageOptions) }
            .publisher
            .flatMap(transport.sendPublisher)
            .tryMap {
                try self.checkResponseForIssues($0.response, data: $0.data)
                let content = try self.decoder.decode(R.Content.self, from: $0.data)
                return Response(content: content, response: $0.response)
            }
            .eraseToAnyPublisher()
    }

    /// Performs the given resource and publishes the response asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: The publisher publishes the response when the operation completes, or terminates if the operation fails with an error.
    public func sendPublisher<R>(_ resource: R) -> AnyPublisher<Response<R.Content>, Error>
    where R: Resource, R.Body: Encodable, R.Content: Decodable {
        Result { try URLRequest(resource, configuration: configuration, encoder: encoder) }
            .publisher
            .flatMap(transport.sendPublisher)
            .tryMap {
                try self.checkResponseForIssues($0.response, data: $0.data)
                let content = try self.decoder.decode(R.Content.self, from: $0.data)
                return Response(content: content, response: $0.response)
            }
            .eraseToAnyPublisher()
    }

    /// Performs the given resource and publishes the response asynchronously.
    /// - Parameters:
    ///    - resource: A resource.
    ///    - pageOptions: Page options to perform pagination.
    /// - Returns: The publisher publishes the response when the operation completes, or terminates if the operation fails with an error.
    public func sendPublisher<R>(
        _ resource: R,
        pageOptions: PageOptions? = nil
    ) -> AnyPublisher<Response<R.Content>, Error> where R: PaginatedResource, R.Body: Encodable {
        Result { try URLRequest(resource, configuration: configuration, encoder: encoder, pageOptions: pageOptions) }
            .publisher
            .flatMap(transport.sendPublisher)
            .tryMap {
                try self.checkResponseForIssues($0.response, data: $0.data)
                let content = try self.decoder.decode(R.Content.self, from: $0.data)
                return Response(content: content, response: $0.response)
            }
            .eraseToAnyPublisher()
    }

    /// Performs the given resource and publishes the response asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: The publisher publishes the response when the operation completes, or terminates if the operation fails with an error.
    public func sendPublisher<R>(_ resource: R) -> AnyPublisher<Response<R.Content>, Error>
    where R: Resource, R.Content == Void {
        Result { try URLRequest(resource, configuration: configuration) }
            .publisher
            .flatMap(transport.sendPublisher)
            .tryMap {
                try self.checkResponseForIssues($0.response)
                return Response(content: (), response: $0.response)
            }
            .eraseToAnyPublisher()
    }

    /// Performs the given resource and publishes the response asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: The publisher publishes the response when the operation completes, or terminates if the operation fails with an error.
    public func sendPublisher<R>(_ resource: R) -> AnyPublisher<Response<R.Content>, Error>
    where R: Resource, R.Body: Encodable, R.Content == Void {
        Result { try URLRequest(resource, configuration: configuration, encoder: encoder) }
            .publisher
            .flatMap(transport.sendPublisher)
            .tryMap {
                try self.checkResponseForIssues($0.response)
                return Response(content: (), response: $0.response)
            }
            .eraseToAnyPublisher()
    }

    /// Performs the given GraphQL query or mutation and publishes the content asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: The publisher publishes the content when the operation completes, or terminates if the operation fails with an error.
    public func sendQueryPublisher<T>(_ resource: GraphQL<T>) -> AnyPublisher<T, Error> {
        sendPublisher(resource)
            .map(\.content)
            .tryMap { try $0.get() }
            .eraseToAnyPublisher()
    }
}
#endif

#if compiler(>=5.5.2) && canImport(_Concurrency)

// MARK: - Async/Await API

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension BuildkiteClient {
    /// Performs the given resource asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: A response containing the content of the response body, as well as other information about the HTTP operation.
    public func send<R>(_ resource: R) async throws -> Response<R.Content> where R: Resource, R.Content: Decodable {
        let request = try URLRequest(resource, configuration: configuration)
        let (data, response) = try await transport.send(request: request)
        try checkResponseForIssues(response, data: data)
        let content = try self.decoder.decode(R.Content.self, from: data)
        return Response(content: content, response: response)
    }

    /// Performs the given resource asynchronously.
    /// - Parameters:
    ///    - resource: A resource.
    ///    - pageOptions: Page options to perform pagination.
    /// - Returns: A response containing the content of the response body, as well as other information about the HTTP operation.
    public func send<R>(_ resource: R, pageOptions: PageOptions? = nil) async throws -> Response<R.Content>
    where R: PaginatedResource {
        let request = try URLRequest(resource, configuration: configuration, pageOptions: pageOptions)
        let (data, response) = try await transport.send(request: request)
        try checkResponseForIssues(response, data: data)
        let content = try self.decoder.decode(R.Content.self, from: data)
        return Response(content: content, response: response)
    }

    /// Performs the given resource asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: A response containing the content of the response body, as well as other information about the HTTP operation.
    public func send<R>(_ resource: R) async throws -> Response<R.Content>
    where R: Resource, R.Body: Encodable, R.Content: Decodable {
        let request = try URLRequest(resource, configuration: configuration, encoder: encoder)
        let (data, response) = try await transport.send(request: request)
        try checkResponseForIssues(response, data: data)
        let content = try self.decoder.decode(R.Content.self, from: data)
        return Response(content: content, response: response)
    }

    /// Performs the given resource asynchronously.
    /// - Parameters:
    ///    - resource: A resource.
    ///    - pageOptions: Page options to perform pagination.
    /// - Returns: A response containing the content of the response body, as well as other information about the HTTP operation.
    public func send<R>(_ resource: R, pageOptions: PageOptions? = nil) async throws -> Response<R.Content>
    where R: PaginatedResource, R.Body: Encodable {
        let request = try URLRequest(resource, configuration: configuration, encoder: encoder, pageOptions: pageOptions)

        let (data, response) = try await transport.send(request: request)
        try checkResponseForIssues(response, data: data)
        let content = try self.decoder.decode(R.Content.self, from: data)
        return Response(content: content, response: response)
    }

    /// Performs the given resource asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: A response containing the content of the response body, as well as other information about the HTTP operation.
    public func send<R>(_ resource: R) async throws -> Response<R.Content> where R: Resource, R.Content == Void {
        let request = try URLRequest(resource, configuration: configuration)
        let (data, response) = try await transport.send(request: request)
        try checkResponseForIssues(response, data: data)
        return Response(content: (), response: response)
    }

    /// Performs the given resource asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: A response containing information about the HTTP operation, and no content.
    public func send<R>(_ resource: R) async throws -> Response<R.Content>
    where R: Resource, R.Body: Encodable, R.Content == Void {
        let request = try URLRequest(resource, configuration: configuration, encoder: encoder)
        let (data, response) = try await transport.send(request: request)
        try checkResponseForIssues(response, data: data)
        return Response(content: (), response: response)
    }

    /// Performs the given GraphQL query or mutation and returns the content asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: Content of the resolved GraphQL operation.
    /// - Throws: An error either of type ``BuildkiteError`` or ``GraphQL/Errors``.
    public func sendQuery<T>(_ resource: GraphQL<T>) async throws -> T {
        let response = try await send(resource)
        return try response.content.get()
    }
}
#endif
