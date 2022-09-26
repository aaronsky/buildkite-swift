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

/// Webhooks allow you to monitor and respond to events within your Buildkite organization,
/// providing a real time view of activity and allowing you to extend and integrate Buildkite into
/// your systems.
///
/// Webhooks can be added and configured on your
/// [organization's Notification Services](https://buildkite.com/organizations/-/services)
/// settings page.
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
        /// ID of the service.
        public var id: UUID
        /// Name of the service provider.
        public var provider: String
        /// Settings for the service.
        public var settings: Settings

        public struct Settings: Codable, Equatable, Hashable, Sendable {
            /// URL to the service.
            public var url: URL

            public init(
                url: URL
            ) {
                self.url = url
            }
        }

        public init(
            id: UUID,
            provider: String,
            settings: Settings
        ) {
            self.id = id
            self.provider = provider
            self.settings = settings
        }
    }

    public struct Sender: Codable, Equatable, Hashable, Identifiable, Sendable {
        /// ID of the user or entity that triggered the event.
        public var id: UUID
        /// Name of the user or entity that triggered the event.
        public var name: String

        public init(
            id: UUID,
            name: String
        ) {
            self.id = id
            self.name = name
        }
    }

    /// Event sent when webhook notification settings have changed.
    public struct Ping: Codable, Equatable, Hashable, Sendable {
        /// The specific sub-event this event was emitted for.
        public var event = "ping"
        /// The notification service that sent this webhook
        public var service: Service
        /// The ``Organization`` this notification belongs to
        public var organization: Organization
        /// The user who created the webhook
        public var sender: Sender

        public init(
            service: Service,
            organization: Organization,
            sender: Sender
        ) {
            self.service = service
            self.organization = organization
            self.sender = sender
        }
    }

    /// Event sent when a build is scheduled, starts, or finishes.
    public struct Build: Codable, Equatable, Hashable, Sendable {
        /// The specific sub-event this event was emitted for.
        public var event: Event
        /// The ``Buildkite/Build`` this notification relates to.
        public var build: Buildkite.Build
        /// The ``Pipeline`` this notification relates to.
        public var pipeline: Pipeline
        /// The user who created the webhook.
        public var sender: Sender

        public init(
            event: Event,
            build: Buildkite.Build,
            pipeline: Pipeline,
            sender: Sender
        ) {
            self.event = event
            self.build = build
            self.pipeline = pipeline
            self.sender = sender
        }

        public enum Event: String, Codable, Equatable, Hashable, Sendable {
            /// A build has been scheduled
            case scheduled = "build.scheduled"
            /// A build has started running
            case running = "build.running"
            /// A build has finished
            case finished = "build.finished"
        }
    }

    /// Event sent when a job in a build is scheduled, starts, finishes, or is unblocked.
    public struct Job: Codable, Equatable, Hashable, Sendable {
        /// The specific sub-event this event was emitted for.
        public var event: Event
        /// The ``Buildkite/Job`` this notification relates to.
        public var job: Buildkite.Job
        /// The ``Buildkite/Build`` this notification relates to.
        public var build: Buildkite.Build
        /// The ``Pipeline`` this notification relates to.
        public var pipeline: Pipeline
        /// The user who created the webhook.
        public var sender: Sender

        public init(
            event: Event,
            job: Buildkite.Job,
            build: Buildkite.Build,
            pipeline: Pipeline,
            sender: Sender
        ) {
            self.event = event
            self.job = job
            self.build = build
            self.pipeline = pipeline
            self.sender = sender
        }

        public enum Event: String, Codable, Equatable, Hashable, Sendable {
            /// A command step job has been scheduled to run on an agent.
            case scheduled = "job.scheduled"
            /// A command step job has started running on an agent.
            case started = "job.started"
            /// A job has finished.
            case finished = "job.finished"
            /// A block step job has been unblocked using the web or API.
            case activated = "job.activated"
        }
    }

    /// Event sent when an agent connects, disconnects, stops, or is lost.
    public struct Agent: Codable, Equatable, Hashable, Sendable {
        public var event: Event
        /// The ``Buildkite/Agent`` this notification relates to.
        public var agent: Buildkite.Agent
        /// The user who created the webhook.
        public var sender: Sender

        public init(
            event: Event,
            agent: Buildkite.Agent,
            sender: Sender
        ) {
            self.event = event
            self.agent = agent
            self.sender = sender
        }

        public enum Event: String, Codable, Equatable, Hashable, Sendable {
            /// An agent has connected to the API.
            case connected = "agent.connected"
            /// An agent has been marked as lost. This happens when Buildkite stops receiving pings from the agent.
            case lost = "agent.lost"
            /// An agent has disconnected. This happens when the agent shuts down and disconnects from the API.
            case disconnected = "agent.disconnected"
            /// An agent is stopping. This happens when an agent is instructed to stop from the API. It first transitions to stopping and finishes any current jobs.
            case stopping = "agent.stopping"
            /// An agent has stopped. This happens when an agent is instructed to stop from the API. It can be graceful or forceful.
            case stopped = "agent.stopped"
        }
    }
}
