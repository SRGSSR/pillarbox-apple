#!/usr/bin/xcrun make -f

CONFIGURATION_REPOSITORY_URL=https://github.com/SRGSSR/pillarbox-apple-configuration.git
CONFIGURATION_COMMIT_SHA1=dad52a4242c7997c179073caec03b8d6e718fc03

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

.PHONY: test-streams-start
test-streams-start:
	@echo "Starting test streams"
	@Scripts/test-streams.sh -s
	@echo "... done.\n"

.PHONY: test-streams-stop
test-streams-stop:
	@echo "Stopping test streams"
	@Scripts/test-streams.sh -k
	@echo "... done.\n"

.PHONY: test-ios
test-ios: setup
	@echo "Running unit tests..."
	@Scripts/test-streams.sh -s
	@bundle exec fastlane test_ios
	@Scripts/test-streams.sh -k
	@echo "... done.\n"

.PHONY: test-tvos
test-tvos: setup
	@echo "Running unit tests..."
	@Scripts/test-streams.sh -s
	@bundle exec fastlane test_tvos
	@Scripts/test-streams.sh -k
	@echo "... done.\n"

.PHONY: check-quality
check-quality: setup
	@echo "Checking quality..."
	@Scripts/check-quality.sh
	@echo "... done.\n"

.PHONY: fix-quality
fix-quality: setup
	@echo "Fixing quality..."
	@Scripts/fix-quality.sh
	@echo "... done.\n"

.PHONY: git-hook-install
git-hook-install:
	@echo "Installing git hooks..."
	@git config core.hooksPath hooks
	@echo "... done.\n"

.PHONY: git-hook-uninstall
git-hook-uninstall:
	@echo "Uninstalling git hooks..."
	@git config --unset core.hooksPath
	@echo "... done.\n"

.PHONY: spm-reload
spm-reload:
	@echo "Remove dependencies..."
	@swift package reset
	@echo "... done.\n"
	@echo "Reload dependencies..."
	@swift package update
	@echo "... done.\n"

.PHONY: clean-imports
clean-imports:
	@echo "Cleaning imports..."
	@mkdir -p .build
	@xcodebuild -scheme Pillarbox -destination generic/platform=ios > ./.build/xcodebuild.log
	@swiftlint analyze --fix --compiler-log-path ./.build/xcodebuild.log
	@xcodebuild -scheme Pillarbox-demo -project ./Demo/Pillarbox-demo.xcodeproj -destination generic/platform=iOS > ./.build/xcodebuild.log
	@swiftlint analyze --fix --compiler-log-path ./.build/xcodebuild.log
	@echo "... done.\n"

.PHONY: find-dead-code
find-dead-code:
	@echo "Start checking dead code..."
	@mkdir -p .build
	@xcodebuild -scheme Pillarbox -destination generic/platform=iOS -derivedDataPath ./.build/derived-data clean build &> /dev/null
	@periphery scan --retain-public --skip-build --index-store-path ./.build/derived-data/Index.noindex/DataStore/
	@xcodebuild -scheme Pillarbox-demo -project ./Demo/Pillarbox-demo.xcodeproj -destination generic/platform=iOS -derivedDataPath ./.build/derived-data clean build &> /dev/null
	@periphery scan --project ./Demo/Pillarbox-demo.xcodeproj --schemes Pillarbox-demo --targets Pillarbox-demo --skip-build --index-store-path ./.build/derived-data/Index.noindex/DataStore/
	@echo "... done.\n"

.PHONY: doc
doc: setup
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
	@echo "   test-streams-start                 Start servicing test streams"
	@echo "   test-streams-stop                  Stop servicing test streams"
	@echo ""
	@echo "   test-ios                           Build and run unit tests for iOS"
	@echo "   test-tvos                          Build and run unit tests for tvOS"
	@echo ""
	@echo "   check-quality                      Run quality checks"
	@echo "   fix-quality                        Fix quality automatically (if possible)"
	@echo ""
	@echo "   git-hook-install                   Use hooks located in ./hooks"
	@echo "   git-hook-uninstall                 Use default hooks located in .git/hooks"
	@echo ""
	@echo "   spm-reload                         Reload SPM dependencies"
	@echo "   clean-imports                      Remove useless imports from the project"
	@echo "   find-dead-code                     Find dead code"
	@echo "   doc                                Build the documentation"
	@echo ""
	@echo "   help                               Display this help message"
