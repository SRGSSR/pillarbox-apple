#!/usr/bin/xcrun make -f

.PHONY: all
all: help

.PHONY: test-streams-start
test-streams-start:
	@Scripts/public/test-streams.sh -s

.PHONY: test-streams-stop
test-streams-stop:
	@Scripts/public/test-streams.sh -k

.PHONY: test-ios
test-ios:
	@Scripts/public/test-streams.sh -s
	@Scripts/public/test.sh -p ios
	@Scripts/public/test-streams.sh -k

.PHONY: test-tvos
test-tvos:
	@Scripts/public/test-streams.sh -s
	@Scripts/public/test.sh -p tvos
	@Scripts/public/test-streams.sh -k

.PHONY: check-quality
check-quality:
	@Scripts/public/check-quality.sh

.PHONY: fix-quality
fix-quality:
	@Scripts/public/fix-quality.sh

.PHONY: git-hook-install
git-hook-install:
	@Scripts/public/git-hooks.sh -i

.PHONY: git-hook-uninstall
git-hook-uninstall:
	@Scripts/public/git-hooks.sh -u

.PHONY: clean-imports
clean-imports:
	@Scripts/public/clean-imports.sh

.PHONY: find-dead-code
find-dead-code:
	@Scripts/public/find-dead-code.sh

.PHONY: help
help:
	@echo "Available targets:"
	@echo
	@echo "Default:"
	@echo "  all                            Default target"
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
