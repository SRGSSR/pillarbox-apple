#!/usr/bin/xcrun make -f

CONFIGURATION_REPOSITORY_URL=https://github.com/SRGSSR/pillarbox-apple-configuration.git
CONFIGURATION_COMMIT_SHA1=e9cd78f090b9e73a7595b90140182989d4d8c7ef

.PHONY: all
all: help

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

.PHONY: archive-demo-ios
archive-demo-ios: setup
	@bundle exec fastlane archive_demo --env ios

.PHONY: archive-demo-tvos
archive-demo-tvos: setup
	@bundle exec fastlane archive_demo --env tvos

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

.PHONY: check-code-quality
check-code-quality: setup
	@echo "Checking code quality..."
	@echo "... checking Swift code..."
	@swiftlint
	@echo "... checking Ruby scripts..."
	@bundle exec rubocop
	@echo "... checking Shell scripts..."
	@shellcheck Scripts/*.sh
	@echo "... checking Markdown documentation..."
	@bundle exec mdl --style markdown_style.rb docs .github Sources/**/*.docc
	@echo "... done.\n"

.PHONY: fix-code-quality
fix-code-quality:
	@echo "Fixing codeq quality..."
	@swiftlint --fix && swiftlint
	@echo "... done.\n"

.PHONY: doc
doc:
	@echo "Generating documentation sets..."
	@bundle exec fastlane doc
	@echo "... done.\n"

.PHONY: help
help:
	@echo "The following targets are available:"
	@echo ""
	@echo "   all                                Default target"
	@echo "   setup                              Setup project"
	@echo ""
	@echo "   fastlane-ios                       Run fastlane for iOS targets"
	@echo "   fastlane-tvos                      Run fastlane for tvOS targets"
	@echo ""
	@echo "   archive-demo-ios                   Archive the iOS demo (for all configurations)"
	@echo "   archive-demo-tvos                  Archive the tvOS demo (for all configurations)"
	@echo ""
	@echo "   deliver-demo-nightly-ios           Deliver a demo nightly build for iOS"
	@echo "   deliver-demo-nightly-tvos          Deliver a demo nightly build for tvOS"
	@echo ""
	@echo "   deliver-demo-release-ios           Deliver a demo release build for iOS"
	@echo "   deliver-demo-release-tvos          Deliver a demo release build for tvOS"
	@echo ""
	@echo "   test-ios                           Build and run unit tests for iOS"
	@echo "   test-tvos                          Build and run unit tests for tvOS"
	@echo ""
	@echo "   check-code-quality                 Run code quality checks"
	@echo "   fix-code-quality                   Fix code quality automatically (where possible)"
	@echo ""
	@echo "   doc                                Build the documentation"
	@echo ""
	@echo "   help                               Display this help message"
