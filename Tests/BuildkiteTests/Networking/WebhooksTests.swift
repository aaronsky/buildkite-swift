//
//  WebhooksTests.swift
//  Buildkite
//
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Foundation
import XCTest

@testable import Buildkite

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class WebhooksTests: XCTestCase {
    let client = BuildkiteClient(
        transport: MockTransport(responses: []),
        tokens: nil
    )

    // MARK: - WebhookEvent Decoding

    private func performWebhookEventTest(_ event: WebhookEvent) throws {
        let data = try client.encoder.encode(event)
        let expected = try client.decodeWebhook(from: data)
        XCTAssertEqual(expected, event)
    }

    func testDecodeWebhook_ping() throws {
        try performWebhookEventTest(
            .ping(
                .init(
                    service: .init(
                        id: .init(),
                        provider: "",
                        settings: .init(url: .init())
                    ),
                    organization: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_buildScheduled() throws {
        try performWebhookEventTest(
            .build(
                .init(
                    event: .scheduled,
                    build: .init(),
                    pipeline: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_buildRunning() throws {
        try performWebhookEventTest(
            .build(
                .init(
                    event: .running,
                    build: .init(),
                    pipeline: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_buildFinished() throws {
        try performWebhookEventTest(
            .build(
                .init(
                    event: .finished,
                    build: .init(),
                    pipeline: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_jobScheduled() throws {
        try performWebhookEventTest(
            .job(
                .init(
                    event: .scheduled,
                    job: .waiter(
                        .init(
                            id: .init(),
                            graphqlId: ""
                        )
                    ),
                    build: .init(),
                    pipeline: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_jobStarted() throws {
        try performWebhookEventTest(
            .job(
                .init(
                    event: .started,
                    job: .waiter(
                        .init(
                            id: .init(),
                            graphqlId: ""
                        )
                    ),
                    build: .init(),
                    pipeline: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_jobFinished() throws {
        try performWebhookEventTest(
            .job(
                .init(
                    event: .finished,
                    job: .waiter(
                        .init(
                            id: .init(),
                            graphqlId: ""
                        )
                    ),
                    build: .init(),
                    pipeline: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_jobActivated() throws {
        try performWebhookEventTest(
            .job(
                .init(
                    event: .activated,
                    job: .waiter(
                        .init(
                            id: .init(),
                            graphqlId: ""
                        )
                    ),
                    build: .init(),
                    pipeline: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_agentConnected() throws {
        try performWebhookEventTest(
            .agent(
                .init(
                    event: .connected,
                    agent: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_agentLost() throws {
        try performWebhookEventTest(
            .agent(
                .init(
                    event: .lost,
                    agent: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_agentDisconnected() throws {
        try performWebhookEventTest(
            .agent(
                .init(
                    event: .disconnected,
                    agent: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_agentStopping() throws {
        try performWebhookEventTest(
            .agent(
                .init(
                    event: .stopping,
                    agent: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_agentStopped() throws {
        try performWebhookEventTest(
            .agent(
                .init(
                    event: .stopped,
                    agent: .init(),
                    sender: .init(
                        id: .init(),
                        name: ""
                    )
                )
            )
        )
    }

    func testDecodeWebhook_invalid() throws {
        struct FakeEvent: Codable, Equatable {
            var event = "invalid"
            var service: WebhookEvent.Service
            var organization: Organization
            var sender: WebhookEvent.Sender
        }

        let event = FakeEvent(
            service: .init(
                id: .init(),
                provider: "",
                settings: .init(url: .init())
            ),
            organization: .init(),
            sender: .init(
                id: .init(),
                name: ""
            )
        )
        let data = try client.encoder.encode(event)
        try XCTAssertThrowsError(client.decodeWebhook(from: data))
    }

    // MARK: - Validation

    let defaultBody = """
    {"event":"ping","service":{"id":"c9f8372d-c0cd-43dc-9274-768a875cf6ca","provider":"webhook","settings":{"url":"https://server.com/webhooks"}},"organization":{"id":"49801950-1df0-474f-bb56-ad6a930c5cb9","graphql_id":"T3JnYW5pemF0aW9uLS0tZTBmMzk3MgsTksGkxOWYtZTZjNzczZTJiYjEy","url":"https://api.buildkite.com/v2/organizations/acme-inc","web_url":"https://buildkite.com/acme-inc","name":"ACME Inc","slug":"acme-inc","agents_url":"https://api.buildkite.com/v2/organizations/acme-inc/agents","emojis_url":"https://api.buildkite.com/v2/organizations/acme-inc/emojis","created_at":"2021-02-03T20:34:10.486Z","pipelines_url":"https://api.buildkite.com/v2/organizations/acme-inc/pipelines"},"sender":{"id":"c9f8372d-c0cd-43dc-9269-bcbb7f308e3f","name":"ACME Man"}}
    """

    let defaultSignature = "timestamp=1642080837,signature=582d496ac2d869dd97a3101c4cda346288c49a742592daf582ec64c86449f79c"

    let secretKey = "29b1ff5779c76bd48ba6705eb99ff970".data(using: .utf8)!

    func testValidateWebhookPayload_signature() throws {
        try client.validateWebhookPayload(
            signatureHeader: defaultSignature,
            body: defaultBody.data(using: .utf8)!,
            secretKey: secretKey
        )
    }

    func testValidateWebhookPayload_signatureWithReplayLimit() throws {
        let replayLimit = (-1 * Date(timeIntervalSince1970: 1642080837).timeIntervalSinceNow + 10)
        try client.validateWebhookPayload(
            signatureHeader: defaultSignature,
            body: defaultBody.data(using: .utf8)!,
            secretKey: secretKey,
            replayLimit: replayLimit
        )
    }

    func testValidateWebhookPayload_errorSignatureMissing() throws {
        try XCTAssertThrowsError(
            client.validateWebhookPayload(
                signatureHeader: "",
                body: defaultBody.data(using: .utf8)!,
                secretKey: secretKey
            ),
            error: WebhookValidationError.signatureFormatInvalid
        )
    }

    func testValidateWebhookPayload_errorSignatureFormat() throws {
        try XCTAssertThrowsError(
            client.validateWebhookPayload(
                signatureHeader: "invalid",
                body: defaultBody.data(using: .utf8)!,
                secretKey: secretKey
            ),
            error: WebhookValidationError.signatureFormatInvalid
        )
    }

    func testValidateWebhookPayload_errorSignatureCorrupted() throws {
        try XCTAssertThrowsError(
            client.validateWebhookPayload(
                signatureHeader: "timestamp=1642080837,signature=yo",
                body: defaultBody.data(using: .utf8)!,
                secretKey: secretKey
            ),
            error: WebhookValidationError.signatureCorrupted
        )
    }

    func testValidateWebhookPayload_errorSignatureRefused() throws {
        try XCTAssertThrowsError(
            client.validateWebhookPayload(
                signatureHeader: defaultSignature.replacingOccurrences(of: "f", with: "a"),
                body: defaultBody.data(using: .utf8)!,
                secretKey: secretKey
            ),
            error: WebhookValidationError.signatureRefused
        )
    }

    func testValidateWebhookPayload_errorTimestampRefused() throws {
        try XCTAssertThrowsError(
            client.validateWebhookPayload(
                signatureHeader: defaultSignature,
                body: defaultBody.data(using: .utf8)!,
                secretKey: secretKey,
                replayLimit: 1
            ),
            error: WebhookValidationError.timestampRefused
        )
    }

    func testValidateWebhookPayload_token() throws {
        try client.validateWebhookPayload(
            tokenHeader: "29b1ff5779c76bd48ba6705eb99ff970",
            secretKey: secretKey
        )
    }

    func testValidateWebhookPayload_errorTokenRefused() throws {
        try XCTAssertThrowsError(
            client.validateWebhookPayload(
                tokenHeader: "invalid",
                secretKey: secretKey
            ),
            error: WebhookValidationError.tokenRefused
        )
    }
}
