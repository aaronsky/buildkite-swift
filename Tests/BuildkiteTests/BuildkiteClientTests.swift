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

    func testResourceWithIncompatibleAPIVersion() throws {
        let testData = try TestData(testCase: .success)
        let resource = MockResources.IsAPIIncompatible()
        let expectation = XCTestExpectation()
        testData.client.send(resource) { result in
            do {
                _ = try result.get()
                XCTFail("Expected to have failed with an error, but closure fulfilled normally")
            } catch ResourceError.incompatibleVersion(resource.version) {
                // Expected error
            } catch {
                XCTFail("Expected to have failed with an error, but not this one: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Closure-based Requests

extension BuildkiteClientTests {
    func testClosureBasedRequest() throws {
        let testData = try TestData(testCase: .success)

        let expectation = XCTestExpectation()
        testData.client.send(testData.resources.contentResource) { result in
            do {
                let response = try result.get()
                XCTAssertEqual(testData.resources.content, response.content)
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testClosureBasedRequestWithPagination() throws {
        let testData = try TestData(testCase: .success)

        let expectation = XCTestExpectation()
        testData.client.send(
            testData.resources.paginatedContentResource,
            pageOptions: PageOptions(page: 1, perPage: 30)
        ) { result in
            do {
                let response = try result.get()
                XCTAssertEqual(testData.resources.paginatedContent, response.content)
                XCTAssertNotNil(response.page)
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testClosureBasedRequestNoContent() throws {
        let testData = try TestData(testCase: .successNoContent)

        let expectation = XCTestExpectation()
        testData.client.send(testData.resources.noContentNoBodyResource) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testClosureBasedRequestHasBody() throws {
        let testData = try TestData(testCase: .successHasBody)

        let expectation = XCTestExpectation()
        testData.client.send(testData.resources.bodyResource) { _ in
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testClosureBasedRequestHasBodyWithContent() throws {
        let testData = try TestData(testCase: .successHasBodyAndContent)

        let expectation = XCTestExpectation()
        testData.client.send(testData.resources.bodyAndContentResource) { result in
            do {
                let response = try result.get()
                XCTAssertEqual(testData.resources.bodyAndContent, response.content)
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testClosureBasedRequestHasBodyWithPagination() throws {
        let testData = try TestData(testCase: .successHasBodyPaginated)

        let expectation = XCTestExpectation()
        testData.client.send(
            testData.resources.bodyAndPaginatedResource,
            pageOptions: PageOptions(page: 1, perPage: 30)
        ) { result in
            do {
                let response = try result.get()
                XCTAssertEqual(testData.resources.bodyAndPaginatedContent, response.content)
                XCTAssertNotNil(response.page)
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testClosureBasedGraphQLRequest() throws {
        let testData = try TestData(testCase: .successGraphQL)

        let expectation = XCTestExpectation()
        testData.client.sendQuery(testData.resources.graphQLResource) { result in
            do {
                let content = try result.get()
                XCTAssertEqual(testData.resources.graphQLContent, content)
            } catch {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testClosureBasedRequestInvalidResponse() throws {
        let testData = try TestData(testCase: .badResponse)
        let expectation = XCTestExpectation()
        testData.client.send(testData.resources.contentResource) { result in
            do {
                _ = try result.get()
                XCTFail("Expected to have failed with an error, but closure fulfilled normally")
            } catch {}
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testClosureBasedRequestUnsuccessfulResponse() throws {
        let testData = try TestData(testCase: .unsuccessfulResponse)
        let expectation = XCTestExpectation()
        testData.client.send(testData.resources.contentResource) { result in
            defer {
                expectation.fulfill()
            }
            guard let _ = try? result.get() else {
                return
            }
            XCTFail("Expected to have failed with an error, but closure fulfilled normally")
        }
        wait(for: [expectation])
    }

    func testFailureFromTransport() throws {
        let testData = try TestData(testCase: .noData)
        let expectation = XCTestExpectation()
        testData.client.send(testData.resources.contentResource) { result in
            defer {
                expectation.fulfill()
            }
            guard let _ = try? result.get() else {
                return
            }
            XCTFail("Expected to have failed with an error, but closure fulfilled normally")
        }
        wait(for: [expectation])
    }
}

// MARK: - Combine-based Requests

#if canImport(Combine)
import Combine

@available(iOS 13, macOS 10.15, tvOS 13, watchOS 6, *)
extension BuildkiteClientTests {
    func testPublisherBasedRequest() throws {
        let testData = try TestData(testCase: .success)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.contentResource)
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        XCTFail(error.localizedDescription)
                    }
                    expectation.fulfill()
                },
                receiveValue: { XCTAssertEqual(testData.resources.content, $0.content) }
            )
            .store(in: &cancellables)
        wait(for: [expectation])
    }

    func testPublisherBasedRequestWithPagination() throws {
        let testData = try TestData(testCase: .success)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client
            .sendPublisher(testData.resources.paginatedContentResource, pageOptions: PageOptions(page: 1, perPage: 30))
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        XCTFail(error.localizedDescription)
                    }
                    expectation.fulfill()
                },
                receiveValue: {
                    XCTAssertEqual(testData.resources.paginatedContent, $0.content)
                    XCTAssertNotNil($0.page)
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation])
    }

    func testPublisherBasedRequestNoContent() throws {
        let testData = try TestData(testCase: .success)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.noContentNoBodyResource)
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        XCTFail(error.localizedDescription)
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        wait(for: [expectation])
    }

    func testPublisherBasedRequestHasBody() throws {
        let testData = try TestData(testCase: .successHasBody)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.bodyResource)
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        XCTFail(error.localizedDescription)
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        wait(for: [expectation])
    }

    func testPublisherBasedRequestHasBodyWithContent() throws {
        let testData = try TestData(testCase: .successHasBodyAndContent)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.bodyAndContentResource)
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        XCTFail(error.localizedDescription)
                    }
                    expectation.fulfill()
                },
                receiveValue: {
                    XCTAssertEqual(testData.resources.bodyAndContent, $0.content)
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation])
    }

    func testPublisherBasedRequestHasBodyWithPagination() throws {
        let testData = try TestData(testCase: .successHasBodyPaginated)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client
            .sendPublisher(testData.resources.bodyAndPaginatedResource, pageOptions: PageOptions(page: 1, perPage: 30))
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        XCTFail(error.localizedDescription)
                    }
                    expectation.fulfill()
                },
                receiveValue: {
                    XCTAssertEqual(testData.resources.bodyAndPaginatedContent, $0.content)
                    XCTAssertNotNil($0.page)
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation])
    }

    func testPublisherBasedGraphQLRequest() throws {
        let testData = try TestData(testCase: .successGraphQL)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendQueryPublisher(testData.resources.graphQLResource)
            .sink(
                receiveCompletion: {
                    if case .failure(let error) = $0 {
                        XCTFail(error.localizedDescription)
                    }
                    expectation.fulfill()
                },
                receiveValue: {
                    XCTAssertEqual(testData.resources.graphQLContent, $0)
                }
            )
            .store(in: &cancellables)
        wait(for: [expectation])
    }

    func testPublisherBasedRequestInvalidResponse() throws {
        let testData = try TestData(testCase: .badResponse)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.contentResource)
            .sink(
                receiveCompletion: {
                    if case .finished = $0 {
                        XCTFail("Expected to have failed with an error, but publisher fulfilled normally")
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        wait(for: [expectation])
    }

    func testPublisherBasedRequestUnsuccessfulResponse() throws {
        let testData = try TestData(testCase: .unsuccessfulResponse)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.contentResource)
            .sink(
                receiveCompletion: {
                    if case .finished = $0 {
                        XCTFail("Expected to have failed with an error, but publisher fulfilled normally")
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
        wait(for: [expectation])
    }
}
#endif

// MARK: - Async/Await-based Requests

extension BuildkiteClientTests {
    func testAsyncBasedRequest() async throws {
        let testData = try TestData(testCase: .success)
        let response = try await testData.client.send(testData.resources.contentResource)
        XCTAssertEqual(testData.resources.content, response.content)
    }

    func testAsyncBasedRequestWithPagination() async throws {
        let testData = try TestData(testCase: .success)
        let response = try await testData.client.send(
            testData.resources.paginatedContentResource,
            pageOptions: PageOptions(page: 1, perPage: 30)
        )
        XCTAssertEqual(testData.resources.paginatedContent, response.content)
        XCTAssertNotNil(response.page)
    }

    func testAsyncBasedRequestNoContent() async throws {
        let testData = try TestData(testCase: .success)
        _ = try await testData.client.send(testData.resources.noContentNoBodyResource)
    }

    func testAsyncBasedRequestHasBody() async throws {
        let testData = try TestData(testCase: .successHasBody)
        _ = try await testData.client.send(testData.resources.bodyResource)
    }

    func testAsyncBasedRequestHasBodyWithContent() async throws {
        let testData = try TestData(testCase: .successHasBodyAndContent)
        let response = try await testData.client.send(testData.resources.bodyAndContentResource)
        XCTAssertEqual(testData.resources.bodyAndContent, response.content)
    }

    func testAsyncBasedRequestHasBodyWithPagination() async throws {
        let testData = try TestData(testCase: .successHasBodyPaginated)
        let response = try await testData.client.send(
            testData.resources.bodyAndPaginatedResource,
            pageOptions: PageOptions(page: 1, perPage: 30)
        )
        XCTAssertEqual(testData.resources.bodyAndPaginatedContent, response.content)
        XCTAssertNotNil(response.page)
    }

    func testAsyncBasedGraphQLRequest() async throws {
        let testData = try TestData(testCase: .successGraphQL)
        let content = try await testData.client.sendQuery(testData.resources.graphQLResource)
        XCTAssertEqual(testData.resources.graphQLContent, content)
    }

    func testAsyncBasedRequestInvalidResponse() async throws {
        let testData = try TestData(testCase: .badResponse)
        do {
            _ = try await testData.client.send(testData.resources.contentResource)
            XCTFail("Expected to have failed with an error, but task fulfilled normally")
        } catch {}
    }

    func testAsyncBasedRequestUnsuccessfulResponse() async throws {
        let testData = try TestData(testCase: .unsuccessfulResponse)
        do {
            _ = try await testData.client.send(testData.resources.contentResource)
            XCTFail("Expected to have failed with an error, but task fulfilled normally")
        } catch {}
    }
}
