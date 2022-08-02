#!/usr/bin/xcrun make -f

CONFIGURATION_REPOSITORY_URL=https://github.com/SRGSSR/pillarbox-apple-configuration.git
CONFIGURATION_COMMIT_SHA1=89b7fb21ee3984f7265ad55180936e45b31b2285

.PHONY: all
all: setup test-ios test-tvos

.PHONY: setup
setup:
	@echo "Setting up the project..."
	@bundle install > /dev/null
	@Scripts/checkout-configuration.sh "${CONFIGURATION_REPOSITORY_URL}" "${CONFIGURATION_COMMIT_SHA1}" Configuration
	@echo "... done.\n"

.PHONY: fastlane-ios
fastlane-ios: setup
	@bundle exec fastlane --env ios

.PHONY: fastlane-tvos
fastlane-tvos: setup
	@bundle exec fastlane --env tvos

.PHONY: fastlane-ios-nightly
fastlane-ios-nightly: setup
	@bundle exec fastlane --env ios.nightly

.PHONY: fastlane-tvos-nightly
fastlane-tvos-nightly: setup
	@bundle exec fastlane --env tvos.nightly

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

.PHONY: doc
doc:
	@echo "Generating documentation sets..."
	@swift package generate-documentation
	@echo "... done.\n"

.PHONY: lint
lint:
	@echo "Linting project..."
	@swiftlint --fix && swiftlint
	@echo "... done.\n"

.PHONY: help
help:
	@echo "The following targets are available:"
	@echo "   all                      Build and run unit tests for all platforms"
	@echo "   setup                    Setup project"
	@echo "   fastlane-ios             Run fastlane for iOS release targets"
	@echo "   fastlane-tvos            Run fastlane for tvOS release targets"
	@echo "   fastlane-ios-nightly     Run fastlane for iOS nightly targets"
	@echo "   fastlane-tvos-nightly    Run fastlane for tvOS nightly targets"
	@echo "   test-ios                 Build and run unit tests for iOS"
	@echo "   test-tvos                Build and run unit tests for tvOS"
	@echo "   doc                      Build the documentation"
	@echo "   lint                     Lint project and fix issues"
	@echo "   help                     Display this help message"