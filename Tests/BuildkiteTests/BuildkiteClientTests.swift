//
//  BuildkiteClientTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest

@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class BuildkiteClientTests: XCTestCase {
    private struct TestData {
        enum Case {
            case success
            case successPaginated
            case successNoContent
            case successHasBody
            case successHasBodyAndContent
            case successHasBodyPaginated
            case successGraphQL
            case badResponse
            case unsuccessfulResponse
            case unrecognizedBuildkiteError
            case noData
        }

        var configuration = Configuration.default
        var client: BuildkiteClient
        var resources = MockResources()

        init(
            testCase: Case = .success
        ) throws {
            let responses: [(Data, URLResponse)]

            switch testCase {
            case .success:
                responses = [try MockData.mockingSuccess(with: resources.content, url: configuration.version.baseURL)]
            case .successPaginated:
                responses = [
                    try MockData.mockingSuccess(with: resources.paginatedContent, url: configuration.version.baseURL)
                ]
            case .successNoContent:
                responses = [MockData.mockingSuccessNoContent(url: configuration.version.baseURL)]
            case .successHasBody:
                responses = [MockData.mockingSuccessNoContent(url: configuration.version.baseURL)]
            case .successHasBodyAndContent:
                responses = [
                    try MockData.mockingSuccess(with: resources.bodyAndContent, url: configuration.version.baseURL)
                ]
            case .successHasBodyPaginated:
                responses = [
                    try MockData.mockingSuccess(
                        with: resources.bodyAndPaginatedContent,
                        url: configuration.version.baseURL
                    )
                ]
            case .successGraphQL:
                responses = [
                    try MockData.mockingSuccess(with: resources.graphQLIntermediary, url: configuration.version.baseURL)
                ]
            case .badResponse:
                responses = [MockData.mockingIncompatibleResponse(for: configuration.version.baseURL)]
            case .unsuccessfulResponse:
                responses = [MockData.mockingUnsuccessfulResponse(for: configuration.version.baseURL)]
            case .unrecognizedBuildkiteError:
                responses = [MockData.mockingUnrecognizedBuildkiteError(for: configuration.version.baseURL)]
            case .noData:
                responses = []
            }

            let token = "a valid token, i guess"
            client = BuildkiteClient(
                configuration: configuration,
                transport: MockTransport(responses: responses),
                token: token
            )
            XCTAssertEqual(token, RawTokenProvider(rawValue: token).token(for: .REST.v2))
        }
    }

    func testResourceWithIncompatibleAPIVersion() async throws {
        let testData = try TestData(testCase: .success)
        let resource = MockResources.IsAPIIncompatible()
        try await XCTAssertThrowsError(
            await testData.client.send(resource),
            error: ResourceError.incompatibleVersion(resource.version)
        )
    }
}

// MARK: - Async/Await-based Requests

extension BuildkiteClientTests {
    func testRequest() async throws {
        let testData = try TestData(testCase: .success)
        let response = try await testData.client.send(testData.resources.contentResource)
        XCTAssertEqual(testData.resources.content, response.content)
    }

    func testRequestWithPagination() async throws {
        let testData = try TestData(testCase: .successPaginated)
        let response = try await testData.client.send(
            testData.resources.paginatedContentResource,
            pageOptions: PageOptions(page: 1, perPage: 30)
        )
        XCTAssertEqual(testData.resources.paginatedContent, response.content)
        XCTAssertNotNil(response.page)
    }

    func testNoContentResponse() async throws {
        let testData = try TestData(testCase: .successNoContent)
        _ = try await testData.client.send(testData.resources.noContentNoBodyResource)
    }

    func testRequestHasBody() async throws {
        let testData = try TestData(testCase: .successHasBody)
        _ = try await testData.client.send(testData.resources.bodyResource)
    }

    func testRequestHasBodyWithContent() async throws {
        let testData = try TestData(testCase: .successHasBodyAndContent)
        let response = try await testData.client.send(testData.resources.bodyAndContentResource)
        XCTAssertEqual(testData.resources.bodyAndContent, response.content)
    }

    func testRequestHasBodyAndPagination() async throws {
        let testData = try TestData(testCase: .successHasBodyPaginated)
        let response = try await testData.client.send(
            testData.resources.bodyAndPaginatedResource,
            pageOptions: PageOptions(page: 1, perPage: 30)
        )
        XCTAssertEqual(testData.resources.bodyAndPaginatedContent, response.content)
        XCTAssertNotNil(response.page)
    }

    func testGraphQLRequest() async throws {
        let testData = try TestData(testCase: .successGraphQL)
        let content = try await testData.client.sendQuery(testData.resources.graphQLResource)
        XCTAssertEqual(testData.resources.graphQLContent, content)
    }

    func testInvalidResponse() async throws {
        let testData = try TestData(testCase: .badResponse)
        try await XCTAssertThrowsError(
            await testData.client.send(testData.resources.contentResource)
        )
    }

    func testUnsuccessfulResponse() async throws {
        let testData = try TestData(testCase: .unsuccessfulResponse)
        try await XCTAssertThrowsError(
            await testData.client.send(testData.resources.contentResource)
        )
    }

    func testUnrecognizedBuildkiteError() async throws {
        let testData = try TestData(testCase: .unrecognizedBuildkiteError)
        try await XCTAssertThrowsError(
            await testData.client.send(testData.resources.contentResource)
        )
    }
}
