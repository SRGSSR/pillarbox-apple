#!/usr/bin/xcrun make -f

CONFIGURATION_REPOSITORY_URL=https://github.com/SRGSSR/pillarbox-apple-configuration.git
CONFIGURATION_COMMIT_SHA1=8777b100612867166384606300c73b64d264132c

.PHONY: all
all: help

.PHONY: setup
setup:
	@echo "Setting up the project..."
	@bundle config set --local path 'vendor/bundle' > /dev/null
	@bundle install > /dev/null
	@Scripts/checkout-configuration.sh "${CONFIGURATION_REPOSITORY_URL}" "${CONFIGURATION_COMMIT_SHA1}" Configuration
	@echo "... done.\n"

.PHONY: fastlane-ios
fastlane-ios: setup
	@bundle exec fastlane --env ios

.PHONY: fastlane-tvos
fastlane-tvos: setup
	@bundle exec fastlane --env tvos

.PHONY: deliver-demo-nightly-ios
deliver-demo-nightly-ios: setup
	@echo "Delivering demo nightly build for iOS..."
	@bundle exec fastlane deliver_demo_nightly --env ios
	@echo "... done.\n"

.PHONY: deliver-demo-nightly-tvos
deliver-demo-nightly-tvos: setup
	@echo "Delivering demo nightly build for tvOS..."
	@bundle exec fastlane deliver_demo_nightly --env tvos
	@echo "... done.\n"

.PHONY: deliver-demo-release-ios
deliver-demo-release-ios: setup
	@echo "Delivering demo release build for iOS..."
	@bundle exec fastlane deliver_demo_release --env ios
	@echo "... done.\n"

.PHONY: deliver-demo-release-tvos
deliver-demo-release-tvos: setup
	@echo "Delivering demo release build for tvOS..."
	@bundle exec fastlane deliver_demo_release --env tvos
	@echo "... done.\n"

.PHONY: test-ios
test-ios: setup
	@echo "Running Appearance unit tests..."
	@bundle exec fastlane test --env ios
	@echo "... done.\n"

.PHONY: test-tvos
test-tvos: setup
	@echo "Running Appearance unit tests..."
	@bundle exec fastlane test --env tvos
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
	@echo "   all                                Default target"
	@echo "   setup                              Setup project"
	@echo "   fastlane-ios                       Run fastlane for iOS targets"
	@echo "   fastlane-tvos                      Run fastlane for tvOS targets"
	@echo "   deliver-demo-nightly-ios           Deliver a demo nightly build for iOS"
	@echo "   deliver-demo-nightly-tvos          Deliver a demo nightly build for tvOS"
	@echo "   deliver-demo-release-ios           Deliver a demo release build for iOS"
	@echo "   deliver-demo-release-tvos          Deliver a demo release build for tvOS"
	@echo "   test-ios                           Build and run unit tests for iOS"
	@echo "   test-tvos               			 Build and run unit tests for tvOS"
	@echo "   doc                                Build the documentation"
	@echo "   lint                               Lint project and fix issues"
	@echo "   help                               Display this help message"