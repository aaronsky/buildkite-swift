# Webhooks

Responding to webhook events from Buildkite.

## Overview

The [Buildkite Webhook API](https://buildkite.com/docs/apis/webhooks) is used to consume lifecycle events from Buildkite in real-time from your server application.

> Note: This will not be a tutorial to implement a server application, nor one to respond to Buildkite webhook events specifically. The purpose of this article is to inform how to use the helpers this client library provides to make implementing your webhooks easier. This article assumes you know how how to configure a new route in your server and expose it in such a way where Buildkite can communicate with it. 
