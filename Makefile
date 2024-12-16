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
deliver-demo-nightly-ios:
	@Scripts/deliver-demo.sh $(MODE) --platform ios --configuration nightly

.PHONY: deliver-demo-nightly-tvos
deliver-demo-nightly-tvos:
	@Scripts/deliver-demo.sh $(MODE) --platform tvos --configuration nightly

.PHONY: deliver-demo-release-ios
deliver-demo-release-ios:
	@Scripts/deliver-demo.sh $(MODE) --platform ios --configuration release

.PHONY: deliver-demo-release-tvos install-bundler
deliver-demo-release-tvos:
	@Scripts/deliver-demo.sh $(MODE) --platform tvos --configuration release

.PHONY: test-streams-start
test-streams-start:
	@Scripts/test-streams.sh -s

.PHONY: test-streams-stop
test-streams-stop:
	@Scripts/test-streams.sh -k

.PHONY: test-ios
test-ios:
	@Scripts/test.sh --platform ios

.PHONY: test-tvos
test-tvos:
	@Scripts/test.sh --platform tvos

.PHONY: check-quality
check-quality:
	@Scripts/check-quality.sh

.PHONY: fix-quality
fix-quality:
	@Scripts/fix-quality.sh

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
	@echo "Available targets:"
	@echo
	@echo "Default:"
	@echo "  all                            Default target"
	@echo
	@echo "Archive:"
	@echo "  archive-demo-ios               Archive iOS demo [MODE=\"--non-interactive\"]"
	@echo "  archive-demo-tvos              Archive tvOS demo [MODE=\"--non-interactive\"]"
	@echo
	@echo "Deliver:"
	@echo "  deliver-demo-nightly-ios       Deliver nightly iOS demo build [MODE=\"--non-interactive\"]"
	@echo "  deliver-demo-nightly-tvos      Deliver nightly tvOS demo build [MODE=\"--non-interactive\"]"
	@echo "  deliver-demo-release-ios       Deliver release iOS demo build [MODE=\"--non-interactive\"]"
	@echo "  deliver-demo-release-tvos      Deliver release tvOS demo build [MODE=\"--non-interactive\"]"
	@echo
	@echo "Test:"
	@echo "  test-streams-start             Start test streams"
	@echo "  test-streams-stop              Stop test streams"
	@echo "  test-ios                       Build & run iOS unit tests"
	@echo "  test-tvos                      Build & run tvOS unit tests"
	@echo
	@echo "Quality:"
	@echo "  check-quality                  Run quality checks"
	@echo "  fix-quality                    Automatically fix quality issues"
	@echo
	@echo "Git Hooks:"
	@echo "  git-hook-install               Install custom hooks from ./hooks"
	@echo "  git-hook-uninstall             Revert to default hooks"
	@echo
	@echo "Utilities:"
	@echo "  clean-imports                  Remove unused imports"
	@echo "  find-dead-code                 Locate dead code"
	@echo
	@echo "Other:"
	@echo "  help                           Show this help message"
