//
//  TransportTests.swift
//  Buildkite
//
//  Created by Aaron Sky on 3/22/20.
//  Copyright © 2020 Aaron Sky. All rights reserved.
//

@testable import Buildkite
import Foundation
import XCTest

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

class TransportTests: XCTestCase {
    private func createSession(testCase: MockURLProtocol.Case = .success) -> URLSession {
        switch testCase {
        case .success:
            MockURLProtocol.requestHandler = MockData.mockingSuccessNoContent
        case .error:
            MockURLProtocol.requestHandler = MockData.mockingError
        }
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: config)
    }

    private class MockURLProtocol: URLProtocol {
        enum Case {
            case success
            case error
        }

        typealias RequestHandler = (URLRequest) throws -> (Data, URLResponse)
        static var requestHandler: RequestHandler?

        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }

        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }

        override func startLoading() {
            guard let handler = MockURLProtocol.requestHandler else {
                return
            }
            do {
                let (data, response) = try handler(request)
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocolDidFinishLoading(self)
            } catch {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }

        override func stopLoading() {
        }
    }
}

// MARK: - Closure-based Requests

extension TransportTests {
    func testURLSessionSendClosureBasedRequest() {
        let request = URLRequest(url: URL())
        let expectation = XCTestExpectation()
        createSession().send(request: request) {
            if case let .failure(error) = $0 {
                XCTFail(error.localizedDescription)
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }

    func testURLSessionSendClosureBasedRequestFailure() {
        let request = URLRequest(url: URL())
        let expectation = XCTestExpectation()
        createSession(testCase: .error).send(request: request) {
            if case .success(_) = $0 {
                XCTFail("Expected to have failed with an error, but closure fulfilled normally")
            }
            expectation.fulfill()
        }
        wait(for: [expectation])
    }
}

// MARK: - Combine-based Requests

#if canImport(Combine)
import Combine

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
extension TransportTests {
    func testURLSessionSendPublisherBasedRequest() {
        let request = URLRequest(url: URL())
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        createSession()
            .sendPublisher(request: request)
            .sink(receiveCompletion: {
                if case let .failure(error) = $0 {
                    XCTFail(error.localizedDescription)
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
            wait(for: [expectation])
    }

    func testURLSessionSendPublisherBasedRequestFailure() {
        let request = URLRequest(url: URL())
        let expectation = XCTestExpectation()
        var cancellables: Set<AnyCancellable> = []
        createSession(testCase: .error)
            .sendPublisher(request: request)
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

// MARK: - Async/Await-based Requests

#if swift(>=5.5)
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension TransportTests {
    func testURLSessionSendAsyncRequest() async throws {
        let request = URLRequest(url: URL())
        _ = try await createSession().send(request: request)
    }
    
    func testURLSessionSendAsyncRequestFailure() async {
        let request = URLRequest(url: URL())
        do {
            _ = try await createSession(testCase: .error).send(request: request)
            XCTFail("Expected to have failed with an error, but task fulfilled normally")
        } catch {}
    }
}
#endif
