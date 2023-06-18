# Facts
GIT_REPO_TOPLEVEL := $(shell git rev-parse --show-toplevel)

# Apple Platform Destinations
DESTINATION_PLATFORM_IOS_SIMULATOR = platform=iOS Simulator,name=iPhone 11 Pro Max
DESTINATION_PLATFORM_MACOS = platform=macOS
DESTINATION_PLATFORM_TVOS_SIMULATOR = platform=tvOS Simulator,name=Apple TV
DESTINATION_PLATFORM_WATCHOS_SIMULATOR = platform=watchOS Simulator,name=Apple Watch Series 5 (44mm)

# Formatting
SWIFT_FORMAT_BIN := swift format
SWIFT_FORMAT_CONFIG_FILE := $(GIT_REPO_TOPLEVEL)/.swift-format.json
FORMAT_PATHS := $(GIT_REPO_TOPLEVEL)/Examples $(GIT_REPO_TOPLEVEL)/Package.swift $(GIT_REPO_TOPLEVEL)/Sources $(GIT_REPO_TOPLEVEL)/Tests

# Tasks

.PHONY: default
default: test-all

.PHONY: test-all
test-all: test-library test-library-xcode build-examples

.PHONY: test-library
test-library:
	swift test --parallel

.PHONY: test-library-xcode
test-library-xcode: test-library-xcode-ios test-library-xcode-macos test-library-xcode-tvos test-library-xcode-watchos

.PHONY: test-library-xcode-ios
test-library-xcode-ios:
	xcodebuild test \
		-scheme Buildkite \
		-destination "$(DESTINATION_PLATFORM_IOS_SIMULATOR)" \
		-quiet

.PHONY: test-library-xcode-macos
test-library-xcode-macos:
	xcodebuild test \
		-scheme Buildkite \
		-destination "$(DESTINATION_PLATFORM_MACOS)" \
		-quiet

.PHONY: test-library-xcode-tvos
test-library-xcode-tvos:
	xcodebuild test \
		-scheme Buildkite \
		-destination "$(DESTINATION_PLATFORM_TVOS_SIMULATOR)" \
		-quiet

.PHONY: test-library-xcode-watchos
test-library-xcode-watchos:
	xcodebuild \
		-scheme Buildkite \
		-destination "$(DESTINATION_PLATFORM_WATCHOS_SIMULATOR)" \
		-quiet

.PHONY: build-examples
build-examples: build-examples-all

.PHONY: build-examples-all
build-examples-all:
	swift build --package-path Examples

.PHONY: build-examples-simple
build-examples-simple:
	swift build --package-path Examples --product simple

.PHONY: build-examples-graphql
build-examples-graphql:
	swift build --package-path Examples --product graphql

.PHONY: build-examples-advanced-authorization
build-examples-advanced-authorization:
	swift build --package-path Examples --product advanced-authorization

.PHONY: build-examples-test-analytics
build-examples-test-analytics:
	swift build --package-path Examples --product test-analytics

.PHONY: build-examples-webhooks
build-examples-webhooks:
	swift build --package-path Examples --product webhooks

.PHONY: format
format:
	$(SWIFT_FORMAT_BIN) \
		--configuration $(SWIFT_FORMAT_CONFIG_FILE) \
		--ignore-unparsable-files \
		--in-place \
		--recursive \
		$(FORMAT_PATHS)

.PHONY: lint
lint:
	$(SWIFT_FORMAT_BIN) lint \
		--configuration $(SWIFT_FORMAT_CONFIG_FILE) \
		--ignore-unparsable-files \
		--recursive \
		$(FORMAT_PATHS)
