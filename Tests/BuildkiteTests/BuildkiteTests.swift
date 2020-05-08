//
//  BuildkiteTests.swift
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

#if canImport(Combine)
import Combine
#endif

class BuildkiteTests: XCTestCase {
    private struct TestData {
        enum Case {
            case success
            case successPaginated
            case successNoContent
            case successHasBody
            case successHasBodyPaginated
            case badResponse
            case unsuccessfulResponse
            case noData
        }
        
        var configuration = Configuration.default
        var client: Buildkite
        var resources = MockResources()
        
        init(testCase: Case = .success) throws {
            let responses: [(Data, URLResponse)]
            
            switch testCase {
            case .success:
                responses = [try MockData.mockingSuccess(with: resources.content, url: configuration.baseURL)]
            case .successPaginated:
                responses = [try MockData.mockingSuccess(with: resources.paginatedContent, url: configuration.baseURL)]
            case .successNoContent:
                responses = [MockData.mockingSuccessNoContent(url: configuration.baseURL)]
            case .successHasBody:
                responses = [MockData.mockingSuccessNoContent(url: configuration.baseURL)]
            case .successHasBodyPaginated:
                responses = [try MockData.mockingSuccess(with: resources.bodyAndPaginatedContent, url: configuration.baseURL)]
            case .badResponse:
                responses = [MockData.mockingIncompatibleResponse(for: configuration.baseURL)]
            case .unsuccessfulResponse:
                responses = [MockData.mockingUnsuccessfulResponse(for: configuration.baseURL)]
            case .noData:
                responses = []
            }
            
            client = Buildkite(configuration: configuration,
                               transport: MockTransport(responses: responses))
        }
    }
}

// MARK: Closure-based Requests

extension BuildkiteTests {
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
        testData.client.send(testData.resources.paginatedContentResource, pageOptions: PageOptions(page: 1, perPage: 30)) { result in
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
    
    func testClosureBasedRequestHasBodyWithPagination() throws {
        let testData = try TestData(testCase: .successHasBodyPaginated)
        
        let expectation = XCTestExpectation()
        testData.client.send(testData.resources.bodyAndPaginatedResource, pageOptions: PageOptions(page: 1, perPage: 30)) { result in
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
    
    func testClosureBasedRequestInvalidResponse() throws {
        let testData = try TestData(testCase: .badResponse)
        let expectation = XCTestExpectation()
        testData.client.send(testData.resources.contentResource) { result in
            do {
                _ = try result.get()
                XCTFail("Expected to have failed with an error, but closure fulfilled normally")
            } catch {
            }
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

// MARK: Combine-based Requests

#if canImport(Combine)
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension BuildkiteTests {
    func testPublisherBasedRequest() throws {
        let testData = try TestData(testCase: .success)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.contentResource)
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            },
                  receiveValue: { XCTAssertEqual(testData.resources.content, $0.content) })
            .store(in: &cancellables)
        wait(for: [expectation])
    }
    
    func testPublisherBasedRequestWithPagination() throws {
        let testData = try TestData(testCase: .success)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.paginatedContentResource, pageOptions: PageOptions(page: 1, perPage: 30))
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            },
                  receiveValue: {
                    XCTAssertEqual(testData.resources.paginatedContent, $0.content)
                    XCTAssertNotNil($0.page)
            })
            .store(in: &cancellables)
        wait(for: [expectation])
    }
    
    func testPublisherBasedRequestNoContent() throws {
        let testData = try TestData(testCase: .success)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.noContentNoBodyResource)
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        wait(for: [expectation])
    }
    
    func testPublisherBasedRequestHasBody() throws {
        let testData = try TestData(testCase: .successHasBody)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.bodyResource)
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        wait(for: [expectation])
    }
    
    func testPublisherBasedRequestHasBodyWithPagination() throws {
        let testData = try TestData(testCase: .successHasBodyPaginated)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.bodyAndPaginatedResource, pageOptions: PageOptions(page: 1, perPage: 30))
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            },
                  receiveValue: {
                    XCTAssertEqual(testData.resources.bodyAndPaginatedContent, $0.content)
                    XCTAssertNotNil($0.page)
            })
            .store(in: &cancellables)
        wait(for: [expectation])
    }
    
    func testPublisherBasedRequestInvalidResponse() throws {
        let testData = try TestData(testCase: .badResponse)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.contentResource)
            .sink(receiveCompletion: {
                if case .finished = $0 {
                    XCTFail("Expected to have failed with an error, but publisher fulfilled normally")
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        wait(for: [expectation])
    }
    
    func testPublisherBasedRequestUnsuccessfulResponse() throws {
        let testData = try TestData(testCase: .unsuccessfulResponse)
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        testData.client.sendPublisher(testData.resources.contentResource)
            .sink(receiveCompletion: {
                if case .finished = $0 {
                    XCTFail("Expected to have failed with an error, but publisher fulfilled normally")
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        wait(for: [expectation])
    }
}
#endif
