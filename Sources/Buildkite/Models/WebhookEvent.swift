//
//  WebhookEvent.swift
//  Buildkite
//
//  Created by Aaron Sky on 6/6/22.
//  Copyright © 2022 Aaron Sky. All rights reserved.
//

import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum WebhookEvent: Codable, Equatable, Hashable, Sendable {
    case ping(Ping)
    case build(Build)
    case job(Job)
    case agent(Agent)

    private enum Unassociated: String, Codable {
        case ping
        case buildScheduled = "build.scheduled"
        case buildRunning = "build.running"
        case buildFinished = "build.finished"
        case jobScheduled = "job.scheduled"
        case jobStarted = "job.started"
        case jobFinished = "job.finished"
        case jobActivated = "job.activated"
        case agentConnected = "agent.connected"
        case agentLost = "agent.lost"
        case agentDisconnected = "agent.disconnected"
        case agentStopping = "agent.stopping"
        case agentStopped = "agent.stopped"
    }

    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let event = try container.decode(Unassociated.self, forKey: .event)
        switch event {
        case .ping:
            self = .ping(try Ping(from: decoder))
        case .buildScheduled, .buildRunning, .buildFinished:
            self = .build(try Build(from: decoder))
        case .jobScheduled, .jobStarted, .jobFinished, .jobActivated:
            self = .job(try Job(from: decoder))
        case .agentConnected, .agentLost, .agentDisconnected, .agentStopping, .agentStopped:
            self = .agent(try Agent(from: decoder))
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .ping(let event):
            try event.encode(to: encoder)
        case .build(let event):
            try event.encode(to: encoder)
        case .job(let event):
            try event.encode(to: encoder)
        case .agent(let event):
            try event.encode(to: encoder)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case event
    }

    public struct Service: Codable, Equatable, Hashable, Identifiable, Sendable {
        public var id: UUID
        public var provider: String
        public var settings: Settings

        public struct Settings: Codable, Equatable, Hashable, Sendable {
            public var url: URL
        }
    }

    public struct Sender: Codable, Equatable, Hashable, Identifiable, Sendable {
        public var id: UUID
        public var name: String
    }

    public struct Ping: Codable, Equatable, Hashable, Sendable {
        /// The notification service that sent this webhook
        public var service: Service
        /// The ``Organization`` this notification belongs to
        public var organization: Organization
        /// The user who created the webhook
        public var sender: Sender
    }

    public struct Build: Codable, Equatable, Hashable, Sendable {
        public var event: Event
        /// The ``Buildkite/Build`` this notification relates to
        public var build: Buildkite.Build
        /// The ``Pipeline`` this notification relates to
        public var pipeline: Pipeline
        /// The user who created the webhook
        public var sender: Sender

        public enum Event: String, Codable, Equatable, Hashable, Sendable {
            /// A build has been scheduled
            case scheduled
            /// A build has started running
            case running
            /// A build has finished
            case finished
        }
    }

    public struct Job: Codable, Equatable, Hashable, Sendable {
        public var event: Event
        /// The ``Buildkite/Job`` this notification relates to
        public var job: Buildkite.Job
        /// The ``Buildkite/Build`` this notification relates to
        public var build: Buildkite.Build
        /// The ``Pipeline`` this notification relates to
        public var pipeline: Pipeline
        /// The user who created the webhook
        public var sender: Sender

        public enum Event: String, Codable, Equatable, Hashable, Sendable {
            /// A command step job has been scheduled to run on an agent
            case scheduled
            /// A command step job has started running on an agent
            case started
            /// A job has finished
            case finished
            /// A block step job has been unblocked using the web or API
            case activated
        }
    }

    public struct Agent: Codable, Equatable, Hashable, Sendable {
        public var event: Event
        /// The ``Buildkite/Agent`` this notification relates to
        public var agent: Buildkite.Agent
        /// The user who created the webhook
        public var sender: Sender

        public enum Event: String, Codable, Equatable, Hashable, Sendable {
            /// An agent has connected to the API
            case connected
            /// An agent has been marked as lost. This happens when Buildkite stops receiving pings from the agent
            case lost
            /// An agent has disconnected. This happens when the agent shuts down and disconnects from the API
            case disconnected
            /// An agent is stopping. This happens when an agent is instructed to stop from the API. It first transitions to stopping and finishes any current jobs
            case stopping
            /// An agent has stopped. This happens when an agent is instructed to stop from the API. It can be graceful or forceful
            case stopped
        }
    }
}
