//
//  MockContext.swift
//  
//
//  Created by Aaron Sky on 5/4/20.
//

import Foundation
import Buildkite

struct MockContext {
    var client: Buildkite
    var resources = MockResources()

    init() {
        let configuration = Configuration.default
        self.init(configuration: configuration, responses: [
            MockData.mockingSuccessNoContent(url: configuration.baseURL)
        ])
    }

    init<Content: Codable>(content: Content) throws {
        let configuration = Configuration.default
        try self.init(configuration: configuration, responses: [
             MockData.mockingSuccess(with: content, url: configuration.baseURL)
        ])
    }

    private init(configuration: Configuration, responses: [(Data, URLResponse)]) {
        let transport = MockTransport(responses: responses)
        client = Buildkite(configuration: configuration,
                               transport: transport)
    }
}
