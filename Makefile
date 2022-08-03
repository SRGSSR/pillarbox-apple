#!/usr/bin/xcrun make -f

CONFIGURATION_REPOSITORY_URL=https://github.com/SRGSSR/pillarbox-apple-configuration.git
CONFIGURATION_COMMIT_SHA1=887244e044828cc5fb82b107d801f563fb033e18

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

.PHONY: deliver_demo_nightly-ios
deliver_demo_nightly-ios: setup
	@echo "Delivering demo nightly build for iOS..."
	@bundle exec fastlane deliver_demo_nightly --env ios
	@echo "... done.\n"

.PHONY: deliver_demo_nightly-tvos
deliver_demo_nightly-tvos: setup
	@echo "Delivering demo nightly build for tvOS..."
	@bundle exec fastlane deliver_demo_nightly --env tvos
	@echo "... done.\n"

.PHONY: deliver_demo_release-ios
deliver_demo_release-ios: setup
	@echo "Delivering demo release build for iOS..."
	@bundle exec fastlane deliver_demo_release --env ios
	@echo "... done.\n"

.PHONY: deliver_demo_release-tvos
deliver_demo_release-tvos: setup
	@echo "Delivering demo release build for tvOS..."
	@bundle exec fastlane deliver_demo_release --env tvos
	@echo "... done.\n"

.PHONY: test-appearance-ios
test-appearance-ios: setup
	@echo "Running Appearance unit tests..."
	@bundle exec fastlane test_appearance --env ios
	@echo "... done.\n"

.PHONY: test-appearance-tvos
test-appearance-tvos: setup
	@echo "Running Appearance unit tests..."
	@bundle exec fastlane test_appearance --env tvos
	@echo "... done.\n"

.PHONY: test-core-business-ios
test-core-business-ios: setup
	@echo "Running CoreBusiness unit tests..."
	@bundle exec fastlane test_core_business --env ios
	@echo "... done.\n"

.PHONY: test-core-business-tvos
test-core-business-tvos: setup
	@echo "Running CoreBusiness unit tests..."
	@bundle exec fastlane test_core_business --env tvos
	@echo "... done.\n"

.PHONY: test-diagnostics-ios
test-diagnostics-ios: setup
	@echo "Running Diagnostics unit tests..."
	@bundle exec fastlane test_diagnostics --env ios
	@echo "... done.\n"

.PHONY: test-diagnostics-tvos
test-diagnostics-tvos: setup
	@echo "Running Diagnostics unit tests..."
	@bundle exec fastlane test_diagnostics --env tvos
	@echo "... done.\n"

.PHONY: test-player-ios
test-player-ios: setup
	@echo "Running Player unit tests..."
	@bundle exec fastlane test_player --env ios
	@echo "... done.\n"

.PHONY: test-player-tvos
test-player-tvos: setup
	@echo "Running Player unit tests..."
	@bundle exec fastlane test_player --env tvos
	@echo "... done.\n"

.PHONY: test-user-interface-ios
test-user-interface-ios: setup
	@echo "Running UserInterface unit tests..."
	@bundle exec fastlane test_user_interface --env ios
	@echo "... done.\n"

.PHONY: test-user-interface-tvos
test-user-interface-tvos: setup
	@echo "Running UserInterface unit tests..."
	@bundle exec fastlane test_user_interface --env tvos
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
	@echo "   deliver_demo_nightly-ios           Deliver a demo nightly build for iOS"
	@echo "   deliver_demo_nightly-tvos          Deliver a demo nightly build for tvOS"
	@echo "   deliver_demo_release-ios           Deliver a demo release build for iOS"
	@echo "   deliver_demo_release-tvos          Deliver a demo release build for tvOS"
	@echo "   test-appearance-ios                Build and run Appearance unit tests for iOS"
	@echo "   test-appearance-tvos               Build and run Appearance unit tests for tvOS"
	@echo "   test-core-business-ios             Build and run CoreBusiness unit tests for iOS"
	@echo "   test-core-business-tvos            Build and run CoreBusiness unit tests for tvOS"
	@echo "   test-diagnostics-ios               Build and run Diagnostics unit tests for iOS"
	@echo "   test-diagnostics-tvos              Build and run Diagnostics unit tests for tvOS"
	@echo "   test-player-ios                    Build and run Player unit tests for iOS"
	@echo "   test-player-tvos                   Build and run Player unit tests for tvOS"
	@echo "   test-user-interface-ios            Build and run UserInterface unit tests for iOS"
	@echo "   test-user-interface-tvos           Build and run UserInterface unit tests for tvOS"
	@echo "   doc                                Build the documentation"
	@echo "   lint                               Lint project and fix issues"
	@echo "   help                               Display this help message"