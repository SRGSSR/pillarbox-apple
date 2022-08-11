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

.PHONY: fastlane
fastlane: setup
	@bundle exec fastlane

.PHONY: archive-demo-ios
archive-demo-ios: setup
	@bundle exec fastlane archive_demo_ios

.PHONY: archive-demo-tvos
archive-demo-tvos: setup
	@bundle exec fastlane archive_demo_tvos

.PHONY: deliver-demo-nightly-ios
deliver-demo-nightly-ios: setup
	@echo "Delivering demo nightly build for iOS..."
	@bundle exec fastlane deliver_demo_nightly_ios
	@echo "... done.\n"

.PHONY: deliver-demo-nightly-tvos
deliver-demo-nightly-tvos: setup
	@echo "Delivering demo nightly build for tvOS..."
	@bundle exec fastlane deliver_demo_nightly_tvos
	@echo "... done.\n"

.PHONY: deliver-demo-release-ios
deliver-demo-release-ios: setup
	@echo "Delivering demo release build for iOS..."
	@bundle exec fastlane deliver_demo_release_ios
	@echo "... done.\n"

.PHONY: deliver-demo-release-tvos
deliver-demo-release-tvos: setup
	@echo "Delivering demo release build for tvOS..."
	@bundle exec fastlane deliver_demo_release_tvos
	@echo "... done.\n"

.PHONY: test-ios
test-ios: setup
	@echo "Running Appearance unit tests..."
	@bundle exec fastlane test_ios
	@echo "... done.\n"

.PHONY: test-tvos
test-tvos: setup
	@echo "Running Appearance unit tests..."
	@bundle exec fastlane test_tvos
	@echo "... done.\n"

.PHONY: check-quality
check-quality: setup
	@echo "Checking quality..."
	@echo "... checking Swift code..."
	@swiftlint --quiet
	@echo "... checking Ruby scripts..."
	@bundle exec rubocop --format quiet
	@echo "... checking Shell scripts..."
	@shellcheck Scripts/*.sh
	@echo "... checking Markdown documentation..."
	@bundle exec mdl --style markdown_style.rb docs .github Sources/**/*.docc
	@echo "... checking YAML files..."
	@yamllint .*.yml .github
	@echo "... done.\n"

.PHONY: fix-quality
fix-quality:
	@echo "Fixing quality..."
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
	@echo "   fastlane                           Run fastlane"
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
	@echo "   check-quality                      Run quality checks"
	@echo "   fix-quality                        Fix quality automatically (if possible)"
	@echo ""
	@echo "   doc                                Build the documentation"
	@echo ""
	@echo "   help                               Display this help message"
