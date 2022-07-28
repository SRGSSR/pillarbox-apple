#!/usr/bin/xcrun make -f

.PHONY: all
all: test-ios test-tvos

.PHONY: doc
doc:
	@echo "Generating documentation sets..."
	@swift package generate-documentation
	@echo "... done.\n"

.PHONY: test-ios
test-ios:
	@echo "Running iOS unit tests..."
	@xcodebuild test -scheme Appearance -destination 'platform=iOS Simulator,name=iPhone 11' 2> /dev/null
	@xcodebuild test -scheme CoreBusiness -destination 'platform=iOS Simulator,name=iPhone 11' 2> /dev/null
	@xcodebuild test -scheme Diagnostics -destination 'platform=iOS Simulator,name=iPhone 11' 2> /dev/null
	@xcodebuild test -scheme Player -destination 'platform=iOS Simulator,name=iPhone 11' 2> /dev/null
	@xcodebuild test -scheme UserInterface -destination 'platform=iOS Simulator,name=iPhone 11' 2> /dev/null
	@echo "... done.\n"

.PHONY: test-tvos
test-tvos:
	@echo "Running tvOS unit tests..."
	@xcodebuild test -scheme Appearance -destination 'platform=tvOS Simulator,name=Apple TV' 2> /dev/null
	@xcodebuild test -scheme CoreBusiness -destination 'platform=tvOS Simulator,name=Apple TV' 2> /dev/null
	@xcodebuild test -scheme Diagnostics -destination 'platform=tvOS Simulator,name=Apple TV' 2> /dev/null
	@xcodebuild test -scheme Player -destination 'platform=tvOS Simulator,name=Apple TV' 2> /dev/null
	@xcodebuild test -scheme UserInterface -destination 'platform=tvOS Simulator,name=Apple TV' 2> /dev/null
	@echo "... done.\n"

.PHONY: lint
lint:
	@echo "Linting project..."
	@swiftlint --fix && swiftlint
	@echo "... done.\n"

.PHONY: help
help:
	@echo "The following targets are available:"
	@echo "   all                 Build and run unit tests for all platforms"
	@echo "   doc                 Build the documentation"
	@echo "   lint                Lint project and fix issues"
	@echo "   test-ios            Build and run unit tests for iOS"
	@echo "   test-tvos           Build and run unit tests for tvOS"
	@echo "   help                Display this help message"