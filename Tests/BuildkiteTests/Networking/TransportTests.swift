//
//  TransportTests.swift
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

extension URLSession {
    fileprivate convenience init(
        _ testCase: MockURLProtocol.Case
    ) {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        self.init(configuration: config)
    }
}

private final class MockURLProtocol: URLProtocol {
    typealias RequestHandler = @Sendable (URLRequest) throws -> (Data, URLResponse)

    enum Case {
        case success
        case error

        var handler: RequestHandler {
            switch self {
            case .success:
                return MockData.mockingSuccessNoContent(for:)
            case .error:
                return MockData.mockingError(for:)
            }
        }
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let client = client, let handler = Self.testCase(for: request)?.handler else { return }
        do {
            let (data, response) = try handler(request)
            client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client.urlProtocol(self, didLoad: data)
            client.urlProtocolDidFinishLoading(self)
        } catch {
            client.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    static func testCase(for request: URLRequest) -> Case? {
        property(forKey: "testCase", in: request) as? Case
    }

    static func setTestCase(_ testCase: Case, for request: inout URLRequest) {
        let mutableRequest = (request as NSURLRequest) as! NSMutableURLRequest
        setProperty(
            testCase,
            forKey: "testCase",
            in: mutableRequest
        )
        request = mutableRequest as URLRequest
    }
}

class TransportTests: XCTestCase {
    func testURLSessionSendRequest() async throws {
        var request = URLRequest(url: URL())
        let session = URLSession(.success)
        MockURLProtocol.setTestCase(.success, for: &request)
        _ = try await session.send(request: request)
    }

    func testURLSessionSendRequestFailure() async {
        var request = URLRequest(url: URL())
        let session = URLSession(.error)
        MockURLProtocol.setTestCase(.error, for: &request)
        try await XCTAssertThrowsError(
            await session.send(request: request)
        )
    }
}
