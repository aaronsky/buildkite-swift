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

/// Client used to interface with all available Buildkite APIs. The primary mechanism of this library.
public actor BuildkiteClient {
    /// Configuration for general interaction with the Buildkite API, including access tokens and supported API versions.
    var configuration: Configuration

    /// The network (or whatever) transport layer. Implemented by URLSession by default.
    var transport: Transport

    /// Convenience property for setting the access token used by the client.
    var tokens: TokenProvider?

    nonisolated var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom(Formatters.encodeISO8601)
        return encoder
    }

    nonisolated var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(Formatters.decodeISO8601)
        return decoder
    }

    /// Creates a session with the specified configuration, transport layer, and token provider.
    /// - Parameters:
    ///   - configuration: Configures supported API versions and the access token. Uses the latest supported API versions by default.
    ///   - transport: Transport layer used for API communication. Uses the shared URLSession by default.
    ///   - tokens: Token provider used for authorization. Unauthenticated by default.
    public init(
        configuration: Configuration = .default,
        transport: Transport = URLSession.shared,
        tokens: TokenProvider? = nil
    ) {
        self.configuration = configuration
        self.transport = transport
        self.tokens = tokens
    }

    /// Creates a session with the specified configuration, transport layer, and fixed token string.
    /// - Parameters:
    ///   - configuration: Configures supported API versions and the access token. Uses the latest supported API versions by default.
    ///   - transport: Transport layer used for API communication. Uses the shared URLSession by default.
    ///   - token: Raw token used for authorization.
    public init(
        configuration: Configuration = .default,
        transport: Transport = URLSession.shared,
        token: String
    ) {
        self.init(configuration: configuration, transport: transport, tokens: RawTokenProvider(rawValue: token))
    }

    /// Performs the given resource asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: A response containing the content of the response body, as well as other information about the HTTP operation.
    /// - Throws: An error describing the manner in which the resource failed to complete.
    public func send<R>(_ resource: R) async throws -> Response<R.Content> where R: Resource, R.Content: Decodable {
        let request = try URLRequest(resource, configuration: configuration, tokens: tokens)

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
    /// - Throws: An error describing the manner in which the resource failed to complete.
    public func send<R>(_ resource: R, pageOptions: PageOptions? = nil) async throws -> Response<R.Content>
    where R: PaginatedResource {
        let request = try URLRequest(resource, configuration: configuration, tokens: tokens, pageOptions: pageOptions)

        let (data, response) = try await transport.send(request: request)
        try checkResponseForIssues(response, data: data)
        let content = try self.decoder.decode(R.Content.self, from: data)

        return Response(content: content, response: response)
    }

    /// Performs the given resource asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: A response containing the content of the response body, as well as other information about the HTTP operation.
    /// - Throws: An error describing the manner in which the resource failed to complete.
    public func send<R>(_ resource: R) async throws -> Response<R.Content>
    where R: Resource, R.Body: Encodable, R.Content: Decodable {
        let request = try URLRequest(resource, configuration: configuration, tokens: tokens, encoder: encoder)

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
    /// - Throws: An error describing the manner in which the resource failed to complete.
    public func send<R>(_ resource: R, pageOptions: PageOptions? = nil) async throws -> Response<R.Content>
    where R: PaginatedResource, R.Body: Encodable {
        let request = try URLRequest(
            resource,
            configuration: configuration,
            tokens: tokens,
            encoder: encoder,
            pageOptions: pageOptions
        )

        let (data, response) = try await transport.send(request: request)
        try checkResponseForIssues(response, data: data)
        let content = try self.decoder.decode(R.Content.self, from: data)

        return Response(content: content, response: response)
    }

    /// Performs the given resource asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: A response containing the content of the response body, as well as other information about the HTTP operation.
    /// - Throws: An error describing the manner in which the resource failed to complete.
    public func send<R>(_ resource: R) async throws -> Response<R.Content> where R: Resource, R.Content == Void {
        let request = try URLRequest(resource, configuration: configuration, tokens: tokens)

        let (data, response) = try await transport.send(request: request)
        try checkResponseForIssues(response, data: data)

        return Response(content: (), response: response)
    }

    /// Performs the given resource asynchronously.
    /// - Parameter resource: A resource.
    /// - Returns: A response containing information about the HTTP operation, and no content.
    /// - Throws: An error describing the manner in which the resource failed to complete.
    public func send<R>(_ resource: R) async throws -> Response<R.Content>
    where R: Resource, R.Body: Encodable, R.Content == Void {
        let request = try URLRequest(resource, configuration: configuration, tokens: tokens, encoder: encoder)

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

    private func checkResponseForIssues(_ response: URLResponse, data: Data? = nil) throws {
        guard
            let httpResponse = response as? HTTPURLResponse,
            let statusCode = StatusCode(rawValue: httpResponse.statusCode)
        else {
            throw ResponseError.incompatibleResponse(response)
        }

        if statusCode.isSuccess {
            return
        }

        guard
            let data = data,
            let errorIntermediary = try? decoder.decode(BuildkiteError.Intermediary.self, from: data)
        else {
            throw statusCode
        }

        throw BuildkiteError(statusCode: statusCode, intermediary: errorIntermediary)
    }
}
