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

public enum WebhookEvent: Codable, Equatable {
    case ping(WebhookEvents.Ping)
    case build(WebhookEvents.Build)
    case job(WebhookEvents.Job)
    case agent(WebhookEvents.Agent)

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
            self = .ping(try WebhookEvents.Ping(from: decoder))
        case .buildScheduled, .buildRunning, .buildFinished:
            self = .build(try WebhookEvents.Build(from: decoder))
        case .jobScheduled, .jobStarted, .jobFinished, .jobActivated:
            self = .job(try WebhookEvents.Job(from: decoder))
        case .agentConnected, .agentLost, .agentDisconnected, .agentStopping, .agentStopped:
            self = .agent(try WebhookEvents.Agent(from: decoder))
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
}

public enum WebhookEvents {
    public struct Ping: Codable, Equatable {
        /// The notification service that sent this webhook
        public var service: Service
        /// The ``Organization`` this notification belongs to
        public var organization: Organization
        /// The user who created the webhook
        public var sender: Sender
    }

    public struct Build: Codable, Equatable {
        public var event: Event
        /// The ``Buildkite/Build`` this notification relates to
        public var build: Buildkite.Build
        /// The ``Pipeline`` this notification relates to
        public var pipeline: Pipeline
        /// The user who created the webhook
        public var sender: Sender

        public enum Event: String, Codable, Equatable {
            /// A build has been scheduled
            case scheduled
            /// A build has started running
            case running
            /// A build has finished
            case finished
        }
    }

    public struct Job: Codable, Equatable {
        public var event: Event
        /// The ``Buildkite/Job`` this notification relates to
        public var job: Buildkite.Job
        /// The ``Buildkite/Build`` this notification relates to
        public var build: Buildkite.Build
        /// The ``Pipeline`` this notification relates to
        public var pipeline: Pipeline
        /// The user who created the webhook
        public var sender: Sender

        public enum Event: String, Codable, Equatable {
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

    public struct Agent: Codable, Equatable {
        public var event: Event
        /// The ``Buildkite/Agent`` this notification relates to
        public var agent: Buildkite.Agent
        /// The user who created the webhook
        public var sender: Sender

        public enum Event: String, Codable, Equatable {
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

public struct Service: Codable, Equatable, Identifiable {
    public var id: UUID
    public var provider: String
    public var settings: Settings

    public struct Settings: Codable, Equatable {
        public var url: URL
    }
}

public struct Sender: Codable, Equatable, Identifiable {
    public var id: UUID
    public var name: String
}


// Received POST {
//   host: '3424-2601-192-8600-bfc0-a963-fc8-ece3-46b8.ngrok.io',
//   'user-agent': 'Buildkite-Request',
//   'content-length': '772',
//   accept: '*/*',
//   'accept-encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
//   'content-type': 'application/json',
//   'x-buildkite-event': 'ping',
//   'x-buildkite-request': '01813932-4ac5-490a-82cd-eb6bcb2b55b6',
//   'x-buildkite-token': '62d32cdc0687926d9c556dff46a6f0e8',
//   'x-datadog-parent-id': '3879493372906842722',
//   'x-datadog-sampling-priority': '0',
//   'x-datadog-trace-id': '2090185261397568562',
//   'x-forwarded-for': '100.24.182.113',
//   'x-forwarded-proto': 'https'
// } {
//   event: 'ping',
//   service: {
//     id: '69774b46-b443-4ed9-8ee5-7817f9d5d3d6',
//     provider: 'webhook',
//     settings: {
//       url: 'https://3424-2601-192-8600-bfc0-a963-fc8-ece3-46b8.ngrok.io'
//     }
//   },
//   organization: {
//     id: '19ab06b9-17cd-4937-a44b-834976e5f894',
//     graphql_id: 'T3JnYW5pemF0aW9uLS0tMTlhYjA2YjktMTdjZC00OTM3LWE0NGItODM0OTc2ZTVmODk0',
//     url: 'https://api.buildkite.com/v2/organizations/asky',
//     web_url: 'https://buildkite.com/asky',
//     name: 'asky',
//     slug: 'asky',
//     agents_url: 'https://api.buildkite.com/v2/organizations/asky/agents',
//     emojis_url: 'https://api.buildkite.com/v2/organizations/asky/emojis',
//     created_at: '2020-03-14T20:04:43.567Z',
//     pipelines_url: 'https://api.buildkite.com/v2/organizations/asky/pipelines'
//   },
//   sender: { id: 'df71cc10-3cf0-49b0-9acb-5882342ca649', name: 'Aaron Sky' }
// }
