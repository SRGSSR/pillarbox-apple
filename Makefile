#!/usr/bin/xcrun make -f

.PHONY: all
all: help


.PHONY: archive-demo-ios
archive-demo-ios: 
	@Scripts/archive-demo.sh $(MODE) --platform ios

.PHONY: archive-demo-tvos
archive-demo-tvos:
	@Scripts/archive-demo.sh $(MODE) --platform tvos

.PHONY: deliver-demo-nightly-ios
deliver-demo-nightly-ios: install-pkgx install-bundler
	@echo "Delivering demo nightly build for iOS..."
	@pkgx +magick +rsvg-convert bundle exec fastlane deliver_demo_nightly_ios
	@echo "... done.\n"

.PHONY: deliver-demo-nightly-tvos
deliver-demo-nightly-tvos: install-pkgx install-bundler
	@echo "Delivering demo nightly build for tvOS..."
	@pkgx +magick +rsvg-convert bundle exec fastlane deliver_demo_nightly_tvos
	@echo "... done.\n"

.PHONY: deliver-demo-release-ios
deliver-demo-release-ios: install-pkgx install-bundler
	@echo "Delivering demo release build for iOS..."
	@pkgx bundle exec fastlane deliver_demo_release_ios
	@echo "... done.\n"

.PHONY: deliver-demo-release-tvos install-bundler
deliver-demo-release-tvos: install-pkgx
	@echo "Delivering demo release build for tvOS..."
	@pkgx bundle exec fastlane deliver_demo_release_tvos
	@echo "... done.\n"

.PHONY: test-streams-start
test-streams-start: install-pkgx
	@echo "Starting test streams"
	@Scripts/test-streams.sh -s
	@echo "... done.\n"

.PHONY: test-streams-stop
test-streams-stop: install-pkgx
	@echo "Stopping test streams"
	@Scripts/test-streams.sh -k
	@echo "... done.\n"

.PHONY: test-ios
test-ios: install-pkgx install-bundler
	@echo "Running unit tests..."
	@Scripts/test-streams.sh -s
	@pkgx bundle exec fastlane test_ios
	@Scripts/test-streams.sh -k
	@echo "... done.\n"

.PHONY: test-tvos
test-tvos: install-pkgx install-bundler
	@echo "Running unit tests..."
	@Scripts/test-streams.sh -s
	@pkgx bundle exec fastlane test_tvos
	@Scripts/test-streams.sh -k
	@echo "... done.\n"

.PHONY: check-quality
check-quality: install-pkgx
	@echo "Checking quality..."
	@Scripts/check-quality.sh
	@echo "... done.\n"

.PHONY: fix-quality
fix-quality: install-pkgx
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
	@pkgx swiftlint analyze --fix --compiler-log-path ./.build/xcodebuild.log
	@xcodebuild -scheme Pillarbox-demo -project ./Demo/Pillarbox-demo.xcodeproj -destination generic/platform=iOS > ./.build/xcodebuild.log
	@pkgx swiftlint analyze --fix --compiler-log-path ./.build/xcodebuild.log
	@echo "... done.\n"

.PHONY: find-dead-code
find-dead-code:
	@echo "Start checking dead code..."
	@mkdir -p .build
	@xcodebuild -scheme Pillarbox -destination generic/platform=iOS -derivedDataPath ./.build/derived-data clean build &> /dev/null
	@pkgx periphery scan --retain-public --skip-build --index-store-path ./.build/derived-data/Index.noindex/DataStore/
	@xcodebuild -scheme Pillarbox-demo -project ./Demo/Pillarbox-demo.xcodeproj -destination generic/platform=iOS -derivedDataPath ./.build/derived-data clean build &> /dev/null
	@pkgx periphery scan --project ./Demo/Pillarbox-demo.xcodeproj --schemes Pillarbox-demo --targets Pillarbox-demo --skip-build --index-store-path ./.build/derived-data/Index.noindex/DataStore/
	@echo "... done.\n"

.PHONY: help
help:
	@echo "The following targets are available:"
	@echo
	@echo "   all                                Default target"
	@echo
	@echo "   archive-demo-ios                   Archive the iOS demo (for all configurations)"
	@echo "     Example: make archive-demo-ios MODE=--non-interactive (interactive by default)"
	@echo "   archive-demo-tvos                  Archive the tvOS demo (for all configurations)"
	@echo "     Example: make archive-demo-tvos MODE=--non-interactive (interactive by default)"
	@echo
	@echo "   deliver-demo-nightly-ios           Deliver a demo nightly build for iOS"
	@echo "   deliver-demo-nightly-tvos          Deliver a demo nightly build for tvOS"
	@echo
	@echo "   deliver-demo-release-ios           Deliver a demo release build for iOS"
	@echo "   deliver-demo-release-tvos          Deliver a demo release build for tvOS"
	@echo
	@echo "   test-streams-start                 Start servicing test streams"
	@echo "   test-streams-stop                  Stop servicing test streams"
	@echo
	@echo "   test-ios                           Build and run unit tests for iOS"
	@echo "   test-tvos                          Build and run unit tests for tvOS"
	@echo
	@echo "   check-quality                      Run quality checks"
	@echo "   fix-quality                        Fix quality automatically (if possible)"
	@echo
	@echo "   git-hook-install                   Use hooks located in ./hooks"
	@echo "   git-hook-uninstall                 Use default hooks located in .git/hooks"
	@echo
	@echo "   spm-reload                         Reload SPM dependencies"
	@echo "   clean-imports                      Remove useless imports from the project"
	@echo "   find-dead-code                     Find dead code"
	@echo
	@echo "   help                               Display this help message"
